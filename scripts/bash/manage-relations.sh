#!/usr/bin/env bash
# 角色关系管理（Bash）

set -e

SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

PROJECT_ROOT=$(get_project_root)
STORY_DIR=$(get_current_story)

REL_FILE=""
if [ -n "$STORY_DIR" ] && [ -f "$STORY_DIR/spec/tracking/relationships.json" ]; then
  REL_FILE="$STORY_DIR/spec/tracking/relationships.json"
elif [ -f "$PROJECT_ROOT/spec/tracking/relationships.json" ]; then
  REL_FILE="$PROJECT_ROOT/spec/tracking/relationships.json"
else
  # 尝试用模板初始化
  mkdir -p "$PROJECT_ROOT/spec/tracking"
  if [ -f "$PROJECT_ROOT/.specify/templates/tracking/relationships.json" ]; then
    cp "$PROJECT_ROOT/.specify/templates/tracking/relationships.json" "$PROJECT_ROOT/spec/tracking/relationships.json"
    REL_FILE="$PROJECT_ROOT/spec/tracking/relationships.json"
  elif [ -f "$SCRIPT_DIR/../../templates/tracking/relationships.json" ]; then
    cp "$SCRIPT_DIR/../../templates/tracking/relationships.json" "$PROJECT_ROOT/spec/tracking/relationships.json"
    REL_FILE="$PROJECT_ROOT/spec/tracking/relationships.json"
  else
    echo "❌ 未找到 relationships.json，且无法从模板创建" >&2
    exit 1
  fi
fi

CMD=${1:-show}
shift || true

print_header() {
  echo "👥 角色关系管理"
  echo "━━━━━━━━━━━━━━━━━━━━"
}

