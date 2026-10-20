---
title: "cloud-server-setup"
date: 2026-10-19
summary: "一台 4c8g 云服务器从裸机到可复现环境的一套脚本。"
stack: "Ubuntu 24.04 · Docker Compose · Nginx · GitHub Actions"
repo: "https://github.com/202367jack/cloud-server-setup"
status: "进行中"
---

## 为什么做

原来的安装脚本只认 CentOS 7.9，而 CentOS 7 已经在 2024-06 停止维护，新机器装上去连 Node 都跑不起来。于是把整套流程按 Ubuntu 24.04 重写了一遍。

## 做了什么

- **系统基线**：时区、swap、基础工具、内核参数，一条脚本跑完
- **软件栈**：Docker 官方源 + 国内镜像加速器 + 日志轮转
- **中间件**：MySQL / Redis / Nacos / RabbitMQ 等 15 个容器，全部先创建不启动
- **验证脚本**：一条命令检查每个服务的健康状况，不用逐个 `docker ps`

## 踩的坑

**Redis 的 `bind 0.0.0.0` 不能改成 `127.0.0.1`。** 端口映射进来时源地址是 Docker 网桥网关，不是本机回环，改了就彻底连不上。正确做法是宿主机端口绑回环 + `requirepass`。

**MySQL 默认没有数据卷。** 官方 compose 只挂了配置和初始化 SQL，数据在容器可写层里，`docker rm -f mysql` 等于全部丢失。加一行 `./mysql/data:/var/lib/mysql` 才是持久化。

**prometheus 和 xxl-job 都占 9090。** 同时启动必有一个失败，把 prometheus 改到 9091。

## 结构

```
cloud-server-setup/
├── README.md
├── docs/                 系统基线、软件栈、安全、与上游差异
├── scripts/
│   ├── 00-bootstrap-ubuntu.sh
│   ├── 01-stack-up.sh
│   ├── 02-verify.sh
│   └── 03-install-jdk-maven.sh
└── software/
    ├── docker-compose-software.yml
    └── docker-compose-cloud.yml
```
