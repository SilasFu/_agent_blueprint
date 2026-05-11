#!/usr/bin/env bash
set -euo pipefail

echo "[check] running environment checks"

required_tools=(git docker)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "[error] missing required tool: $tool"
    exit 1
  fi
  echo "[ok] found $tool: $(command -v "$tool")"
done

optional_tools=(python uv node pnpm pyenv nvm)
for tool in "${optional_tools[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    echo "[ok] found $tool: $(command -v "$tool")"
  else
    echo "[warn] optional tool not found yet: $tool"
  fi
done

echo "[check] versions"
command -v python >/dev/null 2>&1 && python --version || true
command -v uv >/dev/null 2>&1 && uv --version || true
command -v node >/dev/null 2>&1 && node -v || true
command -v pnpm >/dev/null 2>&1 && pnpm -v || true
command -v docker >/dev/null 2>&1 && docker --version || true
command -v docker >/dev/null 2>&1 && docker compose version || true

echo "[done] environment check completed"