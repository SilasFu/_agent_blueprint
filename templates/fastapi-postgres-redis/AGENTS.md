# FastAPI 模板协作规则

本文件用于指导 Agent CLI 在当前模板基础上继续扩展，而不是重写整个技术栈。

当前模板默认使用 `scripts/bootstrap.sh` 作为新手主入口。

如果用户只想单独检查环境，再使用 `scripts/check-env.sh`。

## 1. 当前固定技术栈

除非用户明确要求变更，否则默认保持以下技术栈：

- Python `3.12.9`
- FastAPI
- Uvicorn
- PostgreSQL
- Redis
- `uv` 管理依赖
- `pytest` 做测试
- Docker Compose 管理本地基础设施

## 2. 目录和代码约定

- Python 代码放在 `src/app`
- 测试放在 `tests`
- 配置集中在 `src/app/config.py`
- 新增业务时，优先保持模块边界清晰
- 优先增加小而明确的路由、服务和测试

## 3. 环境与依赖约定

- 使用 `.python-version` 固定 Python 版本
- 使用 `pyproject.toml` 作为 Python 项目配置入口
- 使用 `uv sync` 安装依赖
- 使用 `.env.example` 描述所需环境变量
- `.env` 只用于本地开发，不应提交 Git

## 4. 基础设施约定

- PostgreSQL 和 Redis 统一通过 `compose.yaml` 启动
- 默认连接配置从 `.env` 读取
- 如果新增服务，要同步更新 `compose.yaml`、`.env.example` 和 `README.md`

## 5. 修改优先级

当用户提出新需求时，优先按下面顺序工作：

1. 阅读 `README.md`
2. 阅读 `pyproject.toml`
3. 阅读 `.env.example`
4. 阅读 `compose.yaml`
5. 阅读 `scripts` 目录
6. 阅读 `src/app` 和 `tests`

如果用户准备初始化项目，应优先建议执行：

1. `make bootstrap`
2. `make dev`
3. `make test`

## 6. 输出要求

每次完成修改后，你应明确告诉用户：

- 修改了哪些文件
- 为什么这样设计
- 如何运行
- 是否需要补充环境变量、数据库迁移或外部服务配置

## 7. 长期原则

- 优先保留当前技术栈一致性
- 优先保持模板可读、可维护、可扩展
- 不为了“看起来更高级”而过度设计
- 新增内容时同步补 README、脚本和测试
