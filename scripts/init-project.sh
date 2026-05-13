#!/usr/bin/env bash
set -euo pipefail

# ── 参数化模板→项目转换脚本 ──
# 用法：bash scripts/init-project.sh <模板名> <目标目录> [项目名]
# 示例：bash scripts/init-project.sh fastapi-postgres-redis ~/workspace/my-api my-api

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── 参数校验 ──

TEMPLATE_NAME="${1:-}"
TARGET_DIR="${2:-}"
PROJECT_NAME="${3:-}"

if [[ -z "$TEMPLATE_NAME" || -z "$TARGET_DIR" ]]; then
  echo "用法：bash scripts/init-project.sh <模板名> <目标目录> [项目名]"
  echo ""
  echo "可用模板："
  echo "  fastapi-postgres-redis          最小 FastAPI 后端"
  echo "  fastapi-postgres-redis-alembic  带 Alembic 迁移的增强后端"
  echo "  react-fastapi-postgres-redis    React + FastAPI 全栈"
  echo ""
  echo "示例："
  echo "  bash scripts/init-project.sh fastapi-postgres-redis ~/workspace/my-api my-api"
  exit 1
fi

TEMPLATE_DIR="$BLUEPRINT_ROOT/templates/$TEMPLATE_NAME"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "[错误] 模板不存在：$TEMPLATE_NAME"
  echo "[提示] 可用模板："
  ls -1 "$BLUEPRINT_ROOT/templates/" 2>/dev/null || echo "  （无）"
  exit 1
fi

if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$(basename "$TARGET_DIR")"
fi

# ── 安全检查 ──

