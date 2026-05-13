#!/usr/bin/env bash
set -euo pipefail

# ── project-spec.yaml 校验脚本 ──
# 用法：bash scripts/validate-spec.sh [spec_file]
# 默认检查 project-spec.yaml
# 会读取 project-spec.schema.yaml 中的枚举值定义

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BLUEPRINT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SPEC_FILE="${1:-project-spec.yaml}"
SCHEMA_FILE="$BLUEPRINT_ROOT/project-spec.schema.yaml"

errors=0
warnings=0

echo "=============================="
echo "  project-spec 校验"
echo "=============================="
echo ""

# 检查文件是否存在
if [[ ! -f "$SPEC_FILE" ]]; then
  echo "[错误] 文件不存在：$SPEC_FILE"
  echo "[提示] 请先复制模板：cp project-spec.example.yaml project-spec.yaml"
  exit 1
fi

echo "[检查] 正在校验 $SPEC_FILE ..."
echo ""

# 检查 YAML 语法（如果 python3 可用）
if command -v python3 >/dev/null 2>&1; then
  if ! python3 -c "import yaml; yaml.safe_load(open('$SPEC_FILE'))" 2>/dev/null; then
    echo "[错误] YAML 语法不正确"
    errors=$((errors + 1))
  else
    echo "[通过] YAML 语法正确"
  fi

  # 尝试安装 PyYAML
  if ! python3 -c "import yaml" 2>/dev/null; then
    pip3 install pyyaml --quiet 2>/dev/null || pip install pyyaml --quiet 2>/dev/null || true
  fi
else
  echo "[跳过] 未安装 python3，跳过 YAML 语法检查"
fi

# ── 从 schema 动态读取枚举值的辅助函数 ──

get_schema_enum_values() {
  local key_path="$1"
  if [[ ! -f "$SCHEMA_FILE" ]]; then
    return 1
  fi
  python3 -c "
import yaml
schema = yaml.safe_load(open('$SCHEMA_FILE'))
keys = '$key_path'.split('.')
obj = schema
for k in keys:
    if isinstance(obj, dict) and k in obj:
        obj = obj[k]
    else:
        exit(1)
if isinstance(obj, dict) and 'values' in obj:
    print(','.join(obj['values']))
else:
    exit(1)
" 2>/dev/null
}

# 必填字段检查
check_required() {
  local key="$1"
  local description="$2"

  if python3 -c "
import yaml
data = yaml.safe_load(open('$SPEC_FILE'))
keys = '$key'.split('.')
obj = data
for k in keys:
    if isinstance(obj, dict) and k in obj:
        obj = obj[k]
    else:
        exit(1)
if obj is None or obj == '':
    exit(1)
" 2>/dev/null; then
    echo "[通过] 必填字段 $key 存在"
  else
    echo "[错误] 必填字段缺失或为空：$key（$description）"
    errors=$((errors + 1))
  fi
}

# 枚举值检查（优先从 schema 读取，回退到硬编码值）
check_enum() {
  local key="$1"
  local fallback_allowed="${2:-}"

  # 尝试从 schema 读取
  local allowed=""
  allowed=$(get_schema_enum_values "$key") || allowed="$fallback_allowed"

  if [[ -z "$allowed" ]]; then
    echo "[跳过] 字段 $key 的枚举值定义不可用"
    return
  fi

  if python3 -c "
import yaml
data = yaml.safe_load(open('$SPEC_FILE'))
keys = '$key'.split('.')
obj = data
for k in keys:
    if isinstance(obj, dict) and k in obj:
        obj = obj[k]
    else:
        exit(0)  # 字段不存在时跳过
allowed = '$allowed'.split(',')
if obj is not None and str(obj) not in allowed:
    print(f'  实际值: {obj}')
    print(f'  允许值: {allowed}')
    exit(1)
" 2>/dev/null; then
    echo "[通过] 字段 $key 的值合法"
  else
    echo "[警告] 字段 $key 的值不在推荐范围内"
    warnings=$((warnings + 1))
  fi
}

# 列表非空检查
check_list_not_empty() {
  local key="$1"
  local description="$2"

  if python3 -c "
import yaml
data = yaml.safe_load(open('$SPEC_FILE'))
keys = '$key'.split('.')
obj = data
for k in keys:
    if isinstance(obj, dict) and k in obj:
        obj = obj[k]
    else:
        exit(1)
if not isinstance(obj, list) or len(obj) == 0:
    exit(1)
" 2>/dev/null; then
    echo "[通过] 列表字段 $key 非空"
  else
    echo "[错误] 列表字段 $key 为空或不存在（$description）"
    errors=$((errors + 1))
  fi
}

