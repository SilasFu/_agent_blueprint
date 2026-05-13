#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/lib.sh"

bash "$SCRIPT_DIR/check-env.sh"

echo "[初始化] 开始初始化 React + FastAPI 全栈项目..."

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[完成] 已根据 .env.example 创建 .env 文件"
fi

# 后端初始化
if [[ -d "backend" ]]; then
  cd backend

  if [[ ! -d ".venv" ]]; then
    uv venv
    echo "[完成] 已创建后端 Python 虚拟环境"
  fi

  source .venv/bin/activate
  uv sync --all-groups
  echo "[完成] 已同步后端 Python 依赖"

  cd ..
fi

# 前端初始化
if [[ -d "frontend" ]]; then
  cd frontend
  pnpm install
  echo "[完成] 已安装前端 Node.js 依赖"
  cd ..
fi

# 使用 lib.sh 的 start_docker_services（含 Docker daemon 检测和端口冲突检测）
start_docker_services || true

echo ""
echo "[完成] 项目初始化结束。"
echo "[下一步] 你现在可以执行："
echo "  make dev"
echo "  make test"
echo ""
echo "[访问地址] 前端页面：http://localhost:5173"
echo "[访问地址] 后端文档：http://127.0.0.1:8000/docs"
echo "[访问地址] 健康检查：http://127.0.0.1:8000/health"
