#!/usr/bin/env bash
set -euo pipefail

echo "[bootstrap] starting project bootstrap"

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[bootstrap] created .env from .env.example"
fi

if [[ -f "pyproject.toml" ]]; then
  if ! command -v uv >/dev/null 2>&1; then
    echo "[error] pyproject.toml found but uv is missing"
    exit 1
  fi
  if [[ ! -d ".venv" ]]; then
    uv venv
    echo "[bootstrap] created Python virtual environment"
  fi
  if [[ -f "uv.lock" ]]; then
    uv sync
    echo "[bootstrap] synced Python dependencies from uv.lock"
  else
    echo "[bootstrap] pyproject.toml found; add dependencies and run 'uv sync' if needed"
  fi
fi

if [[ -f "package.json" ]]; then
  if ! command -v pnpm >/dev/null 2>&1; then
    echo "[error] package.json found but pnpm is missing"
    exit 1
  fi
  pnpm install
  echo "[bootstrap] installed Node dependencies"
fi

if [[ -f "compose.yaml" || -f "docker-compose.yml" ]]; then
  if ! command -v docker >/dev/null 2>&1; then
    echo "[error] compose file found but docker is missing"
    exit 1
  fi
  docker compose up -d
  echo "[bootstrap] started Docker infrastructure"
fi

echo "[done] bootstrap completed"