# FastAPI + PostgreSQL + Redis 成品模板

这是一个可直接运行的最小成品模板，适合在 `Windows + WSL2 Ubuntu + Docker` 环境下快速启动一个 Python 后端项目。

## 技术栈

- Python `3.12.9`
- FastAPI
- Uvicorn
- PostgreSQL
- Redis
- `uv` 管理依赖
- `pytest` 做基础测试
- Docker Compose 负责本地基础设施

## 适用场景

- AI 后端服务
- 中小型 API 项目
- 单人开发 MVP
- 需要数据库和缓存的本地开发环境

## 目录结构

```text
fastapi-postgres-redis
├─ AGENTS.md
├─ README.md
├─ .env.example
├─ .gitignore
├─ .python-version
├─ Makefile
├─ compose.yaml
├─ pyproject.toml
├─ scripts
│  ├─ bootstrap.sh
│  ├─ check-env.sh
│  ├─ dev.sh
│  └─ test.sh
├─ src
│  └─ app
│     ├─ __init__.py
│     ├─ config.py
│     └─ main.py
└─ tests
   └─ test_health.py
```

## 快速开始

### 1. 复制模板

```bash
cp -r fastapi-postgres-redis my-api
cd my-api
```

### 2. 准备配置

```bash
cp .env.example .env
```

### 3. 检查环境

```bash
make check
```

### 4. 初始化项目

```bash
make bootstrap
```

### 5. 启动开发服务

```bash
make dev
```

服务启动后访问：

- `http://127.0.0.1:8000/health`
- `http://127.0.0.1:8000/docs`

### 6. 运行测试

```bash
make test
```

## 推荐给 Agent 的提示词

### 场景 1：基于当前模板继续扩展

```text
先阅读 AGENTS.md、README.md、pyproject.toml、compose.yaml、.env.example 和 scripts 目录。
保持当前技术栈为 FastAPI + PostgreSQL + Redis + uv。
在这个基础上扩展业务代码、配置和测试，不要随意替换技术栈。
完成后告诉我新增了哪些文件、如何运行、还需要我补什么配置。
```

### 场景 2：让 Agent 增加具体业务模块

```text
先阅读 AGENTS.md 和 README.md。
基于当前模板，为项目增加一个新的业务模块，包含路由、配置、数据访问层和对应测试。
保持 src 目录结构清晰，优先简单、稳定、便于后续扩展。
```

### 场景 3：让 Agent 加入数据库模型和迁移

```text
基于当前 FastAPI 模板，为项目补充 PostgreSQL 数据模型、迁移方案和初始化脚本。
优先选择适合单人维护和本地开发的方案，并更新 README.md、scripts 和测试入口。
```

## 使用原则

- `.env` 不提交 Git
- `.env.example` 需要保留并更新
- 中间件统一通过 Docker 管理
- 项目尽量保持统一脚本入口
- 如果后续要加 AI 能力，优先通过环境变量注入 API Key