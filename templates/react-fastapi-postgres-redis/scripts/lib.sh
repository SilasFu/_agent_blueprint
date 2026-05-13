#!/usr/bin/env bash
# ──────────────────────────────────────────────
# scripts/lib.sh — 共享函数库
# 所有根目录和模板脚本通过 source 引入此文件
# 修改函数时只需更新此文件，然后同步到模板的 scripts/lib.sh
# ──────────────────────────────────────────────

# 防止重复 source
[[ -n "${_LIB_SH_LOADED:-}" ]] && return 0
_LIB_SH_LOADED=1

# ── 通用工具 ──

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

append_line_if_missing() {
  local file="$1"
  local line="$2"

  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

# ── sudo 辅助 ──

run_with_sudo() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

# ── apt 包管理 ──

APT_UPDATED=0

apt_update_once() {
  if ! command_exists apt; then
    echo "[错误] 当前系统没有检测到 apt，暂不支持自动安装。"
    echo "[提示] 请改用 Ubuntu / WSL Ubuntu，或手动安装缺失工具。"
    echo "[提示] 推荐环境：Windows + WSL2 Ubuntu。"
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

# ── nvm 加载 ──

load_nvm() {
  export NVM_DIR="$HOME/.nvm"
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    source "$NVM_DIR/nvm.sh"
  fi
}

# ── 工具安装函数 ──

install_git() {
  apt_install git
}

install_docker() {
  if command_exists docker; then
    return 0
  fi

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

install_pyenv() {
  if ! command_exists curl; then
    apt_install curl
  fi

  echo "[安装] 正在安装 pyenv..."
  curl -fsSL https://pyenv.run | bash
  append_line_if_missing "$HOME/.bashrc" 'export PYENV_ROOT="$HOME/.pyenv"'
  append_line_if_missing "$HOME/.bashrc" 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
  append_line_if_missing "$HOME/.bashrc" 'eval "$(pyenv init -)"'
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
    install_nvm || return 1
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

install_tool() {
  local tool="$1"

  case "$tool" in
    git) install_git ;;
    docker) install_docker ;;
    python3) install_python3 ;;
    uv) install_uv ;;
    node) install_node ;;
    pnpm) install_pnpm ;;
    pyenv) install_pyenv ;;
    nvm) install_nvm ;;
    *)
      echo "[错误] 未知工具：$tool"
      return 1
      ;;
  esac
}

# ── 工具检测 ──

is_installed() {
  local tool="$1"

  case "$tool" in
    pyenv)
      command_exists pyenv || [[ -d "$HOME/.pyenv" ]]
      ;;
    nvm)
      load_nvm >/dev/null 2>&1 || true
      command_exists nvm || [[ -d "$HOME/.nvm" ]]
      ;;
    docker)
      # 只检查二进制是否存在，不检查 daemon 状态
      # daemon 状态检查由 check_docker_daemon 单独负责
      command_exists docker
      ;;
    *)
      command_exists "$tool"
      ;;
  esac
}

# ── 版本输出 ──

tool_label() {
  case "$1" in
    git) echo "Git" ;;
    docker) echo "Docker" ;;
    python3) echo "Python 3" ;;
    uv) echo "uv" ;;
    node) echo "Node.js" ;;
    pnpm) echo "pnpm" ;;
    pyenv) echo "pyenv" ;;
    nvm) echo "nvm" ;;
    *) echo "$1" ;;
  esac
}

print_version() {
  local tool="$1"

  case "$tool" in
    git)
      git --version
      ;;
    docker)
      if command_exists docker; then
        docker --version
        if docker info >/dev/null 2>&1; then
          docker compose version || true
        else
          echo "Docker 已安装但 daemon 未运行"
          echo "  修复方式：sudo service docker start 或启动 Docker Desktop"
        fi
      fi
      ;;
    python3)
      python3 --version
      ;;
    uv)
      uv --version
      ;;
    node)
      node -v
      ;;
    pnpm)
      pnpm -v
      ;;
    pyenv)
      if command_exists pyenv; then
        pyenv --version
      elif [[ -d "$HOME/.pyenv" ]]; then
        echo "pyenv 已安装在 $HOME/.pyenv（重新打开终端后可直接使用）"
      fi
      ;;
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

# ── 交互确认 ──

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

# ── Docker 相关检测 ──

check_docker_daemon() {
  if ! command_exists docker; then
    return 1
  fi
  docker info >/dev/null 2>&1
}

check_port_in_use() {
  local port="$1"
  if command -v ss >/dev/null 2>&1; then
    ss -tlnp 2>/dev/null | grep -q ":${port} " && return 0
  elif command -v lsof >/dev/null 2>&1; then
    lsof -i :"${port}" >/dev/null 2>&1 && return 0
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tlnp 2>/dev/null | grep -q ":${port} " && return 0
  fi
  return 1
}

# ── 环境检查主流程（通用版）──
# 用法：run_env_check required_tools optional_tools
# 例如：run_env_check "git docker python3 uv" "pyenv nvm"

