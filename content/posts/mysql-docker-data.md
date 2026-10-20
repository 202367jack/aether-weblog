---
title: "docker rm 之后数据没了：MySQL 容器的持久化"
date: 2026-10-19
categories: ["技术"]
tags: ["MySQL", "Docker", "踩坑"]
summary: "官方 compose 只挂了配置和初始化 SQL，数据在容器可写层里，删容器即删库。"
---

## 事故现场

按网上的 compose 文件起了一个 MySQL：

```yaml
services:
  mysql:
    image: mysql:8.0.32
    volumes:
      - ./mysql/conf/my.cnf:/etc/my.cnf
      - ./mysql/sql:/docker-entrypoint-initdb.d
```

跑了一周，写了些测试数据。某天想改配置，习惯性 `docker rm -f mysql` 再 `docker compose up -d`。

起来之后库是空的——建库脚本重新跑了一遍，但**之前写的数据全没了**。

## 原因

上面那段 volumes 里挂的是「配置文件」和「初始化脚本目录」，**没有挂数据目录**。

MySQL 的数据存在容器的 `/var/lib/mysql`，属于容器的可写层。容器一删，这层就跟着删。这就好比你把人家的硬盘装在自己抽屉里，抽屉一扔，硬盘也没了。

## 修法

加一行绑定挂载：

```yaml
    volumes:
      - ./mysql/data:/var/lib/mysql
      - ./mysql/conf/my.cnf:/etc/my.cnf
      - ./mysql/sql:/docker-entrypoint-initdb.d
```

**一个坑里套着另一个坑**：容器里的 mysql 用户 uid 是 999，宿主机上这个目录如果归 root，MySQL 起不来，会报 `Permission denied`。先建目录并改属主：

```bash
mkdir -p mysql/data
sudo chown -R 999:999 mysql/data
```

## 另一个容易误会的点

`docker-entrypoint-initdb.d` 里的 SQL **只在数据目录为空时执行**。

所以第一次启动会建库建表，之后重启不会重跑。想重新初始化，必须把 `./mysql/data` 清空——这也意味着数据会丢。生产环境别这么干。

## 小结

- 判断一个容器有没有持久化，看它有没有挂载**数据目录**，不是看有没有 volumes
- 挂载前先对齐 uid，否则起不来
- 初始化脚本只跑一次，别拿它当迁移工具
