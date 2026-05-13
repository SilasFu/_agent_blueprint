#!/usr/bin/env bash
set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/lib.sh"

echo "=============================="
echo "  Vibe Coding 环境检查"
echo "=============================="

# 蓝图根目录需要的工具：必需 + 可选
run_env_check "git docker" "python3 uv node pnpm pyenv nvm"
