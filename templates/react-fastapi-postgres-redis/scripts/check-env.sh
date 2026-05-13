#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/lib.sh"

echo "=============================="
echo "  React + FastAPI 全栈模板环境检查"
echo "=============================="

# 全栈模板必需：git docker python3 uv node pnpm
run_env_check "git docker python3 uv node pnpm" ""
