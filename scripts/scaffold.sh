#!/usr/bin/env bash
set -euo pipefail

# ── 基于 project-spec.yaml 生成项目骨架 ──
# 用法：bash scripts/scaffold.sh [spec_file] [target_dir]
# 如果不指定参数，默认读取当前目录的 project-spec.yaml
# 并在 ../<project_name> 生成项目

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SPEC_FILE="${1:-project-spec.yaml}"
TARGET_DIR="${2:-}"

# ── 前置检查 ──

if ! command -v python3 >/dev/null 2>&1; then
  echo "[错误] 需要 python3 来解析 project-spec.yaml"
  echo "[提示] 请先安装 python3，或运行：make check"
  exit 1
fi

if [[ ! -f "$SPEC_FILE" ]]; then
  echo "[错误] 文件不存在：$SPEC_FILE"
  echo "[提示] 请先复制模板：cp project-spec.example.yaml project-spec.yaml"
  echo "[提示] 然后编辑 project-spec.yaml 填写你的项目需求"
  exit 1
fi

# 检查 PyYAML 是否可用
if ! python3 -c "import yaml" 2>/dev/null; then
  echo "[提示] 正在安装 PyYAML（项目生成需要）..."
  pip3 install pyyaml --quiet 2>/dev/null || pip install pyyaml --quiet 2>/dev/null || {
    echo "[错误] 无法安装 PyYAML，请手动安装：pip install pyyaml"
    exit 1
  }
fi

# ── 解析 project-spec.yaml ──

echo "=============================="
echo "  基于 project-spec.yaml 生成项目"
echo "=============================="
echo ""

read_spec() {
  local key="$1"
  python3 -c "
import yaml, sys
data = yaml.safe_load(open('$SPEC_FILE'))
keys = '$key'.split('.')
obj = data
for k in keys:
    if isinstance(obj, dict) and k in obj:
        obj = obj[k]
    else:
        sys.exit(1)
print(obj)
"
}

read_spec_default() {
  local key="$1"
  local default="${2:-}"
  result=$(read_spec "$key" 2>/dev/null) && echo "$result" || echo "$default"
}

# 读取核心字段
PROJECT_NAME=$(read_spec "project.name" 2>/dev/null) || {
  echo "[错误] project-spec.yaml 中缺少必填字段：project.name"
  exit 1
}

PROJECT_TYPE=$(read_spec_default "project.type" "web_app")
PROJECT_STAGE=$(read_spec_default "project.stage" "mvp")
BACKEND_LANG=$(read_spec_default "preferences.backend.preferred" "python")
BACKEND_FRAMEWORK=$(read_spec_default "preferences.backend.framework" "fastapi")
FRONTEND_PREF=$(read_spec_default "preferences.frontend.preferred" "none")
FRONTEND_BUNDLER=$(read_spec_default "preferences.frontend.bundler" "vite")
DATABASE_PREF=$(read_spec_default "preferences.database.preferred" "postgresql")
CACHE_PREF=$(read_spec_default "preferences.cache.preferred" "redis")
PYTHON_VERSION=$(read_spec_default "preferences.python.version" "3.12")
PYTHON_PM=$(read_spec_default "preferences.python.package_manager" "uv")
NODE_VERSION=$(read_spec_default "preferences.node.version" "lts")
NODE_PM=$(read_spec_default "preferences.node.package_manager" "pnpm")
DEPLOY_TARGET=$(read_spec_default "constraints.deployment.target" "vps")
USE_DOCKER=$(read_spec_default "environment.use_docker_for_infra" "true")

# 验证项目名格式
if ! echo "$PROJECT_NAME" | grep -qE '^[a-z][a-z0-9_-]*$'; then
  echo "[错误] 项目名格式不合法：$PROJECT_NAME"
  echo "[提示] 只能包含小写字母、数字、连字符和下划线，且以小写字母开头"
  exit 1
fi

# 确定目标目录
if [[ -z "$TARGET_DIR" ]]; then
  TARGET_DIR="$BLUEPRINT_ROOT/../$PROJECT_NAME"
fi

