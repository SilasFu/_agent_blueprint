#!/usr/bin/env bash
set -euo pipefail

if [[ ! -d ".venv" ]]; then
  echo "[错误] 没有找到 .venv，请先执行 make bootstrap"
  exit 1
fi

source .venv/bin/activate

echo "[测试] 正在运行 pytest..."
uv run pytest