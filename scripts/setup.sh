#!/bin/bash
set -e

echo "=============================="
echo "  Vibe Coding 环境一键安装"
echo "  Ubuntu 26.04 LTS"
echo "=============================="

# 1. 系统更新 + 基础依赖
echo "[1/6] 更新系统并安装基础依赖..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git build-essential ca-certificates \
    gnupg lsb-release software-properties-common

# 2. Docker（跑数据库、中间件，不污染系统）
echo "[2/6] 安装 Docker..."
if ! command -v docker &>/dev/null; then
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker $USER
    echo "   Docker 安装完成（需要重新登录生效）"
else
    echo "   Docker 已存在"
fi

# 3. Flatpak（补 Ubuntu 没有的桌面软件）
echo "[3/6] 安装 Flatpak..."
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 4. pyenv（Python 版本管理，别动系统 Python）
echo "[4/6] 安装 pyenv..."
if [ ! -d "$HOME/.pyenv" ]; then
    curl -fsSL https://pyenv.run | bash
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    echo "   pyenv 安装完成"
else
    echo "   pyenv 已存在"
fi

# 5. nvm（Node 版本管理）
echo "[5/6] 安装 nvm..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    echo "   nvm 安装完成"
else
    echo "   nvm 已存在"
fi

# 6. pnpm（更快的 npm 替代）
echo "[6/6] 安装 pnpm..."
npm install -g pnpm 2>/dev/null || sudo npm install -g pnpm

echo ""
echo "=============================="
echo " 安装完成！一些说明："
echo "=============================="
echo ""
echo "👉 重新打开终端，或运行: source ~/.bashrc"
echo ""
echo "📦 Docker 命令（跑完脚本后重新登录才能免 sudo）："
echo "  docker run -d --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql:8"
echo "  docker run -d --name redis -p 6379:6379 redis"
echo "  docker run -d --name postgres -p 5432:5432 -e POSTGRES_PASSWORD=root postgres:16"
echo ""
echo "📱 缺少桌面软件？Flatpak 搜一下："
echo "  flatpak search <软件名>"
echo "  flatpak install flathub <软件名>"
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
