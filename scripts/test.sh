#!/usr/bin/env bash
set -euo pipefail

echo "[测试] 正在尝试运行项目测试..."

ran_any=false

if [[ -f "pyproject.toml" ]] && command -v pytest >/dev/null 2>&1; then
  pytest
  ran_any=true
fi

if [[ -f "package.json" ]] && command -v pnpm >/dev/null 2>&1; then
  if pnpm run | grep -q ' test'; then
    pnpm test
    ran_any=true
  fi
fi

if [[ "$ran_any" == "false" ]]; then
  echo "[警告] 当前没有识别到可直接运行的测试命令。"
  echo "[提示] 可以让 Agent 按所选技术栈补齐最小测试体系。"
fi