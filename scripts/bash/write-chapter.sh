#!/usr/bin/env bash
# 写作章节

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 获取当前故事目录
STORY_DIR=$(get_current_story)

if [ -z "$STORY_DIR" ]; then
    echo "错误: 未找到故事项目" >&2
    exit 1
fi

# 检查前置条件
if [ ! -f "$STORY_DIR/outline.md" ]; then
    echo "错误: 未找到章节规划，请先使用 /outline 命令" >&2
    exit 1
fi

# 确定要写作的章节（可以通过参数传入，或自动找下一章）
CHAPTER_NUM="${1:-}"

# 确定章节所属卷册
determine_volume() {
    local chapter=$1
    if [ "$chapter" -le 60 ]; then
        echo "volume-1"
    elif [ "$chapter" -le 120 ]; then
        echo "volume-2"
    elif [ "$chapter" -le 180 ]; then
        echo "volume-3"
    else
        echo "volume-4"
    fi
}

if [ -z "$CHAPTER_NUM" ]; then
    # 自动查找下一个未写的章节
    CHAPTER_NUM=1
    found=false
    while [ "$CHAPTER_NUM" -le 240 ] && [ "$found" = false ]; do
        VOLUME=$(determine_volume "$CHAPTER_NUM")
        CHAPTER_FMT=$(printf "%03d" "$CHAPTER_NUM")
        if [ ! -f "$STORY_DIR/chapters/$VOLUME/chapter-${CHAPTER_FMT}.md" ]; then
            found=true
        else
            CHAPTER_NUM=$((CHAPTER_NUM + 1))
        fi
    done
fi

# 格式化章节编号并确定所属卷册
CHAPTER_NUM_FMT=$(printf "%03d" "$CHAPTER_NUM")
VOLUME_DIR=$(determine_volume "$CHAPTER_NUM")
CHAPTER_FILE="$STORY_DIR/chapters/$VOLUME_DIR/chapter-${CHAPTER_NUM_FMT}.md"

# 创建章节文件（包括卷册目录）
mkdir -p "$(dirname "$CHAPTER_FILE")"
touch "$CHAPTER_FILE"

# 更新进度
PROGRESS_FILE="$STORY_DIR/progress.json"
if [ -f "$PROGRESS_FILE" ]; then
    # 这里应该更新 JSON，简化处理
    echo "已创建章节文件: $CHAPTER_FILE" >&2
fi

# 输出结果
echo "CHAPTER_FILE: $CHAPTER_FILE"
echo "CHAPTER_NUM: $CHAPTER_NUM"
echo "VOLUME: $VOLUME_DIR"
echo "STATUS: ready"