#!/usr/bin/env bash
set -euo pipefail

cd backend

if [[ ! -d ".venv" ]]; then
  echo "[错误] 没有找到 backend/.venv，请先执行 make bootstrap"
  exit 1
fi

source .venv/bin/activate
source ../.env 2>/dev/null || true

echo "[开发] 正在启动后端 FastAPI 服务..."
uv run uvicorn app.main:app --reload --host "${BACKEND_HOST:-0.0.0.0}" --port "${BACKEND_PORT:-8000}" --app-dir src