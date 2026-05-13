#!/usr/bin/env bash
set -euo pipefail

echo "[测试] 正在尝试运行项目测试..."

# 判断是否在蓝图根目录
if [[ ! -f "pyproject.toml" && ! -f "package.json" && -d "templates" ]]; then
  echo ""
  echo "[提示] 当前目录是蓝图框架根目录，不是具体项目。"
  echo "[提示] 项目测试需要在具体项目目录中运行。"
  echo "[提示] 请先从模板创建项目：bash scripts/init-project.sh <模板名> <目录>"
  exit 0
fi

ran_any=false

# Python 测试
if [[ -f "pyproject.toml" ]]; then
  if command -v pytest >/dev/null 2>&1; then
    pytest
    ran_any=true
  elif [[ -d ".venv" ]]; then
    echo "[提示] 检测到 Python 项目，但 pytest 不可用。"
    echo "[提示] 请先激活虚拟环境：source .venv/bin/activate"
    echo "[提示] 然后安装测试依赖：uv add --dev pytest"
  fi
fi

# Node.js 测试
if [[ -f "package.json" ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    if pnpm run 2>/dev/null | grep -q ' test'; then
      pnpm test
      ran_any=true
    fi
  else
    echo "[提示] 检测到 Node.js 项目，但 pnpm 不可用。"
    echo "[提示] 请先运行环境检查：make check"
  fi
fi

if [[ "$ran_any" == "false" ]]; then
  echo "[提示] 当前没有识别到可直接运行的测试命令。"
  echo "[提示] 可以让 Agent 按所选技术栈补齐最小测试体系。"
fi
