#!/bin/bash

# 澄清故事大纲的支撑脚本
# 用于 /clarify 命令，扫描并返回当前故事路径

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
JSON_MODE=false
PATHS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --json)
            JSON_MODE=true
            shift
            ;;
        --paths-only)
            PATHS_ONLY=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# Find the current story directory
STORIES_DIR="stories"
if [ ! -d "$STORIES_DIR" ]; then
    if [ "$JSON_MODE" = true ]; then
        echo '{"error": "No stories directory found"}'
    else
        echo "错误：未找到 stories 目录，请先运行 /story 创建故事大纲"
    fi
    exit 1
fi

# Get the latest story (assuming single story for now, can be enhanced)
STORY_DIR=$(find "$STORIES_DIR" -maxdepth 1 -type d ! -name "stories" | sort -r | head -n 1)

if [ -z "$STORY_DIR" ]; then
    if [ "$JSON_MODE" = true ]; then
        echo '{"error": "No story found"}'
    else
        echo "错误：未找到故事，请先运行 /story 创建故事大纲"
    fi
    exit 1
fi

# Extract story name from directory
STORY_NAME=$(basename "$STORY_DIR")

# Find story.md file
STORY_FILE="$STORY_DIR/story.md"
if [ ! -f "$STORY_FILE" ]; then
    if [ "$JSON_MODE" = true ]; then
        echo '{"error": "Story file not found"}'
    else
        echo "错误：未找到故事文件 $STORY_FILE"
    fi
    exit 1
fi

# Check if clarification already exists
CLARIFICATION_EXISTS=false
if grep -q "## 澄清记录" "$STORY_FILE" 2>/dev/null; then
    CLARIFICATION_EXISTS=true
fi

# Count existing clarification sessions
CLARIFICATION_COUNT=0
if [ "$CLARIFICATION_EXISTS" = true ]; then
    CLARIFICATION_COUNT=$(grep -c "### 澄清会话" "$STORY_FILE" 2>/dev/null || echo "0")
fi

# Output in JSON format if requested
if [ "$JSON_MODE" = true ]; then
    if [ "$PATHS_ONLY" = true ]; then
        # Minimal output for command template
        cat <<EOF
{
    "STORY_PATH": "$STORY_FILE",
    "STORY_NAME": "$STORY_NAME",
    "STORY_DIR": "$STORY_DIR"
}
EOF
    else
        # Full output for analysis
        cat <<EOF
{
    "STORY_PATH": "$STORY_FILE",
    "STORY_NAME": "$STORY_NAME",
    "STORY_DIR": "$STORY_DIR",
    "CLARIFICATION_EXISTS": $CLARIFICATION_EXISTS,
    "CLARIFICATION_COUNT": $CLARIFICATION_COUNT,
    "PROJECT_ROOT": "$PROJECT_ROOT"
}
EOF
    fi
else
    echo "找到故事：$STORY_NAME"
    echo "文件路径：$STORY_FILE"
    if [ "$CLARIFICATION_EXISTS" = true ]; then
        echo "已有澄清会话：$CLARIFICATION_COUNT 次"
    else
        echo "尚未进行过澄清"
    fi
fi