#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo "  Vibe Coding 环境一键安装"
echo "  适用于 Ubuntu / WSL2 Ubuntu"
echo "=============================="

# ── 工具函数 ──

append_line_if_missing() {
  local file="$1"
  local line="$2"

  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ── 主流程 ──

# 1. 系统更新 + 基础依赖
echo "[1/6] 更新系统并安装基础依赖..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential ca-certificates \
    gnupg lsb-release software-properties-common

# 2. Docker
echo "[2/6] 安装 Docker..."
if ! command_exists docker; then
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker "$USER"
    echo "   Docker 安装完成（需要重新登录生效）"
else
    echo "   Docker 已存在"
fi

# 3. pyenv
echo "[3/5] 安装 pyenv..."
if [ ! -d "$HOME/.pyenv" ]; then
    curl -fsSL https://pyenv.run | bash
    append_line_if_missing ~/.bashrc 'export PYENV_ROOT="$HOME/.pyenv"'
    append_line_if_missing ~/.bashrc 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
    append_line_if_missing ~/.bashrc 'eval "$(pyenv init -)"'
    echo "   pyenv 安装完成"
else
    echo "   pyenv 已存在"
fi

# 4. nvm
echo "[4/5] 安装 nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    append_line_if_missing ~/.bashrc 'export NVM_DIR="$HOME/.nvm"'
    append_line_if_missing ~/.bashrc '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    echo "   nvm 安装完成"
else
    echo "   nvm 已存在"
fi

# 5. pnpm
echo "[5/5] 安装 pnpm..."
# 先加载 nvm 以确保 node 可用
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command_exists corepack; then
    corepack enable
    corepack prepare pnpm@latest --activate
    echo "   pnpm 通过 corepack 安装完成"
elif command_exists npm; then
    npm install -g pnpm 2>/dev/null || sudo npm install -g pnpm
    echo "   pnpm 通过 npm 安装完成"
else
    echo "   [警告] 未找到 node/npm，请重新打开终端后再安装 pnpm"
fi

echo ""
echo "=============================="
echo " 安装完成！一些说明："
echo "=============================="
echo ""
echo "👉 重新打开终端，或运行: source ~/.bashrc"
echo ""
echo "📦 下一步：创建或进入项目目录"
echo "  方式一：从模板创建项目"
echo "    bash scripts/init-project.sh fastapi-postgres-redis ~/workspace/my-api my-api"
echo "  方式二：基于需求文件生成骨架"
echo "    bash scripts/scaffold.sh project-spec.yaml ~/workspace/my-project"
echo ""
echo "🐍 Python 版本管理："
echo "  pyenv install 3.12"
echo "  pyenv global 3.12"
echo ""
echo "⬢ Node 版本管理："
echo "  nvm install 22"
echo "  nvm use 22"
echo ""
echo "=============================="
