---
title: "简历"
name: "Aether"
role: "Java 后端开发 · 2027 届"
location: "江西 · 南昌"
email: "wangjie202367@qq.com"
github: "https://github.com/202367jack"
summary: "南昌大学软件工程 2023 级本科生，GPA 3.59/4.0，专业排名 14/329（前 4.3%）。熟悉 Java 并发、Spring 全家桶与 DDD 分层设计，独立完成过拼团营销交易系统与 Spring AI 的 RAG/MCP 工具服务，能把项目从设计一路做到 Docker 部署。"
skills:
  - "Java：集合、多线程、反射，熟悉并发编程"
  - "框架：Spring、Spring Boot、MyBatis、Spring Cloud"
  - "中间件：RabbitMQ（异步通信、流量削峰）、Redis（分布式缓存、Redisson 分布式锁）"
  - "设计：DDD 领域驱动设计，充血模型、四色建模、依赖倒置"
  - "工程化：Docker 容器化部署、Git、Maven、IDEA"
education:
  - school: "南昌大学（211）"
    degree: "软件工程 · 本科"
    period: "2023.09 – 2027.06"
    bullets:
      - "GPA 3.59/4.0，专业排名 14/329（前 4.3%）"
      - "主修课程：算法分析与设计 96、计算机网络 95、数据结构 94、数据库原理 93、操作系统 85、计算机组成原理 85"
projects:
  - name: "基于 DDD 设计的拼团营销交易系统"
    period: "2025.05 – 2025.08"
    desc: "参考拼多多拼团场景，基于 DDD 六边形架构实现覆盖试算、锁单、结算、退款全流程的交易系统。技术栈：Spring Boot、MyBatis、RabbitMQ、Redis、MySQL、Docker。"
    bullets:
      - "基于策略模式 + 责任链抽象通用营销框架，实现满减/折扣/N 元购/直减的动态计算与活动校验、用户限购、库存占用的链式执行，避免 if-else 嵌套"
      - "基于 RabbitMQ + 本地消息表 + 定时任务补偿保障拼团结算最终一致性，支持 HTTP/MQ 双模式回调，结合分布式锁防止重复操作"
      - "基于分阶段锁单结算与条件更新（影响行数判断）、Redis 原子抢占库存，保证高并发下单的同时防止拼团超卖"
      - "基于 Redis BitSet 存储用户标签、发布订阅实现配置热更新（RTopic + @DCCValue 注解），实现人群秒级过滤与配置无重启生效"
      - "基于 Docker Compose 编排中间件与 ELK/Prometheus 监控环境，实现一键部署与可观测"
  - name: "基于 Spring AI 的 RAG 检索增强与 MCP 工具服务"
    period: "2026.03 – 2026.05"
    desc: "基于 Spring AI 构建 AI 知识库与 MCP 工具服务体系，实现 RAG 检索增强生成与大模型工具调用编排。技术栈：Spring Boot、Spring AI、MCP、PGVector、Tika、Redis、JGit、Docker。"
    bullets:
      - "基于 RAG 实现检索增强：Tika 文档解析 + TokenTextSplitter 分片 + Embedding 向量化写入 PGVector，支持本地文件与 Git 仓库导入，按知识标签执行 Top-K 语义检索，缓解大模型幻觉"
      - "基于 MCP 协议将 CSDN 发帖、微信通知、系统配置查询封装为标准化工具，通过 @Tool 注解暴露给大模型，实现对外部能力的自主调用（Function Calling）"
      - "实现文档 Markdown→HTML 转换发布与微信模板消息推送（含 access_token 动态获取），打通内容生产到分发通知的完整链路"
      - "基于定时任务 + ChatClient 编排大模型完成「生成文章 → 调用 MCP 发帖 → 触发微信通知」的多步工具调用工作流，实现无人值守的自动内容生产"
awards:
  - "特等优秀学生奖学金、一等优秀学生奖学金"
  - "三好学生标兵、社会活动积极分子"
  - "CET-6、CET-4、中级软件设计师"
---

有较强的学习能力和责任心，能够独立完成后端接口开发，对 Java 后端开发方向有较强兴趣。
