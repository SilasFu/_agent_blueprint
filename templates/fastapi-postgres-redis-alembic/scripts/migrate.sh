#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d ".venv" ]]; then
  echo "[错误] 没有找到 .venv，请先执行 make bootstrap"
  exit 1
fi

source .venv/bin/activate
source .env 2>/dev/null || true

echo "[迁移] 正在执行 Alembic 数据库迁移..."
uv run alembic upgrade head