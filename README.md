# Aether Weblog

个人站点：学习经历、技术笔记、项目、影视推荐、简历。

- 生成器：Hugo（静态，无数据库、无后端）
- 主题：本仓库内自写轻量模板（`layouts/` + `static/css/style.css`），不依赖外部主题
- 部署：GitHub Actions 构建 → rsync 到服务器 → Nginx 直接读文件
- 内容真源：本仓库的 Markdown，文章历史 = `git log`

**日常写作看 [docs/写内容.md](docs/写内容.md)**：新建笔记 / 随笔 / 影视、放图片、本地预览、push 发布的完整命令都在那一份里。

## 部署到新服务器

服务器环境先按 [cloud-server-setup](https://github.com/202367jack/cloud-server-setup) 准备好（系统、Docker、基础工具），然后：

```bash
git clone git@github.com:202367jack/aether-weblog.git /dev-ops/aether-weblog
cd /dev-ops/aether-weblog
sudo bash scripts/install-nginx.sh        # 编译 Nginx + 站点配置 + systemd
```

再配部署密钥和三个 GitHub Secrets（`SERVER_HOST` / `SERVER_USER` / `SSH_PRIVATE_KEY`），push 即上线。
完整步骤、换域名与 HTTPS、排错表：[docs/部署.md](docs/部署.md)。

## 目录

```
aether-weblog/
├── hugo.toml              站点配置（标题、菜单、社交、输出格式）
├── archetypes/            hugo new 的模板（default.md / media.md）
├── content/
│   ├── about/index.md     关于
│   ├── resume/index.md    简历（结构化 front matter，网页 + 打印导出 PDF）
│   ├── essays/            随笔（按时间倒序，每页 8 篇）
│   ├── posts/             技术笔记
│   ├── projects/          项目
│   └── media/             影视推荐（类型 / 剧情 / 地区三轴筛选）
├── layouts/               页面模板
├── assets/
│   ├── css/style.css      样式（深色模式、打印样式、交互动效）
│   ├── js/search.js       站内搜索（读 /index.json）
│   ├── js/enhance.js      光斑跟随、卡片 3D 倾斜
│   └── images/avatar.jpg  头像（构建时压成 256×256 WebP）
├── scripts/install-nginx.sh   新服务器装 Nginx 与站点
├── deploy/                nginx.conf、nginx-cloud.service 模板
├── docs/写内容.md         新建笔记/随笔/影视、放图、发布
├── docs/部署.md           部署步骤、HTTPS、排错
└── .github/workflows/deploy.yml   构建 + rsync
```

## 本地预览

```powershell
winget install --id Hugo.Hugo.Extended -e   # 只需一次
cd D:\PrivateGithubRepository\aether-weblog
hugo server -D
```

打开 <http://localhost:1313>。改文件会自动刷新。

只构建不启动服务器：

```bash
hugo --minify
# 产物在 public/
```

## 写内容（笔记 / 随笔 / 影视）

完整步骤（建文件夹、front matter、放图、预览、发布、改删草稿）在 **[docs/写内容.md](docs/写内容.md)**。

三步速记：

```powershell
cd D:\PrivateGithubRepository\aether-weblog
New-Item -ItemType Directory -Force -Path "content\posts\docker-network-debug" | Out-Null
New-Item -ItemType File -Force -Path "content\posts\docker-network-debug\index.md" | Out-Null
```

```yaml
---
title: "标题"
date: 2026-10-20T20:10:00+08:00
categories: ["技术"]
tags: ["Docker", "MySQL"]
summary: "一两句话，会显示在列表和搜索结果里"
draft: false
---
```

一条铁律：**一篇内容一个文件夹，里面必须有 `index.md`**。文件夹名就是 URL（`content/posts/docker-network-debug/` → `/posts/docker-network-debug/`），用英文、数字、连字符。

`draft: true` 只在 `hugo server -D` 下可见，push 也不会发布。

发布：

```powershell
git add -A
git commit -m "post: 标题"
git push
```

## 加一个项目

`content/projects/项目名/index.md`：

```yaml
---
title: "项目名"
date: 2026-10-20
summary: "一句话说明"
stack: "Java · Spring Boot · MySQL"
repo: "https://github.com/202367jack/xxx"
demo: "https://demo.example.com"
status: "进行中"
---
```

`repo` / `demo` / `status` 都是可选的，没写就不显示。

## 加一部影视

`content/media/片名/index.md`：

```yaml
---
title: "漫长的季节"
date: 2023-04-22
medium: "剧集"                  # 类型：电影 / 剧集 / 动画 / 综艺，列表第一行筛选
genre: ["悬疑", "剧情", "家庭"]  # 剧情：列表第二行筛选，可多个
region: "中国"                  # 地区：列表第三行筛选
year: 2023
rating: 9.4                     # 0-10，列表按它从高到低排
status: "看完"                  # 在看 / 看完 / 重看 / 弃了
summary: "一句话简介"
tags: ["悬疑"]
---
```

海报存成同目录的 `poster.jpg` 即自动压缩，也可用 `poster: "https://..."` 写外链。

**注意字段叫 `medium` 不叫 `type`**：Hugo 里 `type` 会改变模板查找路径，用了它这一页就不会走 `layouts/media/single.html`。

不写 `poster` 时显示渐变底色 + 片名的占位卡，不会出现断图。

## 图片怎么放

三种图，三种放法。

**1. 文章配图 —— 跟文章放同一个文件夹（page bundle）**

```
content/posts/某篇文章/
├── index.md
└── shot.jpg
```

正文里用 shortcode（推荐）：

```
{{</* img src="shot.jpg" alt="截图说明" caption="图注，可省略" */>}}
```

构建时 Hugo 自动做四件事：限制到最大 1600px、转 WebP、生成 800w / 1600w 两档 `srcset`、加 `loading="lazy"`。一张 1MB 的图出来通常 100–250KB。

也可以写普通 Markdown 图片 `![](shot.jpg)`，但那是原图直出，没有 WebP 和响应式。

**2. 影视海报 —— 放条目同目录，命名 `poster.*`**

```
content/media/漫长的季节/
├── index.md
└── poster.jpg
```

模板会自己缩：列表页 300×450、详情页 600×900，都是 WebP。注意**必须是文件夹形式**（`index.md` 而不是 `片名.md`）才认得到资源；继续用 `poster:` 写外链也支持，二选一。

**3. 头像、favicon —— 放 assets**

- 头像：`assets/images/avatar.jpg`，模板压成 256×256 WebP（原来那张 1MB 的原图会变十几 KB，favicon 再从它生成 64×64）
- 其他固定图（分享图、背景）：`static/images/xxx.png`，原样输出到 `/images/xxx.png`

### 为什么不用「GitHub 仓库 + jsDelivr」当主链路

- jsDelivr 的大陆节点需要备案，国内访问时快时慢，偶尔直接打不开——你的读者大概率在大陆
- 单文件超 20MB 会被拒；仓库越大，首次回源越慢
- 图片跟着站点同源走（nginx + 7 天缓存）在国内是最稳的，也少一次 DNS/TLS 握手

真要用图床（七牛、阿里云 OSS、Cloudflare R2），`poster:` 和 `{{</* img */>}}` 都接受完整 URL，直接换即可。

### 体积红线

- 单张原图 ≤ 2000px 宽、≤ 1.5MB（Hugo 会再压，但仓库里存的是原图）
- 截图用 PNG，照片用 JPG
- 仓库图片总量控制在 200MB 以内，否则 clone 和每次 Actions 构建都会变慢

## 简历

`content/resume/index.md` 的 front matter 是结构化的（姓名、技能、经历、项目、教育），模板负责排版。
页面右上角「打印 / 存为 PDF」调用浏览器打印，选「另存为 PDF」即可得到 A4 版简历。

改内容只改一份 Markdown，网页和 PDF 同时生效。

## 搜索

构建时生成 `/index.json`（标题、摘要、标签、正文前 600 字），`static/js/search.js` 在前端做子串匹配。
没有后端、没有第三方服务，中文直接用。

## 部署

### 一次性准备

**服务器端**——用仓库里的脚本，不要手动 apt 装 Nginx：

```bash
mkdir -p /dev-ops
git clone git@github.com:202367jack/aether-weblog.git /dev-ops/aether-weblog
cd /dev-ops/aether-weblog
sudo bash scripts/install-nginx.sh
```

脚本会装依赖、从源码编译 Nginx 1.30.6 到 `/codedeveloper/circumstances/nginx/`、写站点配置 `conf/sites/blog.conf`、注册 systemd 服务 `nginx-cloud`，最后自检。
重复执行是安全的：已编译就跳过，站点配置已存在就不覆盖。

细节、换域名、HTTPS、排错：[docs/部署.md](docs/部署.md)。

**GitHub 仓库 Secrets：**

| 名称 | 内容 |
|---|---|
| `SERVER_HOST` | 服务器公网 IP |
| `SERVER_USER` | `root`（或部署专用账号） |
| `SSH_PRIVATE_KEY` | 部署私钥全文（对应公钥放服务器 `~/.ssh/authorized_keys`） |

### 之后每次

```bash
git add -A && git commit -m "post: 新文章" && git push
```

Actions 自动构建并 rsync 到 `/var/www/blog`，几十秒后线上生效。

## 换域名 / 上线 HTTPS

1. `hugo.toml` 里 `baseURL` 改成 `https://你的域名/`
2. 域名解析 A 记录指向服务器 IP
3. 备案完成后（国内服务器必须）装证书：

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d 你的域名
```

certbot 会自动改 Nginx 配置并处理续期。

## 常见问题

**构建报 `found no layout file`**：检查 `layouts/` 下的目录名是否和内容目录名一致（如 `content/media/` 对应 `layouts/media/`）。

**中文标签链接 404**：模板里用 `.GetTerms "tags"` 取标签页链接，不要手拼 `/tags/标签名/`。

**改了 `hugo.toml` 菜单不生效**：`pageRef` 指向的页面必须存在，否则该菜单项会被静默丢弃。

**样式没更新**：浏览器缓存，`Ctrl+F5`。
