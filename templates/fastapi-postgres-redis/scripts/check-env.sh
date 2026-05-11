#!/usr/bin/env bash
set -euo pipefail

echo "[check] verifying required tools"

required_tools=(python uv docker git)
for tool in "${required_tools[@]}"; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "[error] missing required tool: $tool"
    exit 1
  fi
  echo "[ok] found $tool: $(command -v "$tool")"
done

echo "[check] versions"
python --version
uv --version
docker --version
docker compose version
git --version

echo "[done] environment check completed"