if [[ -d "$TARGET_DIR" && "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  echo "[错误] 目标目录已存在且不为空：$TARGET_DIR"
  echo "[提示] 请指定一个空目录或新目录名。"
  exit 1
fi

# ── 确定项目模板策略 ──

NEEDS_FRONTEND=false
NEEDS_DATABASE=false
NEEDS_CACHE=false
NEEDS_MIGRATION=false

if [[ "$FRONTEND_PREF" != "none" ]]; then
  NEEDS_FRONTEND=true
fi

if [[ "$DATABASE_PREF" != "none" ]]; then
  NEEDS_DATABASE=true
fi

if [[ "$CACHE_PREF" != "none" ]]; then
  NEEDS_CACHE=true
fi

# 判断是否可匹配已有模板
MATCHED_TEMPLATE=""

if [[ "$BACKEND_LANG" == "python" && "$BACKEND_FRAMEWORK" == "fastapi" ]]; then
  if [[ "$NEEDS_FRONTEND" == true && "$FRONTEND_PREF" == "react" ]]; then
    MATCHED_TEMPLATE="react-fastapi-postgres-redis"
  elif [[ "$NEEDS_DATABASE" == true && "$DATABASE_PREF" == "postgresql" ]]; then
    # 判断是否需要迁移管理（stage=production 或显式需求暗示更复杂项目）
    if [[ "$PROJECT_STAGE" == "production" ]]; then
      MATCHED_TEMPLATE="fastapi-postgres-redis-alembic"
    else
      MATCHED_TEMPLATE="fastapi-postgres-redis"
    fi
  fi
fi

# ── 生成项目 ──

echo "[信息] 项目名称：$PROJECT_NAME"
echo "[信息] 项目类型：$PROJECT_TYPE"
echo "[信息] 后端技术：$BACKEND_LANG / $BACKEND_FRAMEWORK"
echo "[信息] 前端技术：$FRONTEND_PREF / $FRONTEND_BUNDLER"
echo "[信息] 数据库：$DATABASE_PREF"
echo "[信息] 缓存：$CACHE_PREF"
echo "[信息] 目标目录：$TARGET_DIR"
echo ""

if [[ -n "$MATCHED_TEMPLATE" ]]; then
  echo "[匹配] 项目需求匹配已有模板：$MATCHED_TEMPLATE"
  echo "[匹配] 将使用模板创建并替换占位符"
  echo ""
  # 委托给 init-project.sh
  bash "$SCRIPT_DIR/init-project.sh" "$MATCHED_TEMPLATE" "$TARGET_DIR" "$PROJECT_NAME"
  echo ""
  echo "[提示] 模板项目已创建，你可以根据 project-spec.yaml 中的需求继续扩展"
  echo "[提示] 建议把 project-spec.yaml 复制到新项目目录中作为需求参考"
  exit 0
fi

echo "[生成] 未匹配到已有模板，将基于 project-spec.yaml 规则生成最小骨架"
echo ""

mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

# ── 生成 .gitignore ──

cat > .gitignore << 'GITIGNORE'
# 环境与密钥
.env
.env.*.local

# Python
.venv/
__pycache__/
*.pyc
*.pyo
*.egg-info/
*.whl
.pytest_cache/
.mypy_cache/
.ruff_cache/
.pyright/

# Node
node_modules/
dist/
build/
.vite/

# 覆盖率
coverage/
htmlcov/

# 日志
*.log

# IDE
.idea/
.vscode/
*.swp
*.swo

# 操作系统
.DS_Store
Thumbs.db
desktop.ini

# Docker 数据
docker-data/
GITIGNORE

# ── 生成 .env.example ──

DB_USER="${PROJECT_NAME}"
DB_NAME="${PROJECT_NAME}_db"
DB_PASSWORD="change_me_in_production"

cat > .env.example << ENVEOF
# ── 应用配置 ──
APP_NAME=${PROJECT_NAME}
APP_ENV=development
APP_HOST=0.0.0.0
APP_PORT=8000

# ── PostgreSQL ──
POSTGRES_HOST=127.0.0.1
POSTGRES_PORT=5432
POSTGRES_DB=${DB_NAME}
POSTGRES_USER=${DB_USER}
POSTGRES_PASSWORD=${DB_PASSWORD}

# ── Redis ──
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_DB=0

# ── Docker Compose ──
COMPOSE_PROJECT_NAME=${PROJECT_NAME}

# ── AI Provider Keys（留空表示不启用）──
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
ENVEOF

# ── 生成 compose.yaml ──

COMPOSE_SERVICES=""
COMPOSE_VOLUMES=""

if [[ "$NEEDS_DATABASE" == true && "$DATABASE_PREF" == "postgresql" ]]; then
  COMPOSE_SERVICES+="
  postgres:
    image: postgres:16
    container_name: \${COMPOSE_PROJECT_NAME:-${PROJECT_NAME}}-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: \${POSTGRES_USER:-${DB_USER}}
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD:-change_me_in_production}
      POSTGRES_DB: \${POSTGRES_DB:-${DB_NAME}}
    ports:
      - \"\${POSTGRES_PORT:-5432}:5432\"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: [\"CMD-SHELL\", \"pg_isready -U \${POSTGRES_USER:-${DB_USER}} -d \${POSTGRES_DB:-${DB_NAME}}\"]
      interval: 10s
      timeout: 5s
      retries: 5
"
  COMPOSE_VOLUMES+="  postgres_data:
"
fi

if [[ "$NEEDS_DATABASE" == true && "$DATABASE_PREF" == "mysql" ]]; then
  COMPOSE_SERVICES+="
  mysql:
    image: mysql:8
    container_name: \${COMPOSE_PROJECT_NAME:-${PROJECT_NAME}}-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD:-change_me_in_production}
      MYSQL_DATABASE: \${MYSQL_DATABASE:-${DB_NAME}}
      MYSQL_USER: \${MYSQL_USER:-${DB_USER}}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD:-change_me_in_production}
    ports:
      - \"\${MYSQL_PORT:-3306}:3306\"
    volumes:
      - mysql_data:/var/lib/mysql
