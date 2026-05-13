#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/lib.sh"

echo "=============================="
echo "  FastAPI + Alembic 模板环境检查"
echo "=============================="

# Alembic 模板必需：git docker python3 uv
run_env_check "git docker python3 uv" ""
