# FastAPI + Alembic 模板协作规则

本文件用于指导 Agent CLI 在当前增强模板基础上继续扩展，而不是重写项目基础设施或随意替换技术栈。

当前模板默认使用 `scripts/bootstrap.sh` 作为新手主入口。

如果用户只想单独检查环境，再使用 `scripts/check-env.sh`。

## 1. 当前固定技术栈

除非用户明确要求变更，否则默认保持以下技术栈：

- Python `3.12.9`
- FastAPI
- SQLAlchemy 2.x
- Alembic
- PostgreSQL
- Redis
- `uv` 管理依赖
- `pytest` 做测试
- Docker Compose 管理本地基础设施

## 2. 结构约定

- Python 代码放在 `src/app`
- 数据库配置与会话放在 `src/app/db.py`
- SQLAlchemy 模型放在 `src/app/models.py`
- Pydantic schema 放在 `src/app/schemas.py`
- 数据访问辅助逻辑放在 `src/app/crud.py`
- 密码处理等安全辅助逻辑放在 `src/app/security.py`
- Alembic 配置在 `alembic.ini` 与 `alembic/`
- 测试放在 `tests/`

## 3. 数据库变更规则

- 涉及表结构调整时，优先通过 Alembic 迁移管理
- 不要只改模型而不补迁移
- 如果修改了模型、迁移或数据库连接配置，要同步更新 `README.md`、`.env.example` 和相关脚本
- 当前模板已经内置 `User` 标准模块，后续扩展认证或权限时应优先在现有结构上演进

## 4. 依赖与运行约定

- Python 版本由 `.python-version` 指定
- 依赖由 `pyproject.toml` 和 `uv` 管理
- 初始化优先执行 `make bootstrap`
- 本地运行优先执行 `make dev`
- 测试优先执行 `make test`
- 手动迁移优先执行 `make migrate`

## 5. 输出要求

每次完成修改后，你应明确告诉用户：

- 修改了哪些文件
- 为什么这样设计
- 是否新增或修改了数据库迁移
- 如何运行和验证
- 是否还需要补充环境变量、密钥或外部服务配置

## 6. 长期原则

- 优先保留模板一致性
- 优先保持数据库结构可迁移、可恢复、可审查
- 优先保持 API 层、配置层、数据层边界清晰
- 不为了炫技而过度设计
