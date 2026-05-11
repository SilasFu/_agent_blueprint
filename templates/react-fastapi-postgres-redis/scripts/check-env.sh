#!/usr/bin/env bash
set -euo pipefail

APT_UPDATED=0
SCRIPT_NAME="$(basename "$0")"

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_with_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

apt_update_once() {
  if ! command_exists apt; then
    echo "[错误] 当前系统没有检测到 apt，暂不支持自动安装。"
    echo "[提示] 推荐在 Ubuntu 或 WSL Ubuntu 中运行该脚本。"
    return 1
  fi

  if [[ "$APT_UPDATED" -eq 0 ]]; then
    echo "[安装] 正在更新软件源列表..."
    run_with_sudo apt update
    APT_UPDATED=1
  fi
}

apt_install() {
  apt_update_once || return 1
  echo "[安装] 正在安装：$*"
  run_with_sudo apt install -y "$@"
}

append_line_if_missing() {
  local file="$1"
  local line="$2"

  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
  fi
}

install_git() {
  apt_install git
}

install_docker() {
  apt_install curl ca-certificates gnupg lsb-release software-properties-common
  echo "[安装] 正在安装 Docker..."
  curl -fsSL https://get.docker.com | run_with_sudo bash
  if command_exists usermod && [[ -n "${USER:-}" ]]; then
    run_with_sudo usermod -aG docker "$USER" || true
  fi
  echo "[提示] Docker 已安装，重新登录后可免 sudo 使用。"
}

install_python3() {
  apt_install python3 python3-venv python3-pip
}

install_uv() {
  if ! command_exists curl; then
    apt_install curl
  fi
  echo "[安装] 正在安装 uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
  append_line_if_missing "$HOME/.bashrc" 'export PATH="$HOME/.local/bin:$PATH"'
  export PATH="$HOME/.local/bin:$PATH"
}

install_nvm() {
  if ! command_exists curl; then
    apt_install curl
  fi
  echo "[安装] 正在安装 nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  append_line_if_missing "$HOME/.bashrc" 'export NVM_DIR="$HOME/.nvm"'
  append_line_if_missing "$HOME/.bashrc" '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"'
  load_nvm
}

install_node() {
  if [[ ! -d "$HOME/.nvm" ]]; then
    install_nvm
  else
    load_nvm
  fi

  if ! command_exists nvm; then
    echo "[错误] nvm 尚未生效，请重新打开终端后再试。"
    return 1
  fi

  echo "[安装] 正在安装 Node.js LTS..."
  nvm install --lts
  nvm use --lts
}

install_pnpm() {
  if ! command_exists node; then
    install_node || return 1
  fi

  if command_exists corepack; then
    echo "[安装] 正在通过 corepack 启用 pnpm..."
    corepack enable
    corepack prepare pnpm@latest --activate
    return 0
  fi

  if command_exists npm; then
    echo "[安装] 正在通过 npm 安装 pnpm..."
    npm install -g pnpm || run_with_sudo npm install -g pnpm
    return 0
  fi

  echo "[错误] 未找到 npm，无法自动安装 pnpm。"
  return 1
}

is_installed() {
  local tool="$1"
  case "$tool" in
    nvm)
      load_nvm >/dev/null 2>&1 || true
      command_exists nvm || [[ -d "$HOME/.nvm" ]]
      ;;
    *)
      command_exists "$tool"
      ;;
  esac
}

tool_label() {
  case "$1" in
    git) echo "Git" ;;
    docker) echo "Docker" ;;
    python3) echo "Python 3" ;;
    uv) echo "uv" ;;
    node) echo "Node.js" ;;
    pnpm) echo "pnpm" ;;
    nvm) echo "nvm" ;;
    *) echo "$1" ;;
  esac
}

install_tool() {
  case "$1" in
    git) install_git ;;
    docker) install_docker ;;
    python3) install_python3 ;;
    uv) install_uv ;;
    node) install_node ;;
    pnpm) install_pnpm ;;
    nvm) install_nvm ;;
    *)
      echo "[错误] 未知工具：$1"
      return 1
      ;;
  esac
}

print_version() {
  case "$1" in
    git) git --version ;;
    docker)
      docker --version
      docker compose version || true
      ;;
    python3) python3 --version ;;
    uv) uv --version ;;
    node) node -v ;;
    pnpm) pnpm -v ;;
    nvm)
      load_nvm >/dev/null 2>&1 || true
      if command_exists nvm; then
        nvm --version
      elif [[ -d "$HOME/.nvm" ]]; then
        echo "nvm 已安装在 $HOME/.nvm（重新打开终端后可直接使用）"
      fi
      ;;
  esac
}

confirm_install() {
  if [[ "${AUTO_INSTALL:-}" == "1" || "${AUTO_INSTALL:-}" == "true" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    echo "[提示] 当前不是交互终端，无法询问是否自动安装。"
    echo "[提示] 如需自动安装，可使用：AUTO_INSTALL=1 bash $SCRIPT_NAME"
    return 1
  fi

  local answer
  read -r -p "是否现在自动安装以上缺失项？[y/N] " answer
  case "$answer" in
    y|Y|yes|YES|是)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

main() {
  echo "=============================="
  echo "  React + FastAPI 模板环境检查"
  echo "=============================="

  local required_tools=(git docker python3 uv node pnpm)
  local optional_tools=(nvm)
  local missing_required=()
  local missing_optional=()
  local tool

  for tool in "${required_tools[@]}"; do
    if is_installed "$tool"; then
      echo "[已安装] $(tool_label "$tool")"
    else
      echo "[缺失] $(tool_label "$tool")"
      missing_required+=("$tool")
    fi
  done

  for tool in "${optional_tools[@]}"; do
    if is_installed "$tool"; then
      echo "[已安装] $(tool_label "$tool")"
    else
      echo "[可选缺失] $(tool_label "$tool")"
      missing_optional+=("$tool")
    fi
  done

  if [[ "${#missing_required[@]}" -eq 0 && "${#missing_optional[@]}" -eq 0 ]]; then
    echo ""
    echo "当前工具版本："
    for tool in "${required_tools[@]}" "${optional_tools[@]}"; do
      print_version "$tool" || true
    done
    echo ""
    echo "[完成] 环境检查通过，可以直接初始化项目。"
    exit 0
  fi

  echo ""
  echo "[说明] 该模板依赖以上工具才能完成前后端初始化。"

  if ! confirm_install; then
    echo "[提示] 你选择了暂不自动安装。"
    if [[ "${#missing_required[@]}" -gt 0 ]]; then
      echo "[错误] 必需工具仍然缺失，当前还不能继续初始化。"
      exit 1
    fi
    echo "[完成] 可选工具暂未安装，但不影响继续操作。"
    exit 0
  fi

  for tool in "${missing_required[@]}" "${missing_optional[@]}"; do
    echo ""
    echo "[处理] 开始安装 $(tool_label "$tool")"
    install_tool "$tool"
  done

  echo ""
  echo "[复查] 再次检查环境..."
  for tool in "${required_tools[@]}"; do
    if ! is_installed "$tool"; then
      echo "[错误] $(tool_label "$tool") 仍未安装成功，请手动处理后重试。"
      exit 1
    fi
  done

  echo "[完成] 必需工具均已准备好。"
  if [[ "${#missing_optional[@]}" -eq 0 ]]; then
    echo "[完成] 推荐工具也已准备好。"
  fi
  echo "[提示] 如果刚安装了 nvm 或 uv，重新打开终端后执行命令会更稳定。"
}

main "$@"