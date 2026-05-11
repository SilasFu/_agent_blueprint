#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d ".venv" ]]; then
  echo "[错误] 没有找到 .venv，请先执行 make bootstrap"
  exit 1
fi

source .venv/bin/activate
source .env 2>/dev/null || true

echo "[开发] 正在启动 FastAPI 开发服务..."
uv run uvicorn app.main:app --reload --host "${APP_HOST:-0.0.0.0}" --port "${APP_PORT:-8000}" --app-dir src