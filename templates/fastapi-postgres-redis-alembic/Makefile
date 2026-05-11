.PHONY: check bootstrap dev test migrate lint

check:
	bash scripts/check-env.sh

bootstrap:
	bash scripts/bootstrap.sh

dev:
	bash scripts/dev.sh

test:
	bash scripts/test.sh

migrate:
	bash scripts/migrate.sh

lint:
	bash -lc "source .venv/bin/activate && uv run ruff check ."