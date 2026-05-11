#!/usr/bin/env bash
set -euo pipefail

cd backend
source .venv/bin/activate
source ../.env 2>/dev/null || true

uv run uvicorn app.main:app --reload --host "${BACKEND_HOST:-0.0.0.0}" --port "${BACKEND_PORT:-8000}" --app-dir src