#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d "backend/.venv" ]]; then
  echo "[错误] 没有找到 backend/.venv，请先执行 make bootstrap"
  exit 1
fi

echo "[测试] 正在运行后端 pytest..."
(cd backend && source .venv/bin/activate && uv run pytest)