#!/usr/bin/env bash
# 创建新故事项目

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 解析参数
JSON_MODE=false
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --help|-h) echo "用法: $0 [--json] <故事描述>"; exit 0 ;;
        *) ARGS+=("$arg") ;;
    esac
done

STORY_DESCRIPTION="${ARGS[*]}"
if [ -z "$STORY_DESCRIPTION" ]; then
    echo "用法: $0 [--json] <故事描述>" >&2
    exit 1
fi

# 获取项目根目录
PROJECT_ROOT=$(get_project_root)
STORIES_DIR="$PROJECT_ROOT/stories"

# 创建带编号的故事目录
STORY_NUM=$(create_numbered_dir "$STORIES_DIR" "story")

# 生成故事目录名
STORY_NAME=$(echo "$STORY_DESCRIPTION" | tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9\u4e00-\u9fa5]/-/g' | sed 's/-\+/-/g' | \
    sed 's/^-//' | sed 's/-$//' | head -c 20)

STORY_DIR_NAME="${STORY_NUM}-${STORY_NAME}"
STORY_DIR="$STORIES_DIR/$STORY_DIR_NAME"

# 创建故事目录结构
mkdir -p "$STORY_DIR"
mkdir -p "$STORY_DIR/chapters"
mkdir -p "$STORY_DIR/characters"
mkdir -p "$STORY_DIR/world"
mkdir -p "$STORY_DIR/notes"

# 复制模板文件
TEMPLATE="$PROJECT_ROOT/.specify/templates/story-template.md"
STORY_FILE="$STORY_DIR/story.md"
ensure_file "$STORY_FILE" "$TEMPLATE"

# 输出结果
if $JSON_MODE; then
    printf '{"STORY_NAME":"%s","STORY_FILE":"%s","STORY_NUM":"%s","STORY_DIR":"%s"}\n' \
        "$STORY_DIR_NAME" "$STORY_FILE" "$STORY_NUM" "$STORY_DIR"
else
    echo "STORY_NAME: $STORY_DIR_NAME"
    echo "STORY_FILE: $STORY_FILE"
    echo "STORY_NUM: $STORY_NUM"
    echo "STORY_DIR: $STORY_DIR"
fi