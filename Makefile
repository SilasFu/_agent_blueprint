.PHONY: check bootstrap dev test

check:
	bash scripts/check-env.sh

bootstrap:
	bash scripts/bootstrap.sh

dev:
	bash scripts/dev.sh

test:
	bash scripts/test.sh
