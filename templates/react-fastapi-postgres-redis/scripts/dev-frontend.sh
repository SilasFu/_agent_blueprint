#!/usr/bin/env bash
set -euo pipefail

cd frontend
source ../.env 2>/dev/null || true

echo "[开发] 正在启动前端开发服务..."
pnpm dev --host 0.0.0.0 --port "${FRONTEND_PORT:-5173}"