"
  COMPOSE_VOLUMES+="  mysql_data:
"
fi

if [[ "$NEEDS_CACHE" == true && "$CACHE_PREF" == "redis" ]]; then
  COMPOSE_SERVICES+="
  redis:
    image: redis:7
    container_name: \${COMPOSE_PROJECT_NAME:-${PROJECT_NAME}}-redis
    restart: unless-stopped
    ports:
      - \"\${REDIS_PORT:-6379}:6379\"
    volumes:
      - redis_data:/data
    healthcheck:
      test: [\"CMD\", \"redis-cli\", \"ping\"]
      interval: 10s
      timeout: 5s
      retries: 5
"
  COMPOSE_VOLUMES+="  redis_data:
"
fi

if [[ "$NEEDS_DATABASE" == true || "$NEEDS_CACHE" == true ]]; then
  cat > compose.yaml << COMPOSEEOF
services:${COMPOSE_SERVICES}

volumes:
${COMPOSE_VOLUMES}
COMPOSEEOF
fi

# ── 生成 Makefile ──

cat > Makefile << 'MAKEFILE'
.PHONY: check bootstrap dev test lint clean

check:
	bash scripts/check-env.sh

bootstrap:
	bash scripts/bootstrap.sh

dev:
	bash scripts/dev.sh

test:
	bash scripts/test.sh

clean:
	rm -rf .venv __pycache__ .pytest_cache .mypy_cache .ruff_cache
	rm -rf node_modules dist build .vite
MAKEFILE

# ── 生成 scripts/ ──

mkdir -p scripts

# 复制共享函数库
cp "$BLUEPRINT_ROOT/scripts/lib.sh" scripts/lib.sh

# bootstrap.sh
cat > scripts/bootstrap.sh << 'BOOTSTRAP'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

echo "=============================="
echo "  项目初始化"
echo "=============================="

# 步骤 1：环境检查
bash "$SCRIPT_DIR/check-env.sh"

echo ""
echo "=============================="
echo "  开始项目配置"
echo "=============================="

# 步骤 2：复制 .env
if [[ -f ".env.example" && ! -f ".env" ]]; then
  cp .env.example .env
  echo "[完成] 已根据 .env.example 创建 .env 文件"
elif [[ -f ".env.example" && -f ".env" ]]; then
  # 检查 .env 是否缺少 .env.example 中的新增项
  missing_vars=0
  while IFS='=' read -r key _; do
    if [[ -n "$key" && "$key" != \#* ]]; then
      if ! grep -q "^${key}=" .env; then
        echo "[警告] .env 中缺少配置项：$key（.env.example 中已定义）"
        missing_vars=$((missing_vars + 1))
      fi
    fi
  done < .env.example
  if [[ $missing_vars -gt 0 ]]; then
    echo "[提示] 请手动补齐 .env 中缺少的配置项，或重新从 .env.example 复制"
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
    uv sync 2>/dev/null || echo "[提示] 检测到 pyproject.toml，请按需补充依赖后执行：uv sync"
  fi
fi

# 步骤 4：Node.js 项目初始化
if [[ -f "package.json" ]]; then
  pnpm install
  echo "[完成] 已安装 Node.js 依赖"
fi

# 步骤 5：Docker 基础服务
if [[ -f "compose.yaml" ]]; then
  start_docker_services || {
    echo "[警告] Docker 服务未启动成功，但不影响其他初始化步骤。"
    echo "[提示] 你可以稍后手动启动：docker compose up -d"
  }
fi

echo ""
echo "[完成] 项目初始化结束。"
echo "[下一步] 你现在可以优先尝试："
echo "  make dev"
echo "  make test"
BOOTSTRAP

# check-env.sh
cat > scripts/check-env.sh << 'CHECKENV'
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

echo "=============================="
echo "  环境检查"
echo "=============================="

# 根据项目类型动态确定需要检查的工具
REQUIRED="git docker"
OPTIONAL="python3 uv node pnpm"

if [[ -f "package.json" ]]; then
  REQUIRED="git docker node pnpm"
  OPTIONAL="python3 uv"
fi

run_env_check "$REQUIRED" "$OPTIONAL"
CHECKENV

# dev.sh
cat > scripts/dev.sh << 'DEVSH'
#!/usr/bin/env bash
set -euo pipefail

echo "[开发] 正在识别当前项目的启动方式..."

# Python 项目
if [[ -f "pyproject.toml" && -d ".venv" ]]; then
  echo "[识别] 当前是 Python 项目"
  echo "[提示] 先执行：source .venv/bin/activate"
  echo "[提示] 再启动：uv run uvicorn src.app.main:app --reload"
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
    echo "[警告] 尚未检测到 pnpm，请先运行环境检查。"
  fi
  exit 0
fi

# 全栈项目
if [[ -d "backend" && -d "frontend" ]]; then
  echo "[识别] 当前是前后端分离项目"
  echo "[提示] 后端：cd backend && source .venv/bin/activate && uvicorn src.app.main:app --reload"
  echo "[提示] 前端：cd frontend && pnpm dev"
  exit 0
fi

echo "[提示] 暂未识别到可直接启动的应用结构。"
DEVSH

# test.sh
cat > scripts/test.sh << 'TESTSH'
#!/usr/bin/env bash
set -euo pipefail

echo "[测试] 正在尝试运行项目测试..."

ran_any=false

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

if [[ -f "package.json" ]]; then
  if command -v pnpm >/dev/null 2>&1; then
    if pnpm run 2>/dev/null | grep -q ' test'; then
      pnpm test
      ran_any=true
    fi
  else
    echo "[提示] 检测到 Node.js 项目，但 pnpm 不可用。"
  fi
fi

if [[ "$ran_any" == "false" ]]; then
  echo "[提示] 当前没有识别到可直接运行的测试命令。"
fi
TESTSH

chmod +x scripts/bootstrap.sh scripts/check-env.sh scripts/dev.sh scripts/test.sh

# ── 根据 backend 语言生成骨架 ──

if [[ "$BACKEND_LANG" == "python" ]]; then
  # Python 项目骨架
  echo "$PYTHON_VERSION" > .python-version

  cat > pyproject.toml << PYPROJECT
[project]
name = "${PROJECT_NAME}"
version = "0.1.0"
description = "Generated from project-spec.yaml"
readme = "README.md"
requires-python = ">=${PYTHON_VERSION}"
dependencies = [
  "fastapi>=0.115.0",
  "uvicorn[standard]>=0.30.0",
  "pydantic-settings>=2.4.0",
]

[dependency-groups]
dev = [
  "httpx>=0.27.0",
  "pytest>=8.3.0",
  "ruff>=0.6.0",
]

[tool.pytest.ini_options]
pythonpath = ["src"]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
target-version = "py312"
PYPROJECT

  # 按需添加数据库和缓存依赖
  if [[ "$NEEDS_DATABASE" == true && "$DATABASE_PREF" == "postgresql" ]]; then
    python3 -c "
import yaml
data = yaml.safe_load(open('pyproject.toml'.replace('pyproject.toml', 'pyproject.toml')))
" 2>/dev/null || true
    # 直接用 sed 追加依赖
    sed -i 's|"pydantic-settings>=2.4.0",|"pydantic-settings>=2.4.0",\n  "psycopg[binary]>=3.2.0",|' pyproject.toml
  fi

  if [[ "$NEEDS_DATABASE" == true && "$DATABASE_PREF" == "mysql" ]]; then
    sed -i 's|"pydantic-settings>=2.4.0",|"pydantic-settings>=2.4.0",\n  "pymysql>=1.1.0",|' pyproject.toml
  fi

  if [[ "$NEEDS_DATABASE" == true && "$DATABASE_PREF" == "sqlite" ]]; then
    # SQLite 不需要额外驱动，但可以加 aiosqlite
    sed -i 's|"pydantic-settings>=2.4.0",|"pydantic-settings>=2.4.0",\n  "aiosqlite>=0.20.0",|' pyproject.toml
  fi

  if [[ "$NEEDS_CACHE" == true && "$CACHE_PREF" == "redis" ]]; then
    sed -i 's|"pydantic-settings>=2.4.0",|"pydantic-settings>=2.4.0",\n  "redis>=5.0.0",|' pyproject.toml
    # 也加到 .env.example
    echo "REDIS_URL=redis://\${REDIS_HOST}:\${REDIS_PORT}/\${REDIS_DB}" >> .env.example
  fi

  # 创建源码目录
  mkdir -p src/app
  mkdir -p tests

  cat > src/app/__init__.py << 'PYINIT'
PYINIT

  cat > src/app/config.py << PYCONFIG
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "${PROJECT_NAME}"
    app_env: str = "development"
    app_host: str = "0.0.0.0"
    app_port: int = 8000

    class Config:
        env_file = ".env"

settings = Settings()
PYCONFIG

  cat > src/app/main.py << 'PYMAIN'
from fastapi import FastAPI
from .config import settings

app = FastAPI(title=settings.app_name)

@app.get("/")
async def root():
    return {
        "message": f"{settings.app_name} is running",
        "environment": settings.app_env,
    }

@app.get("/health")
async def health():
    return {"status": "ok", "environment": settings.app_env}
PYMAIN

  cat > tests/test_health.py << 'TESTHEALTH'
from fastapi.testclient import TestClient
from src.app.main import app

client = TestClient(app)

def test_root():
    response = client.get("/")
    assert response.status_code == 200

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
TESTHEALTH

elif [[ "$BACKEND_LANG" == "node" ]]; then
  # Node.js 项目骨架
  mkdir -p src
  cat > package.json << PKGJSON
{
  "name": "${PROJECT_NAME}",
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "node --watch src/index.js",
    "start": "node src/index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  }
}
PKGJSON

  cat > src/index.js << 'NODEINDEX'
import http from 'node:http';

const PORT = process.env.APP_PORT || 8000;

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
  } else {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ message: 'Server is running' }));
  }
});

