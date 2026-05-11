#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d ".venv" ]]; then
  echo "[error] .venv not found, run 'make bootstrap' first"
  exit 1
fi

source .venv/bin/activate
uv run pytest