# 执行检查
if command -v python3 >/dev/null 2>&1 && python3 -c "import yaml" 2>/dev/null; then
  echo "--- 必填字段检查 ---"
  check_required "project.name" "项目名称"
  check_required "project.type" "项目类型"
  check_required "requirements.summary" "需求概述"
  check_list_not_empty "requirements.core_features" "核心功能列表"

  echo ""
  echo "--- 枚举值检查 ---"
  # 从 schema 读取枚举值，硬编码值作为回退
  check_enum "project.type" "web_app,api_service,cli_tool,fullstack_app,data_pipeline,ai_service,mobile_app,desktop_app"
  check_enum "project.stage" "prototype,mvp,production"
  check_enum "project.owner" "solo_developer,small_team,medium_team"
  check_enum "constraints.deployment.target" "vps,serverless,container,local,cloud_managed"
  check_enum "preferences.backend.preferred" "python,node,go,rust"
  check_enum "preferences.frontend.preferred" "react,vue,svelte,none"
  check_enum "preferences.database.preferred" "postgresql,mysql,sqlite,mongodb,none"
  check_enum "preferences.cache.preferred" "redis,memcached,none"

  echo ""
  echo "--- 项目名格式检查 ---"
  if python3 -c "
import yaml, re
data = yaml.safe_load(open('$SPEC_FILE'))
name = data.get('project', {}).get('name', '')
if name and not re.match(r'^[a-z][a-z0-9_-]*\$', name):
    print(f'  项目名: {name}')
    print(f'  建议格式: 小写字母开头，只含小写字母、数字、连字符和下划线')
    exit(1)
" 2>/dev/null; then
    echo "[通过] 项目名格式合法"
  else
    echo "[警告] 项目名格式不规范，可能影响容器名和目录名生成"
    warnings=$((warnings + 1))
  fi

  echo ""
  echo "--- 需求概述长度检查 ---"
  if python3 -c "
import yaml
data = yaml.safe_load(open('$SPEC_FILE'))
summary = data.get('requirements', {}).get('summary', '')
if summary and len(summary) < 10:
    print(f'  当前长度: {len(summary)} 字符')
    print(f'  建议至少: 10 字符')
    exit(1)
" 2>/dev/null; then
    echo "[通过] 需求概述长度足够"
  else
    echo "[警告] 需求概述太短，建议至少 10 个字符以便 Agent 理解"
    warnings=$((warnings + 1))
  fi

  echo ""
  echo "--- scaffold 兼容性检查 ---"
  # 检查 project-spec.yaml 是否包含 scaffold.sh 需要的关键字段
  scaffold_fields=("preferences.backend.preferred" "preferences.frontend.preferred" "preferences.database.preferred")
  for field in "${scaffold_fields[@]}"; do
    if python3 -c "
import yaml
data = yaml.safe_load(open('$SPEC_FILE'))
keys = '$field'.split('.')
obj = data
for k in keys:
    if isinstance(obj, dict) and k in obj:
        obj = obj[k]
    else:
        exit(1)
if obj is None:
    exit(1)
" 2>/dev/null; then
      echo "[通过] $field 已填写"
    else
      echo "[警告] $field 未填写，scaffold 生成时将使用默认值"
      warnings=$((warnings + 1))
    fi
  done
else
  echo "[跳过] 未安装 python3 或 PyYAML，跳过字段级校验"
  echo "[提示] 安装 python3 和 PyYAML 后可执行更详细的校验"
fi

# 输出结果
echo ""
echo "=============================="
echo "  校验结果"
echo "=============================="
echo ""
echo "  错误：$errors"
echo "  警告：$warnings"
echo ""

if [[ $errors -gt 0 ]]; then
  echo "[失败] 存在必须修复的问题，请根据提示修正后重新校验。"
  echo "[下一步] 修正后重新执行：make validate"
  exit 1
elif [[ $warnings -gt 0 ]]; then
  echo "[通过] 必填项完整，但存在建议改进项。"
  echo "[下一步] 你可以直接执行：make scaffold 生成项目骨架"
  exit 0
else
  echo "[通过] 校验完全通过。"
  echo "[下一步] 你可以执行：make scaffold 生成项目骨架"
  exit 0
fi
