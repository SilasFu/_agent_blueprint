#!/usr/bin/env bash
set -euo pipefail

echo "[开发] 正在识别当前项目的启动方式..."

# 判断是否在蓝图根目录
if [[ ! -f "pyproject.toml" && ! -f "package.json" && -d "templates" ]]; then
  echo ""
  echo "[提示] 当前目录是蓝图框架根目录，不是具体项目。"
  echo "[提示] 要开始开发，请先从模板创建项目："
  echo "  bash scripts/init-project.sh <模板名> <新项目目录>"
  echo ""
  echo "[提示] 可用模板："
  echo "  fastapi-postgres-redis          最小 FastAPI 后端"
  echo "  fastapi-postgres-redis-alembic  带 Alembic 迁移的增强后端"
  echo "  react-fastapi-postgres-redis    React + FastAPI 全栈"
  echo ""
  echo "[提示] 或者让 Agent 基于 project-spec.yaml 推荐技术栈并生成骨架。"
  exit 0
fi

if [[ -f "Makefile" ]] && grep -q '^dev:' Makefile; then
  echo "[提示] 推荐优先使用 Makefile 统一入口：make dev"
fi

# Python 项目
if [[ -f "pyproject.toml" && -d ".venv" ]]; then
  echo "[识别] 当前是 Python 项目"
  echo "[提示] 先执行：source .venv/bin/activate"
  echo "[提示] 再启动你的框架入口，例如：uv run uvicorn src.app.main:app --reload"
  exit 0
fi

if [[ -f "pyproject.toml" && ! -d ".venv" ]]; then
  echo "[识别] 当前是 Python 项目，但虚拟环境尚未创建"
  echo "[提示] 请先运行：make bootstrap"
  exit 0
fi

# Node.js 项目
if [[ -f "package.json" ]]; then
  echo "[识别] 当前是 Node.js 项目"
  if command -v pnpm >/dev/null 2>&1; then
    echo "[提示] 可直接执行：pnpm dev"
  else
    echo "[警告] 尚未检测到 pnpm，请先运行环境检查脚本。"
  fi
  exit 0
fi

# 全栈项目（前后端分离）
if [[ -d "backend" && -d "frontend" ]]; then
  echo "[识别] 当前可能是前后端分离项目"
  echo "[提示] 后端：cd backend && source .venv/bin/activate && uvicorn src.app.main:app --reload"
  echo "[提示] 前端：cd frontend && pnpm dev"
  exit 0
fi

echo "[提示] 暂未识别到可直接启动的应用结构。"
echo "[提示] 可以让 Agent 根据 project-spec.yaml 生成项目骨架。"
