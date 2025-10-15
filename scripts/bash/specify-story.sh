#!/bin/bash

# 故事规格定义脚本
# 用于 /specify 命令

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
JSON_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            JSON_MODE=true
            shift
            ;;
        *)
            STORY_NAME="$1"
            shift
            ;;
    esac
done

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 确定故事名称和路径
if [ -z "$STORY_NAME" ]; then
    # 查找最新的故事
    STORIES_DIR="stories"
    if [ -d "$STORIES_DIR" ] && [ "$(ls -A $STORIES_DIR 2>/dev/null)" ]; then
        STORY_DIR=$(find "$STORIES_DIR" -maxdepth 1 -type d ! -name "stories" | sort -r | head -n 1)
        if [ -n "$STORY_DIR" ]; then
            STORY_NAME=$(basename "$STORY_DIR")
        fi
    fi

    # 如果还是没有，生成默认名称
    if [ -z "$STORY_NAME" ]; then
        STORY_NAME="story-$(date +%Y%m%d)"
    fi
fi

# 设置路径
STORY_DIR="stories/$STORY_NAME"
SPEC_FILE="$STORY_DIR/specification.md"

# 创建目录
mkdir -p "$STORY_DIR"

# 检查文件状态
SPEC_EXISTS=false
STATUS="new"

if [ -f "$SPEC_FILE" ]; then
    SPEC_EXISTS=true
    STATUS="exists"
fi

# 输出 JSON 格式
if [ "$JSON_MODE" = true ]; then
    cat <<EOF
{
    "STORY_NAME": "$STORY_NAME",
    "STORY_DIR": "$STORY_DIR",
    "SPEC_PATH": "$SPEC_FILE",
    "STATUS": "$STATUS",
    "PROJECT_ROOT": "$PROJECT_ROOT"
}
EOF
else
    echo "故事规格初始化"
    echo "================"
    echo "故事名称：$STORY_NAME"
    echo "规格路径：$SPEC_FILE"

    if [ "$SPEC_EXISTS" = true ]; then
        echo "状态：规格文件已存在，准备更新"
    else
        echo "状态：准备创建新规格"
    fi

    # 检查宪法
    if [ -f "memory/constitution.md" ]; then
        echo ""
        echo "✅ 检测到创作宪法，规格将遵循宪法原则"
    fi
fi