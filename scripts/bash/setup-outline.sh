#!/usr/bin/env bash
# 设置章节大纲

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 获取当前故事目录
STORY_DIR=$(get_current_story)

if [ -z "$STORY_DIR" ]; then
    echo "错误: 未找到故事项目，请先使用 /story 命令创建故事" >&2
    exit 1
fi

# 创建大纲文件
OUTLINE_FILE="$STORY_DIR/outline.md"
TEMPLATE="$PROJECT_ROOT/templates/outline-template.md"

ensure_file "$OUTLINE_FILE" "$TEMPLATE"

# 创建章节目录结构
mkdir -p "$STORY_DIR/chapters/volume-1"

# 输出结果
echo "OUTLINE_FILE: $OUTLINE_FILE"
echo "STORY_DIR: $STORY_DIR"
echo "STATUS: ready"