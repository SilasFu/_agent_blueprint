# React + FastAPI + PostgreSQL + Redis 全栈模板

这是一个适合前后端分离项目的最小可运行成品模板，适合在 `Windows + WSL2 Ubuntu + Docker` 环境下快速启动一个全栈项目。

## 技术栈

- 前端：React + Vite + pnpm
- 后端：FastAPI + uv
- 数据库：PostgreSQL
- 缓存：Redis
- 本地基础设施：Docker Compose

## 适用场景

- 前后端分离 Web 项目
- 管理后台
- AI SaaS 原型
- 中小型 MVP

## 目录结构

```text
react-fastapi-postgres-redis
├─ AGENTS.md
├─ README.md
├─ .env.example
├─ .gitignore
├─ Makefile
├─ compose.yaml
├─ backend
│  ├─ .python-version
│  ├─ pyproject.toml
│  ├─ src
│  │  └─ app
│  │     ├─ __init__.py
│  │     ├─ config.py
│  │     └─ main.py
│  └─ tests
│     └─ test_health.py
├─ frontend
│  ├─ package.json
│  ├─ vite.config.ts
│  ├─ index.html
│  └─ src
│     ├─ App.tsx
│     ├─ main.tsx
│     └─ index.css
└─ scripts
   ├─ bootstrap.sh
   ├─ check-env.sh
   ├─ dev.sh
   ├─ dev-backend.sh
   ├─ dev-frontend.sh
   └─ test.sh
```

## 快速开始

### 1. 复制模板

```bash
cp -r react-fastapi-postgres-redis my-fullstack-app
cd my-fullstack-app
cp .env.example .env
```

### 2. 检查环境

```bash
make check
```

### 3. 初始化项目

```bash
make bootstrap
```

### 4. 分别启动前后端

后端：

```bash
make dev-backend
```

前端：

```bash
make dev-frontend
```

### 5. 运行测试

```bash
make test
```

## 默认访问地址

- 前端：`http://127.0.0.1:5173`
- 后端健康检查：`http://127.0.0.1:8000/health`
- 后端文档：`http://127.0.0.1:8000/docs`

## 推荐给 Agent 的提示词

### 场景 1：继续扩展全栈功能

```text
先阅读 AGENTS.md、README.md、backend、frontend、compose.yaml、.env.example 和 scripts 目录。
保持当前技术栈为 React + FastAPI + PostgreSQL + Redis。
在这个基础上扩展前后端功能、接口、页面和测试，不要随意替换技术栈。
```

### 场景 2：新增一个完整业务模块

```text
基于当前模板新增一个完整业务模块，包含后端接口、前端页面、状态处理和最小测试。
优先保持前后端边界清晰、目录结构稳定、README 和脚本同步更新。
```

### 场景 3：加入 AI 能力

```text
在当前全栈模板基础上增加 AI 功能。
优先把 AI 调用放在后端，前端只负责输入和展示结果。
通过环境变量管理 API Key，并同步更新 .env.example、README 和相关脚本。
```