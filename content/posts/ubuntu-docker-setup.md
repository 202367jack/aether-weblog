---
title: "Ubuntu 24.04 上从零装 Docker"
date: 2026-10-19
categories: ["技术"]
tags: ["Docker", "Ubuntu", "环境搭建"]
summary: "官方源 + 国内镜像加速，顺带解决拉镜像超时和日志把磁盘写满这两个坑。"
---

## 为什么不用系统自带的 docker.io

Ubuntu 仓库里的 `docker.io` 版本旧、没有 `docker compose` 子命令，后面跑 compose 文件会到处别扭。用 Docker 官方源，一条命令就能拿到新版和 compose 插件。

## 装

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

装完验证：

```bash
docker version
docker compose version
```

## 坑一：拉镜像超时

国内直连 Docker Hub 基本会卡住。改 `/etc/docker/daemon.json`：

```json
{
  "registry-mirrors": ["https://docker.1ms.run", "https://docker.1panel.live"]
}
```

然后 `systemctl restart docker`。加速器地址会失效，失效了就换一个，不用怀疑自己的网络。

## 坑二：日志把磁盘写满

容器默认的 json-file 日志没有上限，一个话多的服务跑几周就能吃掉几十 G。同一份 `daemon.json` 里加上：

```json
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "100m", "max-file": "3" }
}
```

注意：这两个参数只对**之后新建**的容器生效，已有容器要重建。

## 小结

装 Docker 本身五分钟，真正花时间的是镜像源和日志这两件“装完之后才会发现”的事。提前配好，省得半夜磁盘告警。
