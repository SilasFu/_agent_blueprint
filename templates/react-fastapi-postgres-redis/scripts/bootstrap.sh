#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/check-env.sh"

echo "[初始化] 开始初始化全栈项目..."

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[完成] 已根据 .env.example 创建 .env 文件"
fi

if [[ ! -d "backend/.venv" ]]; then
  (cd backend && uv venv)
  echo "[完成] 已创建后端 Python 虚拟环境"
fi

(cd backend && source .venv/bin/activate && uv sync --all-groups)
(cd frontend && pnpm install)
docker compose up -d

echo "[完成] 已同步后端依赖"
echo "[完成] 已安装前端依赖"
echo "[完成] 已启动 PostgreSQL 和 Redis"
echo ""
echo "[完成] 项目初始化结束。"
echo "[下一步] 建议在两个终端分别执行："
echo "  make dev-backend"
echo "  make dev-frontend"
echo "  make test"
echo ""
echo "[访问地址] 前端：http://127.0.0.1:5173"
echo "[访问地址] 后端文档：http://127.0.0.1:8000/docs"