server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
NODEINDEX
fi

# ── 前端骨架 ──

if [[ "$NEEDS_FRONTEND" == true && "$FRONTEND_PREF" == "react" ]]; then
  FRONTEND_DIR="frontend"
  if [[ "$BACKEND_LANG" == "python" ]]; then
    # 全栈项目：前端在 frontend/ 子目录
    mkdir -p "$FRONTEND_DIR/src"
    cat > "$FRONTEND_DIR/package.json" << FEJSON
{
  "name": "${PROJECT_NAME}-frontend",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.0",
    "vite": "^5.4.0"
  }
}
FEJSON

    cat > "$FRONTEND_DIR/index.html" << 'FEHTML'
<!DOCTYPE html>
<html lang="zh-CN">
  <head><meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><title>App</title></head>
  <body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body>
</html>
FEHTML

    cat > "$FRONTEND_DIR/src/main.jsx" << 'FEMAIN'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode><App /></React.StrictMode>
)
FEMAIN

    cat > "$FRONTEND_DIR/src/App.jsx" << 'FEAPP'
function App() {
  return <div><h1>Hello from React</h1></div>
}
export default App
FEAPP

    cat > "$FRONTEND_DIR/vite.config.js" << 'FEVITE'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': 'http://127.0.0.1:8000',
    },
  },
})
FEVITE
  fi
