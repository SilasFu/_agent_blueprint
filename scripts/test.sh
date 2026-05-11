#!/usr/bin/env bash
set -euo pipefail

echo "[test] running project tests"

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
  echo "[warn] no runnable test command detected"
  echo "[hint] ask the Agent to add the appropriate test setup for the selected stack"
fi