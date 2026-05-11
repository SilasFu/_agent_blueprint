# React + FastAPI 全栈模板协作规则

本文件用于指导 Agent CLI 在当前全栈模板基础上继续扩展，而不是随意改造技术栈或破坏前后端分离结构。

## 1. 当前固定技术栈

除非用户明确要求变更，否则默认保持以下技术栈：

- 前端：React + Vite + pnpm
- 后端：FastAPI + uv
- 数据库：PostgreSQL
- 缓存：Redis
- 本地基础设施：Docker Compose

## 2. 结构约定

- 前端代码放在 `frontend/src`
- 后端代码放在 `backend/src/app`
- 前后端配置应尽量分开管理
- API 访问优先由前端调用后端 HTTP 接口，不要把业务逻辑塞进前端

## 3. 依赖与运行约定

- 前端依赖由 `pnpm` 管理
- 后端依赖由 `uv` 管理
- PostgreSQL 和 Redis 统一通过 `compose.yaml` 启动
- 优先使用 `make` 或 `scripts` 作为统一入口

## 4. 修改优先级

当用户提出新需求时，按以下顺序理解和修改：

1. `README.md`
2. `backend/pyproject.toml`
3. `frontend/package.json`
4. `.env.example`
5. `compose.yaml`
6. `scripts` 目录
7. 前后端源码和测试

## 5. 输出要求

每次完成修改后，你应明确告诉用户：

- 修改了哪些文件
- 前端改了什么，后端改了什么
- 如何运行和验证
- 是否需要补充环境变量、数据库配置或外部 API Key

## 6. 长期原则

- 优先保持前后端边界清晰
- 优先保持脚本入口统一
- 优先保持模板简单、稳定、可扩展
- 不为了复杂而复杂