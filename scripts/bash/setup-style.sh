#!/usr/bin/env bash
# 设置创作风格

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 获取项目根目录
PROJECT_ROOT=$(get_project_root)
MEMORY_DIR="$PROJECT_ROOT/.specify/memory"

# 创建 memory 目录
mkdir -p "$MEMORY_DIR"

# 创建或更新创作准则文件
CONSTITUTION_FILE="$MEMORY_DIR/writing-constitution.md"
TEMPLATE="$PROJECT_ROOT/.specify/templates/writing-constitution-template.md"

ensure_file "$CONSTITUTION_FILE" "$TEMPLATE"

# 输出结果
echo "CONSTITUTION_FILE: $CONSTITUTION_FILE"
echo "STATUS: ready"

# 可选：融合个人语料摘要，增强个体表达一致性
PV_FILE="$PROJECT_ROOT/.specify/memory/personal-voice.md"
if [ -f "$PV_FILE" ]; then
  TMP="/tmp/pv_summary_$$.md"
  echo "" > "$TMP"
  echo "## 个人语料摘要（自动引用）" >> "$TMP"
  echo "来源：.specify/memory/personal-voice.md" >> "$TMP"
  echo "" >> "$TMP"
  awk '
      /^## / { if(h>6) exit; h++; if(cnt>0) {print ""}; print $0; lc=0; next }
      /^- / && lc<2 { print $0; lc++; next }
  ' "$PV_FILE" >> "$TMP"
  if ! grep -q "个人语料摘要（自动引用）" "$CONSTITUTION_FILE"; then
    echo "" >> "$CONSTITUTION_FILE"
    cat "$TMP" >> "$CONSTITUTION_FILE"
    echo "PERSONAL_VOICE: merged"
  fi
  rm -f "$TMP"
fi

# 固定专章：个人表达基线（自动同步）
if [ -f "$PV_FILE" ]; then
  TMP2="/tmp/pv_baseline_$$.md"
  echo "<!-- BEGIN: PERSONAL_BASELINE_AUTO -->" > "$TMP2"
  echo "## 个人表达基线（自动同步）" >> "$TMP2"
  echo "来源：.specify/memory/personal-voice.md（只读镜像，修改请在源文件）" >> "$TMP2"
  echo "" >> "$TMP2"
  awk -v t="口头禅与常用表达" -v n=6 '
      BEGIN{hit=0;cnt=0}
      $0 ~ "^## " t "$" {hit=1; next}
      hit==1 && $0 ~ /^## / {hit=0}
      hit==1 && $0 ~ /^- / && cnt<n {print $0; cnt++}
  ' "$PV_FILE" >> "$TMP2"
  echo "" >> "$TMP2"
  awk -v t="固定句式与节奏偏好" -v n=6 '
      BEGIN{hit=0;cnt=0}
      $0 ~ "^## " t "$" {hit=1; next}
      hit==1 && $0 ~ /^## / {hit=0}
      hit==1 && $0 ~ /^- / && cnt<n {print $0; cnt++}
  ' "$PV_FILE" >> "$TMP2"
  echo "" >> "$TMP2"
  awk -v t="行业/地域词汇（口音、俚语、术语）" -v n=6 '
      BEGIN{hit=0;cnt=0}
      $0 ~ "^## " t "$" {hit=1; next}
      hit==1 && $0 ~ /^## / {hit=0}
      hit==1 && $0 ~ /^- / && cnt<n {print $0; cnt++}
  ' "$PV_FILE" >> "$TMP2"
  echo "" >> "$TMP2"
  awk -v t="比喻口味与意象库" -v n=8 '
      BEGIN{hit=0;cnt=0}
      $0 ~ "^## " t "$" {hit=1; next}
      hit==1 && $0 ~ /^## / {hit=0}
      hit==1 && $0 ~ /^- / && cnt<n {print $0; cnt++}
  ' "$PV_FILE" >> "$TMP2"
  echo "" >> "$TMP2"
  awk -v t="写作忌口与避讳" -v n=6 '
      BEGIN{hit=0;cnt=0}
      $0 ~ "^## " t "$" {hit=1; next}
      hit==1 && $0 ~ /^## / {hit=0}
      hit==1 && $0 ~ /^- / && cnt<n {print $0; cnt++}
  ' "$PV_FILE" >> "$TMP2"
  echo "<!-- END: PERSONAL_BASELINE_AUTO -->" >> "$TMP2"

  if grep -q "<!-- BEGIN: PERSONAL_BASELINE_AUTO -->" "$CONSTITUTION_FILE"; then
    awk -v RS='' -v ORS='\n\n' -v file="$TMP2" '
        BEGIN{while((getline l<file)>0){blk=blk l "\n"}}
        { gsub(/<!-- BEGIN: PERSONAL_BASELINE_AUTO -->[\s\S]*<!-- END: PERSONAL_BASELINE_AUTO -->/, blk) }1
    ' "$CONSTITUTION_FILE" > "$CONSTITUTION_FILE.tmp" && mv "$CONSTITUTION_FILE.tmp" "$CONSTITUTION_FILE"
  else
    echo "" >> "$CONSTITUTION_FILE"
    cat "$TMP2" >> "$CONSTITUTION_FILE"
  fi
  rm -f "$TMP2"
fi
