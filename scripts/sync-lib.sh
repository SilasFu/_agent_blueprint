#!/usr/bin/env bash
set -euo pipefail

# ── 同步 lib.sh 到所有模板 ──
# 用法：bash scripts/sync-lib.sh [--dry-run]
# 将根目录的 scripts/lib.sh 推送到所有模板的 scripts/lib.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DRY_RUN=false

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[预览] 仅显示将要同步的文件，不实际执行"
  echo ""
fi

SOURCE_FILE="$BLUEPRINT_ROOT/scripts/lib.sh"

if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "[错误] 源文件不存在：$SOURCE_FILE"
  exit 1
fi

TEMPLATE_DIR="$BLUEPRINT_ROOT/templates"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "[错误] 模板目录不存在：$TEMPLATE_DIR"
  exit 1
fi

SYNC_COUNT=0
SKIP_COUNT=0
DIFF_COUNT=0

for template in "$TEMPLATE_DIR"/*/; do
  template_name="$(basename "$template")"
  target_file="$template/scripts/lib.sh"

  if [[ ! -f "$target_file" ]]; then
    echo "[跳过] $template_name/scripts/lib.sh 不存在"
    SKIP_COUNT=$((SKIP_COUNT + 1))
    continue
  fi

  # 比较文件内容
  if diff -q "$SOURCE_FILE" "$target_file" >/dev/null 2>&1; then
    echo "[一致] $template_name/scripts/lib.sh 已是最新"
    continue
  fi

  DIFF_COUNT=$((DIFF_COUNT + 1))

  if [[ "$DRY_RUN" == true ]]; then
    echo "[待同步] $template_name/scripts/lib.sh"
    diff --color=auto "$SOURCE_FILE" "$target_file" || true
    echo ""
  else
    cp "$SOURCE_FILE" "$target_file"
    echo "[已同步] $template_name/scripts/lib.sh"
    SYNC_COUNT=$((SYNC_COUNT + 1))
  fi
done

echo ""
echo "=============================="
echo "  同步结果"
echo "=============================="
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "  待同步：$DIFF_COUNT 个模板"
  echo "  已跳过：$SKIP_COUNT 个模板（无 lib.sh）"
  echo ""
  echo "[提示] 确认无误后，执行：bash scripts/sync-lib.sh"
else
  echo "  已同步：$SYNC_COUNT 个模板"
  echo "  已跳过：$SKIP_COUNT 个模板（无 lib.sh）"
  echo "  无变化：$(( $(ls -1d "$TEMPLATE_DIR"/*/ 2>/dev/null | wc -l) - SYNC_COUNT - SKIP_COUNT - DIFF_COUNT + SYNC_COUNT )) 个模板"
  if [[ $SYNC_COUNT -gt 0 ]]; then
    echo ""
    echo "[提示] 已更新模板中的 lib.sh，建议检查模板功能是否正常"
  fi
fi