run_env_check() {
  local required_str="${1:-}"
  local optional_str="${2:-}"

  local -a required_tools=()
  local -a optional_tools=()

  # 将空格分隔的字符串转为数组
  if [[ -n "$required_str" ]]; then
    read -ra required_tools <<< "$required_str"
  fi
  if [[ -n "$optional_str" ]]; then
    read -ra optional_tools <<< "$optional_str"
  fi

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

  echo ""
  echo "检测结果："
  if [[ "${#missing_required[@]}" -eq 0 ]]; then
    echo "- 必需工具：都已具备"
  else
    echo "- 必需工具缺失：${missing_required[*]}"
  fi

  if [[ "${#missing_optional[@]}" -eq 0 ]]; then
    echo "- 推荐工具：都已具备"
  else
    echo "- 推荐工具缺失：${missing_optional[*]}"
  fi

  # 如果全部具备
  if [[ "${#missing_required[@]}" -eq 0 && "${#missing_optional[@]}" -eq 0 ]]; then
    echo ""
    echo "当前可用工具版本："
    for tool in "${required_tools[@]}" "${optional_tools[@]}"; do
      print_version "$tool" || true
    done
    echo ""
    echo "[完成] 环境检查通过，可以继续下一步。"
    return 0
  fi

  echo ""
  echo "[说明] 缺失的工具会影响后续初始化或开发体验。"

  if ! confirm_install; then
    echo "[提示] 你选择了暂不自动安装。"
    echo ""
    echo "当前可用工具版本："
    for tool in "${required_tools[@]}" "${optional_tools[@]}"; do
      if is_installed "$tool"; then
        print_version "$tool" || true
      fi
    done
    if [[ "${#missing_required[@]}" -gt 0 ]]; then
      echo ""
      echo "[错误] 必需工具仍然缺失，当前项目还不能顺利初始化。"
      echo "[下一步] 请先补齐必需工具，再重新执行：make bootstrap"
      return 1
    fi
    echo ""
    echo "[完成] 推荐工具暂未安装，但不影响你继续查看项目。"
    return 0
  fi

  local failed=()
  for tool in "${missing_required[@]}" "${missing_optional[@]}"; do
    echo ""
    echo "[处理] 开始处理 $(tool_label "$tool")"
    if install_tool "$tool"; then
      echo "[完成] $(tool_label "$tool") 处理完成"
    else
      echo "[失败] $(tool_label "$tool") 安装失败"
      failed+=("$tool")
    fi
  done

  echo ""
  echo "[复查] 正在重新检查环境..."

  # 重新检测
  local still_missing_required=()
  local still_missing_optional=()

  for tool in "${missing_required[@]}"; do
    if ! is_installed "$tool"; then
      still_missing_required+=("$tool")
    fi
  done
  for tool in "${missing_optional[@]}"; do
    if ! is_installed "$tool"; then
      still_missing_optional+=("$tool")
    fi
  done

  echo "复查结果："
  if [[ "${#still_missing_required[@]}" -eq 0 ]]; then
    echo "- 必需工具：都已具备"
  else
    echo "- 必需工具仍缺失：${still_missing_required[*]}"
  fi
  if [[ "${#still_missing_optional[@]}" -eq 0 ]]; then
    echo "- 推荐工具：都已具备"
  else
    echo "- 推荐工具仍缺失：${still_missing_optional[*]}"
  fi

  echo ""
  echo "当前可用工具版本："
  for tool in "${required_tools[@]}" "${optional_tools[@]}"; do
    if is_installed "$tool"; then
      print_version "$tool" || true
    fi
  done

  if [[ "${#failed[@]}" -gt 0 ]]; then
    echo ""
    echo "[提示] 以下工具安装失败，请手动处理：${failed[*]}"
  fi

  if [[ "${#still_missing_required[@]}" -gt 0 ]]; then
    echo ""
    echo "[错误] 必需工具仍未准备完成，请根据提示手动处理后再继续。"
    echo "[下一步] 建议先按提示补齐工具，再重新执行：make bootstrap"
    return 1
  fi

  if [[ "${#still_missing_optional[@]}" -gt 0 ]]; then
    echo ""
    echo "[完成] 必需工具已准备好，推荐工具可以稍后再安装。"
  else
    echo ""
    echo "[完成] 所有工具都已准备好。"
  fi

  echo "[提示] 如果刚安装了 nvm / pyenv / uv，重新打开终端后体验会更稳定。"
  echo "[下一步] 继续执行项目初始化：make bootstrap"
  return 0
}

# ── Docker 服务启动（带检测）──

start_docker_services() {
  if [[ ! -f "compose.yaml" && ! -f "docker-compose.yml" ]]; then
    return 0
  fi

  if ! check_docker_daemon; then
    echo ""
    echo "[警告] Docker daemon 未运行或未安装。"
    echo "[提示] 如果在 WSL2 中，请先启动 Docker："
    echo "  sudo service docker start"
    echo "[提示] 或在 Windows 中启动 Docker Desktop。"
    echo "[提示] 跳过 Docker 服务启动，其他初始化已完成。"
    return 1
  fi

  # 端口冲突检测
  local pg_port="${POSTGRES_PORT:-5432}"
  local redis_port="${REDIS_PORT:-6379}"

  local port_warnings=()
  if check_port_in_use "$pg_port"; then
    port_warnings+=("PostgreSQL (${pg_port})")
  fi
  if check_port_in_use "$redis_port"; then
    port_warnings+=("Redis (${redis_port})")
  fi

  if [[ ${#port_warnings[@]} -gt 0 ]]; then
    echo ""
    echo "[警告] 检测到以下端口已被占用：${port_warnings[*]}"
    echo "[提示] 可能本机已安装对应服务，Docker 容器可能启动失败。"
    echo "[提示] 你可以在 .env 中修改端口号，或停止本机对应服务。"
    echo ""
    if [[ -t 0 ]]; then
      local answer
      read -r -p "是否仍要尝试启动 Docker 服务？[y/N] " answer
      case "$answer" in
        y|Y|yes|YES)
          docker compose up -d
          echo "[完成] 已尝试启动 Docker 基础服务（如有端口冲突，容器可能启动失败）"
          ;;
        *)
          echo "[跳过] 未启动 Docker 基础服务。"
          return 0
          ;;
      esac
    else
      echo "[跳过] 非交互终端，跳过 Docker 服务启动。"
      return 0
    fi
  else
    docker compose up -d
    echo "[完成] 已启动 Docker 基础服务"
  fi

  return 0
}
