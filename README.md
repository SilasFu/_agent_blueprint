# Agent 可感知项目脚手架模板

这是一套面向 `Agent CLI + 人类协作者` 的项目协作骨架。

它的重点不是预先塞满业务代码，而是把“怎么提任务、怎么执行任务、怎么交付结果”沉淀成一套可重复读取的项目规则系统。

## 这是什么

- 一套项目协作协议，而不是某个固定技术栈的成品项目
- 一套让 Agent 先读规则、再做判断、最后稳定交付的文档体系
- 一套可迁移、可分享、可复用的工作流骨架

## 核心原则

- 文档优先，模板次之，脚本兜底
- 根目录文档和 `doc/` 是默认主入口
- `templates/` 是可选样例，不是默认上下文
- 没有明确选择模板前，Agent 不应默认读取 `templates/`
- 如果样例模板和当前规则冲突，以当前任务、根规则和需求文档为准

## 默认环境约定

- 开发环境：`Windows + WSL2 Ubuntu`
- Python：`pyenv + uv`
- Node：`nvm + pnpm`
- 基础设施：`Docker + PostgreSQL + Redis`
- 配置原则：保留 `.env.example`，不提交真实 `.env`
- 代码保护：必须纳入 Git，建议尽早推送远程仓库

## 最快上手

```bash
cp -r _agent_blueprint my-new-project
cd my-new-project
cp project-spec.example.yaml project-spec.yaml
cp .env.example .env
```

然后按这个顺序继续：

1. 先看 `doc/使用总览导航.md`
2. 填写 `project-spec.yaml`
3. 让 Agent 先读 `AGENTS.md`
4. 运行 `bash scripts/check-env.sh`
5. 再按需要运行 `bash scripts/bootstrap.sh`

## 先看什么

- 第一次打开这套体系：看 `doc/使用总览导航.md`
- 第一次起新项目：看 `项目初始化操作手册.md`
- 想调整 Agent 行为：看 `AGENTS.md`
- 想继续维护和扩展这套文档体系：看 `doc/文档命名与目录规范.md`
- 想知道以后维护这套体系时先改什么、别动什么：看 `doc/最小维护说明.md`
- 想统一这套体系里的高频术语：看 `doc/术语使用规范.md`
- 想查看环境、Git、备份、项目模板等长期资料：看 `doc/开发环境知识库总目录.md`
- 想把任务描述清楚：看 `doc/任务输入模板.md`
- 想规范执行过程：看 `doc/任务执行与交付验收准则.md`
- 想规范最终汇报：看 `doc/任务结果输出模板.md`
- 想处理具体任务：看 `doc/task-playbooks/README.md`

## 这套体系怎么协作

- `project-spec.yaml` 负责描述项目需求
- `doc/任务输入模板.md` 负责约束任务怎么提
- `AGENTS.md` 负责定义 Agent 总规则
- `doc/任务执行与交付验收准则.md` 负责约束执行质量
- `doc/task-playbooks/` 负责提供高频具体任务的操作手册
- `doc/任务结果输出模板.md` 负责约束最终交付表达

## 模板什么时候介入

只有下面情况才建议读取 `templates/`：

- 你已经决定直接从某个成品模板开始
- 你需要现成样例加速初始化
- 根目录规则已经不足以支撑当前搭建任务

下面情况不建议先读模板：

- 还在梳理规则
- 还在澄清需求
- 还在设计协作流程
- 当前任务只是补文档、补规范或补执行准则

## 目录概览

```text
_agent_blueprint
├─ AGENTS.md
├─ README.md
├─ 项目初始化操作手册.md
├─ doc
│  ├─ 任务执行与交付验收准则.md
│  ├─ 使用总览导航.md
│  ├─ 文档命名与目录规范.md
│  ├─ 术语使用规范.md
│  ├─ 最小维护说明.md
│  ├─ 任务输入模板.md
│  ├─ 任务结果输出模板.md
│  ├─ 开发环境知识库总目录.md
│  └─ task-playbooks
│     ├─ README.md
│     ├─ 新增接口操作手册.md
│     ├─ 新增数据表与迁移操作手册.md
│     ├─ 接入第三方API操作手册.md
│     └─ 改动后验证与回归检查手册.md
├─ .env.example
├─ .gitignore
├─ .python-version
├─ .nvmrc
├─ Makefile
├─ compose.yaml
├─ project-spec.example.yaml
└─ scripts
   ├─ bootstrap.sh
   ├─ check-env.sh
   ├─ dev.sh
   └─ test.sh
```

## 可选成品模板

- 这些模板默认属于“可选样例”，不是当前项目的必选上下文
- 只有在你明确决定从某个模板起步时，才让 Agent 深入读取对应目录
- 如果当前任务是建立规则、澄清约束、完善流程，优先使用根目录文档，不要让 Agent 被模板实现细节带偏
- `templates/fastapi-postgres-redis`
  - 这是一个可直接运行的 `FastAPI + PostgreSQL + Redis` 成品模板
  - 适合 Python 后端、AI 服务、中小型 API 项目和 MVP 开发
  - 如果你不想从通用协议开始拼装，可以直接复制这个模板作为新项目起点
- `templates/fastapi-postgres-redis-alembic`
  - 这是一个增强版 `FastAPI + SQLAlchemy + Alembic + PostgreSQL + Redis` 成品模板
  - 适合一开始就需要数据库模型、迁移管理和更接近真实项目结构的后端项目
  - 如果你预计项目会长期演进，优先从这个模板起步更稳
- `templates/react-fastapi-postgres-redis`
  - 这是一个前后端分离的 `React + FastAPI + PostgreSQL + Redis` 全栈成品模板
  - 适合管理后台、SaaS 原型、AI Web 应用和中小型 MVP
  - 如果你需要同时维护前端页面和后端 API，可以直接从这个模板起步

## 一句话记忆

- 先看导航
- 再写需求
- 再让 Agent 读规则
- 最后按统一方式执行和交付
