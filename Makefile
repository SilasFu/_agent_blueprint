.PHONY: check bootstrap dev test init-project setup validate scaffold sync-lib lint smoke-test

check:
	bash scripts/check-env.sh

bootstrap:
	bash scripts/bootstrap.sh

dev:
	bash scripts/dev.sh

test:
	bash scripts/test.sh

init-project:
	@echo "用法：bash scripts/init-project.sh <模板名> <目标目录> [项目名]"
	@echo ""
	@echo "可用模板："
	@echo "  fastapi-postgres-redis          最小 FastAPI 后端"
	@echo "  fastapi-postgres-redis-alembic  带 Alembic 迁移的增强后端"
	@echo "  react-fastapi-postgres-redis    React + FastAPI 全栈"
	@echo ""
	@echo "示例："
	@echo "  bash scripts/init-project.sh fastapi-postgres-redis ~/workspace/my-api my-api"

setup:
	bash scripts/setup.sh

scaffold:
	bash scripts/scaffold.sh

validate:
	bash scripts/validate-spec.sh

sync-lib:
	bash scripts/sync-lib.sh

lint:
	bash scripts/lint.sh

smoke-test:
	bash scripts/smoke-test.sh
