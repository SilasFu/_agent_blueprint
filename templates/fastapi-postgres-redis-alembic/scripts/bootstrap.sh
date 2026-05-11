#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] starting bootstrap"

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[bootstrap] created .env from .env.example"
fi

if [[ ! -d ".venv" ]]; then
  uv venv
  echo "[bootstrap] created Python virtual environment"
fi

source .venv/bin/activate
uv sync --all-groups

echo "[bootstrap] synced Python dependencies"

docker compose up -d

echo "[bootstrap] started PostgreSQL and Redis"

bash scripts/migrate.sh

echo "[done] bootstrap completed"