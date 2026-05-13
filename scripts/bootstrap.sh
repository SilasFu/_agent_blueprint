#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 加载共享函数库
source "$SCRIPT_DIR/lib.sh"

echo "=============================="
echo "  Vibe Coding 项目初始化"
echo "=============================="

# 如果在蓝图根目录，引导用户使用模板或 scaffold
if [[ ! -f "pyproject.toml" && ! -f "package.json" && -d "templates" ]]; then
  echo ""
  echo "[提示] 当前目录是蓝图框架根目录，不是具体项目。"
  echo ""
  echo "[方式一] 从模板创建项目（推荐，最快）："
  echo "  bash scripts/init-project.sh <模板名> <新项目目录>"
  echo "  可用模板："
  echo "    fastapi-postgres-redis          最小 FastAPI 后端"
  echo "    fastapi-postgres-redis-alembic  带 Alembic 迁移的增强后端"
  echo "    react-fastapi-postgres-redis    React + FastAPI 全栈"
  echo ""
  echo "[方式二] 基于 project-spec.yaml 生成项目骨架："
  echo "  1. cp project-spec.example.yaml project-spec.yaml"
  echo "  2. 编辑 project-spec.yaml 填写项目需求"
  echo "  3. bash scripts/scaffold.sh"
  echo ""
  echo "[方式三] 让 Agent 根据需求推荐技术栈并生成骨架。"
  echo ""
  exit 0
fi

# 步骤 1：环境检查
bash "$SCRIPT_DIR/check-env.sh"

echo ""
echo "=============================="
echo "  开始项目配置"
echo "=============================="

# 步骤 2：复制 .env（幂等：已存在时检查缺失项）
if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[完成] 已根据 .env.example 创建 .env 文件"
elif [[ -f ".env.example" && -f ".env" ]]; then
  # 检查 .env 中是否缺少 .env.example 里新增的配置项
  missing_vars=0
  while IFS='=' read -r key _; do
    key="$(echo "$key" | xargs)"  # 去除前后空白
    if [[ -n "$key" && "$key" != \#* ]]; then
      if ! grep -q "^${key}=" .env 2>/dev/null; then
        if [[ $missing_vars -eq 0 ]]; then
          echo "[检查] .env 中缺少 .env.example 中的配置项："
        fi
        echo "  - $key"
        missing_vars=$((missing_vars + 1))
      fi
    fi
  done < .env.example
  if [[ $missing_vars -gt 0 ]]; then
    echo "[提示] 请手动补齐 .env 中缺少的配置项，或重新从 .env.example 复制"
  else
    echo "[跳过] .env 已存在且配置项完整"
  fi
fi

# 步骤 3：Python 项目初始化
if [[ -f "pyproject.toml" ]]; then
  if [[ ! -d ".venv" ]]; then
    uv venv
    echo "[完成] 已创建 Python 虚拟环境 .venv"
  else
    echo "[跳过] Python 虚拟环境已存在（如需重建，先执行：make clean）"
  fi

  if [[ -f "uv.lock" ]]; then
    uv sync
    echo "[完成] 已根据 uv.lock 同步 Python 依赖"
  else
    uv sync 2>/dev/null || {
      echo "[提示] 检测到 pyproject.toml，但没有 uv.lock。"
      echo "[提示] 请按需补充依赖后执行：uv sync"
    }
  fi
fi

# 步骤 4：Node.js 项目初始化
if [[ -f "package.json" ]]; then
  if [[ ! -d "node_modules" ]]; then
    pnpm install
    echo "[完成] 已安装 Node.js 依赖"
  else
    echo "[跳过] Node.js 依赖已存在（如需重装，先执行：make clean）"
  fi
fi

# 步骤 5：Docker 基础服务（不再静默吞掉失败）
if [[ -f "compose.yaml" || -f "docker-compose.yml" ]]; then
  if start_docker_services; then
    echo "[完成] Docker 基础服务已启动"
  else
    echo ""
    echo "[警告] Docker 服务启动失败，但不影响其他初始化步骤。"
    echo "[修复] 你可以稍后手动启动："
    echo "  docker compose up -d"
  fi
else
  echo "[跳过] 未检测到 compose.yaml，跳过 Docker 服务启动"
fi

echo ""
echo "[完成] 项目初始化结束。"
echo "[下一步] 你现在可以优先尝试下面命令："
echo "  make dev"
echo "  make test"
echo ""
echo "[提示] 如果当前项目是模板生成的具体项目，也可以先查看 README.md 获取更详细的启动说明。"
