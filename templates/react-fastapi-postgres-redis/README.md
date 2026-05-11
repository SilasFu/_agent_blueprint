# React + FastAPI + PostgreSQL + Redis 全栈模板

这是一个适合前后端分离项目的最小可运行成品模板，适合在 `Windows + WSL2 Ubuntu + Docker` 环境下快速启动一个全栈项目。

如果你是第一次使用，默认先执行：

```bash
make bootstrap
```

它会先检查环境，再初始化前后端依赖和 Docker 基础服务；如果缺少工具，会先用中文提示，再征求安装确认。

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

### 2. 推荐直接初始化项目

```bash
make bootstrap
```

如果你只想先单独检查环境，再执行：

```bash
make check
```

### 3. 分别启动前后端

后端：

```bash
make dev-backend
```

前端：

```bash
make dev-frontend
```

### 4. 运行测试

```bash
make test
```

## 典型成功提示

执行 `make bootstrap` 成功后，终端通常会看到类似提示：

```text
[完成] 已根据 .env.example 创建 .env 文件
[完成] 已创建后端 Python 虚拟环境
[完成] 已同步后端依赖
[完成] 已安装前端依赖
[完成] 已启动 PostgreSQL 和 Redis
[完成] 项目初始化结束。
[下一步] 建议在两个终端分别执行：
  make dev-backend
  make dev-frontend
  make test
```

这表示前后端依赖和 Docker 基础服务都已经准备好，可以进入日常开发。

## 默认访问地址

- 前端：`http://127.0.0.1:5173`
- 后端健康检查：`http://127.0.0.1:8000/health`
- 后端文档：`http://127.0.0.1:8000/docs`

## 运行成功后会看到什么

- 启动前端后，页面标题会显示 `React + FastAPI Template`
- 页面正文默认会尝试请求后端 `/api/message`
- 当前端和后端都正常启动时，页面上会显示：

```text
Hello from FastAPI backend
```

- 后端接口的典型返回结果如下：

访问 `GET /health`：

```json
{
  "status": "ok",
  "environment": "dev"
}
```

访问 `GET /api/message`：

```json
{
  "message": "Hello from FastAPI backend"
}
```

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

## 这个模板能证明什么

- 仓库不仅能生成后端骨架，也能提供最小可运行的前后端分离样例
- 用户可以通过统一脚本完成环境检查、初始化、开发启动和测试
- 适合作为“从 0 到最小全栈项目”的验证样例