fi

# ── 生成 README.md ──

cat > README.md << READMEEOF
# ${PROJECT_NAME}

> 由 \`scaffold.sh\` 基于 \`project-spec.yaml\` 生成

## 技术栈

- 后端：${BACKEND_LANG} / ${BACKEND_FRAMEWORK}
- 前端：${FRONTEND_PREF}
- 数据库：${DATABASE_PREF}
- 缓存：${CACHE_PREF}

## 快速开始

\`\`\`bash
cp .env.example .env
# 编辑 .env，修改密码和配置
make bootstrap
make dev
make test
\`\`\`

## 环境要求

- Python ${PYTHON_VERSION} + uv
- Docker（用于 PostgreSQL / Redis）
- Node.js + pnpm（如需前端开发）

## 项目结构

\`\`\`text
${PROJECT_NAME}
├─ .env.example
├─ .gitignore
├─ Makefile
├─ compose.yaml
├─ pyproject.toml
├─ scripts/
│  ├─ bootstrap.sh
│  ├─ check-env.sh
│  ├─ dev.sh
│  ├─ lib.sh
│  └─ test.sh
├─ src/
│  └─ app/
├─ tests/
└─ README.md
\`\`\`

## 更多信息

- 项目需求：\`project-spec.yaml\`
- Agent 协作规则：\`AGENTS.md\`
READMEEOF

# ── 生成 AGENTS.md（精简版）──

cat > AGENTS.md << AGENTSEOF
# ${PROJECT_NAME} Agent 协作规则

## 技术栈

- 后端：${BACKEND_LANG} / ${BACKEND_FRAMEWORK}
- 前端：${FRONTEND_PREF}
- 数据库：${DATABASE_PREF}
- 缓存：${CACHE_PREF}
- 包管理：${PYTHON_PM} / ${NODE_PM}

## 工作方式

1. 先读 \`README.md\` 和 \`pyproject.toml\`（或 \`package.json\`）
2. 保持当前技术栈，不随意替换
3. 修改代码后同步更新测试和文档
4. 环境变量通过 \`.env\` 管理，不提交 Git

## 脚本入口

- 初始化：\`make bootstrap\`
- 开发：\`make dev\`
- 测试：\`make test\`
- 环境检查：\`make check\`
AGENTSEOF

# ── 初始化 Git ──

git init
echo "[完成] 已初始化 Git 仓库"

# ── 完成 ──

echo ""
echo "=============================="
echo "  项目骨架生成完成！"
echo "=============================="
echo ""
echo "  项目目录：$TARGET_DIR"
echo "  项目名称：$PROJECT_NAME"
echo ""
echo "[下一步] 请执行以下操作："
echo ""
echo "  1. 进入项目目录："
echo "     cd $TARGET_DIR"
echo ""
echo "  2. 复制并编辑环境变量："
echo "     cp .env.example .env"
echo "     # 编辑 .env，填入你的真实密码和 API Key"
echo ""
echo "  3. 运行初始化："
echo "     make bootstrap"
echo ""
echo "  4. 启动开发："
echo "     make dev"
echo ""
echo "[提示] 这是一个最小骨架，你可以让 Agent 基于 project-spec.yaml 中的需求继续扩展。"
