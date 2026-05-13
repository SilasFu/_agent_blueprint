#!/usr/bin/env bash
set -euo pipefail

# ── 脚本质量检查 ──
# 用法：bash scripts/lint.sh [--fix]
# 检查所有 shell 脚本的语法和风格

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

FIX_MODE=false
if [[ "${1:-}" == "--fix" ]]; then
  FIX_MODE=true
fi

echo "=============================="
echo "  脚本质量检查"
echo "=============================="
echo ""

# 收集所有 shell 脚本
SCRIPTS=()
while IFS= read -r -d '' file; do
  SCRIPTS+=("$file")
done < <(find "$BLUEPRINT_ROOT/scripts" -name "*.sh" -print0 2>/dev/null)

# 也检查模板脚本
while IFS= read -r -d '' file; do
  SCRIPTS+=("$file")
done < <(find "$BLUEPRINT_ROOT/templates" -name "*.sh" -print0 2>/dev/null)

TOTAL=${#SCRIPTS[@]}
PASS=0
FAIL=0
WARN=0

echo "[检查] 共发现 $TOTAL 个 shell 脚本"
echo ""

for script in "${SCRIPTS[@]}"; do
  rel_path="${script#$BLUEPRINT_ROOT/}"

  # bash 语法检查
  if bash -n "$script" 2>/dev/null; then
    echo "[通过] $rel_path — 语法正确"
    PASS=$((PASS + 1))
  else
    echo "[失败] $rel_path — 语法错误"
    bash -n "$script" 2>&1 | sed 's/^/  /'
    FAIL=$((FAIL + 1))
  fi

  # ShellCheck（如果可用）
  if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck -s bash "$script" 2>/dev/null; then
      :
    else
      echo "[警告] $rel_path — ShellCheck 发现问题："
      if [[ "$FIX_MODE" == true ]]; then
        shellcheck -s bash --format diff "$script" 2>/dev/null | head -20 || true
      else
        shellcheck -s bash "$script" 2>/dev/null | head -10 | sed 's/^/  /'
      fi
      WARN=$((WARN + 1))
    fi
  fi
done

echo ""
echo "=============================="
echo "  检查结果"
echo "=============================="
echo ""
echo "  总计：$TOTAL"
echo "  通过：$PASS"
echo "  失败：$FAIL"
echo "  警告：$WARN"
echo ""

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "[提示] 未安装 ShellCheck，跳过风格检查"
  echo "[提示] 安装方式：sudo apt install shellcheck 或 apt install shellcheck"
fi

if [[ $FAIL -gt 0 ]]; then
  echo "[失败] 存在语法错误，请修复后重新检查"
  exit 1
elif [[ $WARN -gt 0 ]]; then
  echo "[通过] 语法正确，但存在风格建议"
  exit 0
else
  echo "[通过] 所有脚本检查通过"
  exit 0
fi
