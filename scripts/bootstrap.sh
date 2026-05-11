#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/check-env.sh"

echo "=============================="
echo "  Vibe Coding 项目初始化"
echo "=============================="

if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[完成] 已根据 .env.example 创建 .env 文件"
fi

if [[ -f "pyproject.toml" ]]; then
  if [[ ! -d ".venv" ]]; then
    uv venv
    echo "[完成] 已创建 Python 虚拟环境 .venv"
  fi

  if [[ -f "uv.lock" ]]; then
    uv sync
    echo "[完成] 已根据 uv.lock 同步 Python 依赖"
  else
    echo "[提示] 检测到 pyproject.toml，但没有 uv.lock。"
    echo "[提示] 请按需补充依赖后执行：uv sync"
  fi
fi

if [[ -f "package.json" ]]; then
  pnpm install
  echo "[完成] 已安装 Node.js 依赖"
fi

if [[ -f "compose.yaml" || -f "docker-compose.yml" ]]; then
  docker compose up -d
  echo "[完成] 已启动 Docker 基础服务"
fi

echo ""
echo "[完成] 项目初始化结束。"
echo "[下一步] 你现在可以优先尝试下面命令："
echo "  make dev"
echo "  make test"
echo ""
echo "[提示] 如果当前项目是模板生成的具体项目，也可以先查看 README.md 获取更详细的启动说明。"
