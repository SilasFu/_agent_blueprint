#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d ".venv" ]]; then
  echo "[error] .venv not found, run 'make bootstrap' first"
  exit 1
fi

source .venv/bin/activate
source .env 2>/dev/null || true

uv run alembic upgrade head
uv run uvicorn app.main:app --reload --host "${APP_HOST:-0.0.0.0}" --port "${APP_PORT:-8000}" --app-dir src