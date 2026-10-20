---
title: "Aether Weblog"
date: 2026-10-20
summary: "这个博客本身：Hugo 静态站，内容在 Git，一条 push 完成发布。"
stack: "Hugo · GitHub Actions · Nginx · jsDelivr"
repo: "https://github.com/202367jack/blog"
status: "进行中"
---

## 结构

- **内容仓库**：Markdown 是唯一真源，文章历史就是 `git log`
- **图片**：文章配图放 page bundle 由 Hugo 处理，海报等复用图走 jsDelivr
- **部署**：push 触发 GitHub Actions，构建产物 rsync 到服务器，Nginx 直接读文件

## 为什么不用动态博客

不需要登录、不需要访客提交内容、不需要后台。文章写完 push 一次，页面就是现成的 HTML，服务器只跑一个 Nginx，内存占用十兆级。

代价是不能在网页后台写作，但我本来就在本地写代码，这个代价值得。

## 技术细节

- 搜索：构建时生成 `index.json`，前端做子串匹配，不依赖任何服务
- 简历页：同一份 Markdown，网页展示 + 打印样式导出 PDF
- 主题：自己写的轻量模板，没有主题依赖，改样式不用跟上游升级打架