cmd_show() {
  print_header
  if ! jq empty "$REL_FILE" >/dev/null 2>&1; then
    echo "❌ relationships.json 格式无效" >&2; exit 1
  fi

  echo "文件：$REL_FILE"
  echo ""
  # 输出主角或首个角色关系摘要
  local main_char=$(jq -r '.characters | keys[0] // ""' "$REL_FILE")
  if [ -z "$main_char" ] || [ "$main_char" = "null" ]; then
    echo "无角色记录"
    exit 0
  fi
  echo "主角：$main_char"
  # 支持两种结构：嵌套 relationships 或直接分类键
  jq -r --arg name "$main_char" '
    .characters[$name] as $c | 
    ($c.relationships // $c) as $r |
    [
      {k:"romantic", v:($r.romantic // [])},
      {k:"allies", v:($r.allies // [])},
      {k:"mentors", v:($r.mentors // [])},
      {k:"enemies", v:($r.enemies // [])},
      {k:"family", v:($r.family // [])},
      {k:"neutral", v:($r.neutral // [])}
    ] | .[] | select((.v|length)>0) |
    "├─ " + (if .k=="romantic" then "💕 爱慕" elseif .k=="allies" then "🤝 盟友" elseif .k=="mentors" then "📚 导师" elseif .k=="enemies" then "⚔️ 敌对" elseif .k=="family" then "👪 家人" else "・ 关系" end) + "：" + (.v | join("、"))
  ' "$REL_FILE"

  # 最近变化
  echo ""
  if jq -e '.history' "$REL_FILE" >/dev/null 2>&1; then
    local recent=$(jq -r '.history[-1] // empty' "$REL_FILE")
    if [ -n "$recent" ]; then
      echo "最近变化："
      jq -r '.history[-1].changes[]? | "- " + (.characters|join("↔")) + "：" + (.relation // .type // "变化")' "$REL_FILE"
    fi
  elif jq -e '.relationshipChanges' "$REL_FILE" >/dev/null 2>&1; then
    echo "最近变化："
    jq -r '.relationshipChanges[-5:][]? | "- " + (.type // "变化") + ": " + (.characters|join("↔"))' "$REL_FILE" 2>/dev/null || true
  fi
}

cmd_update() {
  local a="$1"; local rel="$2"; local b="$3"; shift 3 || true
  local chapter=""; local note=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --chapter) chapter="$2"; shift 2;;
      --note) note="$2"; shift 2;;
      *) shift;;
    esac
  done
  if [ -z "$a" ] || [ -z "$rel" ] || [ -z "$b" ]; then
    echo "用法: manage-relations.sh update <人物A> <allies|enemies|romantic|neutral|family|mentors> <人物B> [--chapter N] [--note 说明]" >&2
    exit 1
  fi

  # 确保角色节点存在
  for name in "$a" "$b"; do
    if ! jq --arg n "$name" '(.characters[$n] // null) != null' "$REL_FILE" | grep -q true; then
      tmp=$(mktemp)
      jq --arg n "$name" '.characters[$n] = (.characters[$n] // {name:$n, relationships:{allies:[],enemies:[],romantic:[],family:[],mentors:[],neutral:[]}})' "$REL_FILE" > "$tmp"
      mv "$tmp" "$REL_FILE"
    fi
  done

  # 写入关系
  tmp=$(mktemp)
  jq --arg a "$a" --arg b "$b" --arg rel "$rel" '
    .characters[$a].relationships[$rel] = ((.characters[$a].relationships[$rel] // []) + [$b] | unique) |
    .lastUpdated = now | todate
  ' "$REL_FILE" > "$tmp"
  mv "$tmp" "$REL_FILE"

  # 记录历史（history 优先，否则 relationshipChanges）
  local now=$(date -Iseconds)
  if jq -e '.history' "$REL_FILE" >/dev/null 2>&1; then
    tmp=$(mktemp)
    jq --arg ch "${chapter:-null}" --arg a "$a" --arg b "$b" --arg rel "$rel" --arg note "$note" --arg t "$now" '
      .history += [{
        chapter: ( ($ch|tonumber) // null ),
        date: $t,
        changes: [{ type: "update", characters: [$a,$b], relation: $rel, note: ($note // "") }]
      }]
    ' "$REL_FILE" > "$tmp" && mv "$tmp" "$REL_FILE"
  else
    tmp=$(mktemp)
    jq --arg a "$a" --arg b "$b" --arg rel "$rel" '.relationshipChanges += [{type:"update", characters:[$a,$b], relation:$rel}]' "$REL_FILE" > "$tmp" && mv "$tmp" "$REL_FILE"
  fi

  echo "✅ 已更新关系：$a [$rel] $b"
}

cmd_history() {
  print_header
  if jq -e '.history' "$REL_FILE" >/dev/null 2>&1; then
    jq -r '.history[] | "第" + ((.chapter // 0|tostring)) + "章：" + (.changes | map((.characters|join("↔"))+"→"+(.relation // .type)) | join("；"))' "$REL_FILE"
  elif jq -e '.relationshipChanges' "$REL_FILE" >/dev/null 2>&1; then
    jq -r '.relationshipChanges[] | (.date // "") + " " + (.type // "") + ": " + (.characters|join("↔")) + "→" + (.relation // "")' "$REL_FILE"
  else
    echo "暂无历史记录"
  fi
}

cmd_check() {
  print_header
  local issues=0
  # 检查所有引用角色是否存在于 characters
  missing=$(jq -r '
    .characters as $c |
    [
      .characters | to_entries[] | .value.relationships // empty |
      to_entries[] | .value[]
    ] | flatten | unique | map(select(has(.) | not))
  ' "$REL_FILE" 2>/dev/null || true)
  if [ -n "$missing" ]; then
    echo "⚠️  发现未建档角色引用，建议补充："
    echo "$missing"
    issues=1
  fi
  if [ "$issues" -eq 0 ]; then
    echo "✅ 关系数据检查通过"
  fi
}

case "$CMD" in
  show) cmd_show ;;
  update) cmd_update "$@" ;;
  history) cmd_history ;;
  check) cmd_check ;;
  *) echo "用法: $0 [show|update|history|check]" >&2; exit 1;;
esac

