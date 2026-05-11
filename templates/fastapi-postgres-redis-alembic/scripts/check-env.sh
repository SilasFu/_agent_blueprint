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

is_installed() {
  command_exists "$1"
}

tool_label() {
  case "$1" in
    git) echo "Git" ;;
    docker) echo "Docker" ;;
    python3) echo "Python 3" ;;
    uv) echo "uv" ;;
    *) echo "$1" ;;
  esac
}

install_tool() {
  case "$1" in
    git) install_git ;;
    docker) install_docker ;;
    python3) install_python3 ;;
    uv) install_uv ;;
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
  echo "  FastAPI Alembic 模板环境检查"
  echo "=============================="

  local required_tools=(git docker python3 uv)
  local missing=()
  local tool

  for tool in "${required_tools[@]}"; do
    if is_installed "$tool"; then
      echo "[已安装] $(tool_label "$tool")"
    else
      echo "[缺失] $(tool_label "$tool")"
      missing+=("$tool")
    fi
  done

  if [[ "${#missing[@]}" -eq 0 ]]; then
    echo ""
    echo "当前工具版本："
    for tool in "${required_tools[@]}"; do
      print_version "$tool"
    done
    echo ""
    echo "[完成] 环境检查通过，可以直接初始化项目。"
    exit 0
  fi

  echo ""
  echo "[说明] 该模板依赖以上工具才能完成初始化。"

  if ! confirm_install; then
    echo "[错误] 你选择了暂不安装，当前还不能继续初始化。"
    exit 1
  fi

  for tool in "${missing[@]}"; do
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

  echo "[完成] 所有必需工具均已准备好。"
  echo "[提示] 如果刚安装了 uv，重新打开终端后执行命令会更稳定。"
}

main "$@"