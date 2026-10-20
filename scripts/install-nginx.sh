#!/usr/bin/env bash
# 在 Ubuntu 24.04 上从源码安装 Nginx，并配好博客站点与 systemd 服务。
# 幂等：已安装则跳过编译，配置文件缺了才写，不会覆盖你改过的配置。
#
# 用法：
#   sudo bash scripts/install-nginx.sh
#   sudo NGINX_VERSION=1.30.6 WEB_ROOT=/var/www/blog bash scripts/install-nginx.sh
#
# 装到 /codedeveloper/circumstances/nginx/nginx-<版本>，软链 current 指向它，
# 这样升级只需再跑一次脚本，旧版本目录留着可随时切回。

set -euo pipefail

NGINX_VERSION="${NGINX_VERSION:-1.30.6}"
PREFIX="${NGINX_PREFIX:-/codedeveloper/circumstances/nginx}"
WEB_ROOT="${WEB_ROOT:-/var/www/blog}"
SERVER_NAME="${SERVER_NAME:-_}"
SERVICE_NAME="${SERVICE_NAME:-nginx-cloud}"

SRC="$PREFIX/nginx-$NGINX_VERSION"
CURRENT="$PREFIX/current"

log() { printf '\n==> %s\n' "$*"; }
die() { printf '\n[错误] %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "请用 root 运行：sudo bash $0"

# ---------------------------------------------------------------- 依赖
log "安装编译依赖"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq --no-install-recommends \
  build-essential libpcre2-dev zlib1g-dev libssl-dev curl ca-certificates >/dev/null

id www-data >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin www-data

mkdir -p "$PREFIX"

# ---------------------------------------------------------------- 编译
if [ -x "$SRC/sbin/nginx" ]; then
  log "已存在 $SRC/sbin/nginx，跳过编译"
else
  log "下载并编译 Nginx $NGINX_VERSION"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fL --retry 3 --connect-timeout 15 \
    -o "$TMP/nginx.tar.gz" "https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz" \
    || die "下载失败，检查网络或改用代理：https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz"
  tar -xzf "$TMP/nginx.tar.gz" -C "$PREFIX"
  cd "$SRC"

  # 注意：不加 --with-http_v3_module，Ubuntu 24.04 的 OpenSSL 3.0 没有 QUIC 接口
  ./configure \
    --prefix="$SRC" \
    --sbin-path="$SRC/sbin/nginx" \
    --conf-path="$SRC/conf/nginx.conf" \
    --pid-path="$SRC/logs/nginx.pid" \
    --lock-path="$SRC/logs/nginx.lock" \
    --error-log-path="$SRC/logs/error.log" \
    --http-log-path="$SRC/logs/access.log" \
    --http-client-body-temp-path="$SRC/temp/client_body" \
    --http-proxy-temp-path="$SRC/temp/proxy" \
    --http-fastcgi-temp-path="$SRC/temp/fastcgi" \
    --http-uwsgi-temp-path="$SRC/temp/uwsgi" \
    --http-scgi-temp-path="$SRC/temp/scgi" \
    --user=www-data \
    --group=www-data \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module \
    >/dev/null
  make -j"$(nproc)" >/dev/null
  make install >/dev/null
  cd - >/dev/null
fi

mkdir -p "$SRC/logs" "$SRC/temp/client_body" "$SRC/temp/proxy" \
         "$SRC/temp/fastcgi" "$SRC/temp/uwsgi" "$SRC/temp/scgi" "$SRC/conf/sites"
ln -sfn "nginx-$NGINX_VERSION" "$CURRENT"

# ---------------------------------------------------------------- 主配置
log "写入 conf/nginx.conf"
cat > "$CURRENT/conf/nginx.conf" <<'NGINXCONF'
worker_processes auto;
pid        logs/nginx.pid;
error_log  logs/error.log warn;

events { worker_connections 1024; }

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile       on;
    tcp_nopush     on;
    keepalive_timeout 65;
    server_tokens  off;
    charset        utf-8;

    access_log  logs/access.log;

    gzip on;
    gzip_types text/css application/javascript application/json image/svg+xml;
    gzip_min_length 1024;

    include sites/*.conf;
}
NGINXCONF

# ---------------------------------------------------------------- 站点配置
if [ -f "$CURRENT/conf/sites/blog.conf" ]; then
  log "conf/sites/blog.conf 已存在，保留不覆盖"
else
  log "写入 conf/sites/blog.conf"
  cat > "$CURRENT/conf/sites/blog.conf" <<SITECONF
server {
    listen 80;
    listen [::]:80;
    server_name $SERVER_NAME;

    root $WEB_ROOT;
    index index.html;
    charset utf-8;

    location ~* \.(css|js|jpg|jpeg|png|gif|webp|svg|ico|woff2?)\$ {
        expires 7d;
        add_header Cache-Control "public";
        try_files \$uri =404;
    }

    location ~* \.html\$ {
        add_header Cache-Control "no-cache";
    }

    location / {
        try_files \$uri \$uri/ =404;
    }

    error_page 404 /404.html;
    location = /404.html { internal; }

    location /.well-known/acme-challenge/ {
        root $WEB_ROOT;
    }
}
SITECONF
fi

# ---------------------------------------------------------------- 站点目录
log "准备站点目录 $WEB_ROOT"
mkdir -p "$WEB_ROOT"
if [ ! -f "$WEB_ROOT/index.html" ] && [ -z "$(ls -A "$WEB_ROOT" 2>/dev/null)" ]; then
  printf '<!doctype html><meta charset="utf-8"><title>等待部署</title><h1>nginx ok</h1><p>站点目录已就绪，等待首次部署。</p>\n' > "$WEB_ROOT/index.html"
fi
chown -R www-data:www-data "$WEB_ROOT"
chmod 755 "$WEB_ROOT"

# ---------------------------------------------------------------- systemd
log "写入 /etc/systemd/system/$SERVICE_NAME.service"
cat > "/etc/systemd/system/$SERVICE_NAME.service" <<UNIT
[Unit]
Description=Nginx (custom build in $PREFIX)
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=$CURRENT/logs/nginx.pid
ExecStartPre=$CURRENT/sbin/nginx -t
ExecStart=$CURRENT/sbin/nginx
ExecReload=$CURRENT/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
TimeoutStopSec=5
KillMode=mixed
LimitNOFILE=65535
PrivateTmp=true

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable "$SERVICE_NAME" >/dev/null 2>&1 || true
systemctl restart "$SERVICE_NAME"

# ---------------------------------------------------------------- 自检
log "自检"
sleep 1
"$CURRENT/sbin/nginx" -t
printf '版本：%s\n' "$("$CURRENT/sbin/nginx" -v 2>&1)"
printf '端口：%s\n' "$(ss -lntp 2>/dev/null | awk '$4 ~ /:80$/ {print $4}' | paste -sd, -)"
printf '本机访问：%s\n' "$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1/ || echo '失败')"
printf '站点目录：%s\n' "$WEB_ROOT"

cat <<'DONE'

完成。下一步：
  1. 把本仓库的 deploy key 公钥追加到 /root/.ssh/authorized_keys
  2. 在 GitHub 仓库配置 SERVER_HOST / SERVER_USER / SSH_PRIVATE_KEY 三个 Secrets
  3. push 触发 Actions，或手动 rsync 一次 public/
详见 docs/部署.md
DONE