if [[ -d "$TARGET_DIR" && "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  echo "[错误] 目标目录已存在且不为空：$TARGET_DIR"
  echo "[提示] 请指定一个空目录或新目录名。"
  exit 1
fi

# ── 执行复制 ──

echo "=============================="
echo "  从模板创建新项目"
echo "=============================="
echo ""
echo "[信息] 模板：$TEMPLATE_NAME"
echo "[信息] 目标：$TARGET_DIR"
echo "[信息] 项目名：$PROJECT_NAME"
echo ""

mkdir -p "$TARGET_DIR"

# 复制模板内容（排除 .git 目录，如果有的话）
if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude='.git' "$TEMPLATE_DIR/" "$TARGET_DIR/"
else
  # fallback：用 cp
  cp -r "$TEMPLATE_DIR/"* "$TARGET_DIR/" 2>/dev/null || true
  cp -r "$TEMPLATE_DIR/".[!.]* "$TARGET_DIR/" 2>/dev/null || true
fi

echo "[完成] 已复制模板文件到 $TARGET_DIR"

# ── 参数化替换（精确替换，不破坏代码）──
#
# 替换策略：
#   1. 配置文件（.env*、compose.yaml、pyproject.toml）：替换项目名、数据库名、用户名
#   2. Python config.py：替换配置类中的默认值
#   3. README.md / AGENTS.md：替换文档中的模板名引用
#   4. 不替换 Python 模块名 `app`（from app.xxx import yyy）和 FastAPI 变量名 `app`
#   5. 替换后验证 YAML 和 Python 语法

cd "$TARGET_DIR"

DB_NAME="${PROJECT_NAME}_db"
DB_USER="${PROJECT_NAME}"

# ── 第 1 步：替换 .env 和 .env.example ──

for env_file in .env.example .env; do
  if [[ -f "$env_file" ]]; then
    # APP_NAME
    sed -i "s/^APP_NAME=.*/APP_NAME=${PROJECT_NAME}/g" "$env_file"
    # COMPOSE_PROJECT_NAME
    sed -i "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=${PROJECT_NAME}/g" "$env_file"
    # POSTGRES_USER
    sed -i "s/^POSTGRES_USER=.*/POSTGRES_USER=${DB_USER}/g" "$env_file"
    # POSTGRES_DB
    sed -i "s/^POSTGRES_DB=.*/POSTGRES_DB=${DB_NAME}/g" "$env_file"
    # POSTGRES_PASSWORD（生成随机密码占位符）
    RANDOM_SUFFIX="$(head -c 8 /dev/urandom 2>/dev/null | xxd -p || echo 'change_me')"
    sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=change_me_${RANDOM_SUFFIX}/g" "$env_file"
  fi
done

# ── 第 2 步：替换 compose.yaml ──

if [[ -f "compose.yaml" ]]; then
  # 容器名默认值
  sed -i "s/\${COMPOSE_PROJECT_NAME:-app}-postgres/\${COMPOSE_PROJECT_NAME:-${PROJECT_NAME}}-postgres/g" compose.yaml
  sed -i "s/\${COMPOSE_PROJECT_NAME:-app}-redis/\${COMPOSE_PROJECT_NAME:-${PROJECT_NAME}}-redis/g" compose.yaml
  # 数据库用户默认值
  sed -i "s/\${POSTGRES_USER:-app}/\${POSTGRES_USER:-${DB_USER}}/g" compose.yaml
  # 数据库名默认值
  sed -i "s/\${POSTGRES_DB:-appdb}/\${POSTGRES_DB:-${DB_NAME}}/g" compose.yaml
  # 健康检查中的默认值
  sed -i "s/pg_isready -U \${POSTGRES_USER:-${DB_USER}} -d \${POSTGRES_DB:-${DB_NAME}}/pg_isready -U \${POSTGRES_USER:-${DB_USER}} -d \${POSTGRES_DB:-${DB_NAME}}/g" compose.yaml
fi

# ── 第 3 步：替换 pyproject.toml ──

if [[ -f "pyproject.toml" ]]; then
  sed -i "s/^name = \".*\"/name = \"${PROJECT_NAME}\"/g" pyproject.toml
elif [[ -f "backend/pyproject.toml" ]]; then
  sed -i "s/^name = \".*\"/name = \"${PROJECT_NAME}-backend\"/g" backend/pyproject.toml
fi

# ── 第 4 步：替换 Python config.py 中的配置默认值 ──
# 使用精确匹配，只替换配置字段的值，不替换模块名

CONFIG_FILES=()
if [[ -f "src/app/config.py" ]]; then
  CONFIG_FILES+=("src/app/config.py")
fi
if [[ -f "backend/src/app/config.py" ]]; then
  CONFIG_FILES+=("backend/src/app/config.py")
fi

for cfg in "${CONFIG_FILES[@]}"; do
  # app_name 默认值
  sed -i "s/app_name: str = \"[^\"]*\"/app_name: str = \"${PROJECT_NAME}\"/g" "$cfg"
  # postgres_user 默认值
  sed -i 's/postgres_user: str = "app"/postgres_user: str = "'${DB_USER}'"/g' "$cfg"
  # postgres_db 默认值
  sed -i 's/postgres_db: str = "appdb"/postgres_db: str = "'${DB_NAME}'"/g' "$cfg"
  # postgres_password 默认值
  sed -i 's/postgres_password: str = "app123"/postgres_password: str = "change_me_in_production"/g' "$cfg"
  # database_url 中的用户名和密码
  sed -i "s|postgresql://app:app123@|postgresql://${DB_USER}:change_me_in_production@|g" "$cfg"
  sed -i "s|postgresql+psycopg://app:app123@|postgresql+psycopg://${DB_USER}:change_me_in_production@|g" "$cfg"
  # database_url 中的数据库名
  sed -i "s|/appdb|/${DB_NAME}|g" "$cfg"
done

# ── 第 5 步：替换文档中的模板名引用（README.md、AGENTS.md）──

for doc_file in README.md AGENTS.md; do
  if [[ -f "$doc_file" ]]; then
    sed -i "s/${TEMPLATE_NAME}/${PROJECT_NAME}/g" "$doc_file"
  fi
done

# ── 第 6 步：验证替换结果 ──

VERIFY_ERRORS=0

# 验证 YAML 语法
if command -v python3 >/dev/null 2>&1 && [[ -f "compose.yaml" ]]; then
  if ! python3 -c "import yaml; yaml.safe_load(open('compose.yaml'))" 2>/dev/null; then
    echo "[警告] compose.yaml 语法检查未通过，请手动检查"
    VERIFY_ERRORS=$((VERIFY_ERRORS + 1))
  fi
fi

# 验证 Python 语法
if command -v python3 >/dev/null 2>&1; then
  for py_file in $(find . -name "config.py" -not -path "*/.venv/*" -not -path "*/__pycache__/*" 2>/dev/null); do
    if ! python3 -m py_compile "$py_file" 2>/dev/null; then
      echo "[警告] Python 语法检查未通过：$py_file"
      VERIFY_ERRORS=$((VERIFY_ERRORS + 1))
    fi
  done
fi

if [[ $VERIFY_ERRORS -eq 0 ]]; then
  echo "[完成] 已完成参数化替换，验证通过"
else
  echo "[警告] 替换完成但存在 $VERIFY_ERRORS 个验证警告，请手动检查"
fi

# ── 清理 ──

# 删除模板中可能存在的其他模板引用
if [[ -d "templates" ]]; then
  rm -rf templates
  echo "[清理] 已移除不需要的模板目录"
fi

# ── 初始化 Git ──

if [[ ! -d ".git" ]]; then
  git init
  echo "[完成] 已初始化 Git 仓库"
fi

# ── 输出引导 ──

echo ""
echo "=============================="
echo "  项目创建完成！"
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
echo "[提示] 安全提醒："
echo "  - .env.example 中的密码是占位符，请务必修改为强密码"
echo "  - .env 已加入 .gitignore，不会被提交到仓库"
echo ""
echo "[提示] 如果你需要让 Agent 协助开发，请先填写 project-spec.yaml"
echo "  并让 Agent 阅读项目中的 AGENTS.md"
