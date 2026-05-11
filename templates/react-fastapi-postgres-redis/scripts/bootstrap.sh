#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] starting fullstack bootstrap"

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[bootstrap] created .env from .env.example"
fi

if [[ ! -d "backend/.venv" ]]; then
  (cd backend && uv venv)
  echo "[bootstrap] created backend virtual environment"
fi

(cd backend && source .venv/bin/activate && uv sync --all-groups)
(cd frontend && pnpm install)
docker compose up -d

echo "[done] bootstrap completed"