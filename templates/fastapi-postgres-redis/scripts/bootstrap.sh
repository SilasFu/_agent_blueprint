#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/lib.sh"

bash "$SCRIPT_DIR/check-env.sh"

echo "[初始化] 开始初始化 FastAPI 项目..."

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[完成] 已根据 .env.example 创建 .env 文件"
fi

if [[ ! -d ".venv" ]]; then
  uv venv
  echo "[完成] 已创建 Python 虚拟环境 .venv"
fi

source .venv/bin/activate
uv sync --all-groups
echo "[完成] 已同步 Python 依赖"

# 使用 lib.sh 的 start_docker_services（含 Docker daemon 检测和端口冲突检测）
start_docker_services || true

echo ""
echo "[完成] 项目初始化结束。"
echo "[下一步] 你现在可以执行："
echo "  make dev"
echo "  make test"
echo ""
echo "[访问地址] FastAPI 文档：http://127.0.0.1:8000/docs"
echo "[访问地址] 健康检查：http://127.0.0.1:8000/health"
