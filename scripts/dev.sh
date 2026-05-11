#!/usr/bin/env bash
set -euo pipefail

echo "[dev] starting development mode"

if [[ -f "Makefile" ]] && grep -q '^dev:' Makefile; then
  echo "[dev] using Makefile as the unified interface is recommended"
fi

if [[ -f "pyproject.toml" && -d ".venv" ]]; then
  echo "[dev] Python project detected"
  echo "[hint] activate environment with: source .venv/bin/activate"
  echo "[hint] then run your framework entrypoint, for example: uv run uvicorn src.app.main:app --reload"
  exit 0
fi

if [[ -f "package.json" ]]; then
  echo "[dev] Node project detected"
  if command -v pnpm >/dev/null 2>&1; then
    echo "[hint] run: pnpm dev"
  else
    echo "[warn] pnpm not found"
  fi
  exit 0
fi

echo "[warn] no application runtime detected yet"
echo "[hint] ask the Agent to generate the project skeleton from project-spec.yaml"