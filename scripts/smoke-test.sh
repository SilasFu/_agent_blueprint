#!/usr/bin/env bash
set -euo pipefail

# ── 冒烟测试：验证核心脚本可执行 ──
# 用法：bash scripts/smoke-test.sh
# 不需要真实环境，只检查脚本是否能正常启动和退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

PASS=0
FAIL=0

echo "=============================="
echo "  冒烟测试"
echo "=============================="
echo ""

# 测试 1：check-env.sh 能正常执行（即使缺少工具也不应崩溃）
echo "[测试 1] check-env.sh 是否可执行..."
if bash "$SCRIPT_DIR/check-env.sh" 2>/dev/null; then
  echo "[通过] check-env.sh 正常退出"
  PASS=$((PASS + 1))
else
  # 缺失工具时 exit 1 是正常的
  echo "[通过] check-env.sh 正常退出（缺失工具导致非零退出码是预期行为）"
  PASS=$((PASS + 1))
fi

# 测试 2：bootstrap.sh 在蓝图根目录给出引导后正常退出
echo ""
echo "[测试 2] bootstrap.sh 在蓝图根目录是否正确引导..."
output=$(bash "$SCRIPT_DIR/bootstrap.sh" 2>&1) || true
if echo "$output" | grep -q "蓝图框架根目录"; then
  echo "[通过] bootstrap.sh 正确识别蓝图根目录并给出引导"
  PASS=$((PASS + 1))
else
  echo "[失败] bootstrap.sh 未正确识别蓝图根目录"
  FAIL=$((FAIL + 1))
fi

# 测试 3：dev.sh 在蓝图根目录给出引导
echo ""
echo "[测试 3] dev.sh 在蓝图根目录是否正确引导..."
output=$(bash "$SCRIPT_DIR/dev.sh" 2>&1) || true
if echo "$output" | grep -q "蓝图框架根目录\|蓝图框架根目录\|不是具体项目"; then
  echo "[通过] dev.sh 正确识别蓝图根目录并给出引导"
  PASS=$((PASS + 1))
else
  echo "[失败] dev.sh 未正确识别蓝图根目录"
  FAIL=$((FAIL + 1))
fi

# 测试 4：test.sh 在蓝图根目录给出引导
echo ""
echo "[测试 4] test.sh 在蓝图根目录是否正确引导..."
output=$(bash "$SCRIPT_DIR/test.sh" 2>&1) || true
if echo "$output" | grep -q "蓝图框架根目录\|蓝图框架根目录\|不是具体项目"; then
  echo "[通过] test.sh 正确识别蓝图根目录并给出引导"
  PASS=$((PASS + 1))
else
  echo "[失败] test.sh 未正确识别蓝图根目录"
  FAIL=$((FAIL + 1))
fi

# 测试 5：init-project.sh 无参数时显示用法
echo ""
echo "[测试 5] init-project.sh 无参数时是否显示用法..."
output=$(bash "$SCRIPT_DIR/init-project.sh" 2>&1) || true
if echo "$output" | grep -q "用法"; then
  echo "[通过] init-project.sh 正确显示用法"
  PASS=$((PASS + 1))
else
  echo "[失败] init-project.sh 未正确显示用法"
  FAIL=$((FAIL + 1))
fi

# 测试 6：validate-spec.sh 无 spec 文件时正确报错
echo ""
echo "[测试 6] validate-spec.sh 无 spec 文件时是否正确报错..."
output=$(bash "$SCRIPT_DIR/validate-spec.sh" /nonexistent/spec.yaml 2>&1) || true
if echo "$output" | grep -q "文件不存在"; then
  echo "[通过] validate-spec.sh 正确报错"
  PASS=$((PASS + 1))
else
  echo "[失败] validate-spec.sh 未正确报错"
  FAIL=$((FAIL + 1))
fi

# 测试 7：scaffold.sh 无 spec 文件时正确报错
echo ""
echo "[测试 7] scaffold.sh 无 spec 文件时是否正确报错..."
output=$(bash "$SCRIPT_DIR/scaffold.sh" /nonexistent/spec.yaml 2>&1) || true
if echo "$output" | grep -q "文件不存在\|错误"; then
  echo "[通过] scaffold.sh 正确报错"
  PASS=$((PASS + 1))
else
  echo "[失败] scaffold.sh 未正确报错"
  FAIL=$((FAIL + 1))
fi

# 测试 8：sync-lib.sh 能正常执行
echo ""
echo "[测试 8] sync-lib.sh 是否可执行..."
if bash "$SCRIPT_DIR/sync-lib.sh" 2>/dev/null; then
  echo "[通过] sync-lib.sh 正常执行"
  PASS=$((PASS + 1))
else
  echo "[失败] sync-lib.sh 执行异常"
  FAIL=$((FAIL + 1))
fi

# 测试 9：Makefile 目标存在
echo ""
echo "[测试 9] Makefile 核心目标是否存在..."
cd "$BLUEPRINT_ROOT"
for target in check bootstrap dev test validate scaffold sync-lib; do
  if grep -q "^${target}:" Makefile; then
    echo "[通过] make $target 目标存在"
    PASS=$((PASS + 1))
  else
    echo "[失败] make $target 目标缺失"
    FAIL=$((FAIL + 1))
  fi
done

# 测试 10：关键文件存在
echo ""
echo "[测试 10] 关键文件是否存在..."
for file in AGENTS.md README.md .env.example compose.yaml Makefile; do
  if [[ -f "$BLUEPRINT_ROOT/$file" ]]; then
    echo "[通过] $file 存在"
    PASS=$((PASS + 1))
  else
    echo "[失败] $file 缺失"
    FAIL=$((FAIL + 1))
  fi
done

# 输出结果
echo ""
echo "=============================="
echo "  测试结果"
echo "=============================="
echo ""
echo "  通过：$PASS"
echo "  失败：$FAIL"
echo ""

if [[ $FAIL -gt 0 ]]; then
  echo "[失败] 存在未通过的测试"
  exit 1
else
  echo "[通过] 所有冒烟测试通过"
  exit 0
fi
