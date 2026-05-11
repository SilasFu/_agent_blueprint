#!/usr/bin/env bash
set -euo pipefail

echo "[开发] 正在识别当前项目的启动方式..."

if [[ -f "Makefile" ]] && grep -q '^dev:' Makefile; then
  echo "[提示] 推荐优先使用 Makefile 统一入口：make dev"
fi

if [[ -f "pyproject.toml" && -d ".venv" ]]; then
  echo "[识别] 当前是 Python 项目"
  echo "[提示] 先执行：source .venv/bin/activate"
  echo "[提示] 再启动你的框架入口，例如：uv run uvicorn src.app.main:app --reload"
  exit 0
fi

if [[ -f "package.json" ]]; then
  echo "[识别] 当前是 Node.js 项目"
  if command -v pnpm >/dev/null 2>&1; then
    echo "[提示] 可直接执行：pnpm dev"
  else
    echo "[警告] 尚未检测到 pnpm，请先运行环境检查脚本。"
  fi
  exit 0
fi

echo "[警告] 暂未识别到可直接启动的应用结构。"
echo "[提示] 可以让 Agent 根据 project-spec.yaml 生成项目骨架。"