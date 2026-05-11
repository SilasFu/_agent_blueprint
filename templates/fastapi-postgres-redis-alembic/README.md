# FastAPI + PostgreSQL + Redis + Alembic 增强模板

这是一个比轻量版更贴近真实项目落地的成品模板，适合需要数据库模型、迁移和更清晰后端结构的 Python 项目。

如果你是第一次使用，默认先执行：

```bash
make bootstrap
```

它会先检查环境，再初始化项目、启动 PostgreSQL 和 Redis，并自动执行数据库迁移。

## 技术栈

- Python `3.12.9`
- FastAPI
- SQLAlchemy 2.x
- Alembic
- PostgreSQL
- Redis
- `uv` 管理依赖
- `pytest` 做基础测试
- Docker Compose 负责本地基础设施

## 适用场景

- 中小型 API 项目
- 需要数据库模型和迁移管理的后端服务
- AI 后端或管理后台 API
- 希望从一开始就保留可维护数据库结构的项目

## 快速开始

### 1. 复制模板

```bash
cp -r fastapi-postgres-redis-alembic my-api
cd my-api
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

### 3. 启动开发服务

```bash
make dev
```

### 4. 运行测试

```bash
make test
```

### 5. 手动执行数据库迁移

```bash
make migrate
```

## 典型成功提示

执行 `make bootstrap` 成功后，终端通常会看到类似提示：

```text
[完成] 已创建 Python 虚拟环境 .venv
[完成] 已同步 Python 依赖
[完成] PostgreSQL 和 Redis 已启动
[迁移] 正在执行 Alembic 数据库迁移...
[完成] 项目初始化结束。
[下一步] 你现在可以执行：
  make dev
  make test
  make migrate
```

这表示模板已经完成环境检查、依赖同步、基础服务启动和初始迁移。

## 运行成功后会看到什么

启动 `make dev` 后，你可以访问：

- `http://127.0.0.1:8000/`
- `http://127.0.0.1:8000/health`
- `http://127.0.0.1:8000/docs`
- `http://127.0.0.1:8000/users`
- `http://127.0.0.1:8000/items`

其中：

- 访问 `/` 时，典型返回结果类似：

```json
{
  "message": "FastAPI Alembic template is running",
  "app": "app",
  "environment": "dev"
}
```

- 访问 `/health` 时，典型返回结果类似：

```json
{
  "status": "ok",
  "app": "app",
  "environment": "dev"
}
```

- `GET /users` 和 `GET /items` 提供了更接近真实项目的列表型接口起点，适合继续扩展模型、迁移和业务逻辑。

## 默认能力

- `/health` 健康检查
- `/items` 查询数据
- `/items` 创建示例数据
- `/users` 用户列表接口
- `/users/{user_id}` 用户详情接口
- `POST /users` 创建用户
- `PATCH /users/{user_id}` 更新用户
- `DELETE /users/{user_id}` 删除用户
- 默认提供 `items` 表和 `users` 表的 Alembic 初始迁移

## 用户模块说明

模板内置了一个最小但完整的用户标准模块，适合作为后续认证、权限和后台管理功能的起点。

默认字段：

- `id`
- `username`
- `email`
- `password_hash`
- `full_name`
- `is_active`

当前能力：

- 用户模型
- Alembic 迁移
- 创建、查询、更新、删除接口
- 不在响应中返回密码哈希
- 基于 `sqlite` 的接口测试示例

## 推荐给 Agent 的提示词

### 场景 1：在当前模板上扩展业务

```text
先阅读 AGENTS.md、README.md、pyproject.toml、alembic、compose.yaml、.env.example 和 scripts 目录。
保持当前技术栈为 FastAPI + SQLAlchemy + Alembic + PostgreSQL + Redis + uv。
在此基础上扩展业务模块、数据库模型、迁移和测试，不要随意更换技术栈。
```

### 场景 2：新增模型与迁移

```text
基于当前模板，为项目新增一个业务实体，并同步补充 SQLAlchemy 模型、Pydantic schema、Alembic 迁移、路由和测试。
优先保持结构清晰、小步修改、README 和脚本同步更新。
```

### 场景 2.1：继续扩展用户模块

```text
基于当前模板已有的用户模块，继续补充认证、权限、用户资料或后台管理功能。
保持现有 User 模型、Schema、CRUD、Alembic 迁移和测试结构一致。
如果新增字段或表结构，请同步补 Alembic 迁移，并更新 README.md 和测试。
```

### 场景 3：加入认证或 AI 能力

```text
基于当前模板继续扩展认证或 AI 集成功能。
优先通过环境变量管理外部服务配置，保持数据库层、业务层和 API 层边界清晰。
如果新增依赖、迁移或脚本，请同步更新 README.md 和 .env.example。
```

## 使用原则

- `.env` 不提交 Git
- `.env.example` 需要随配置变化同步更新
- 数据库结构变更必须通过 Alembic 迁移管理
- 中间件统一通过 Docker 管理
- 尽量保持统一脚本入口，不要让运行方式分散在多个地方

## 这个模板能证明什么

- 仓库不只支持最小后端模板，也支持带迁移能力的增强后端项目
- 用户可以通过统一脚本完成环境检查、初始化、迁移、启动和测试
- 适合作为“从 0 到更真实后端结构”的验证样例
