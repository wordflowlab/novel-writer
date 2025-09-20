#!/usr/bin/env bash
# 生成写作任务

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
if [ ! -f "$STORY_DIR/story.md" ]; then
    echo "错误: 未找到故事大纲，请先使用 /story 命令" >&2
    exit 1
fi

if [ ! -f "$STORY_DIR/outline.md" ]; then
    echo "错误: 未找到章节规划，请先使用 /outline 命令" >&2
    exit 1
fi

# 创建任务文件
TASKS_FILE="$STORY_DIR/tasks.md"
touch "$TASKS_FILE"

# 创建进度追踪文件
PROGRESS_FILE="$STORY_DIR/progress.json"
if [ ! -f "$PROGRESS_FILE" ]; then
    echo '{"total_chapters":0,"completed":0,"in_progress":0,"word_count":0}' > "$PROGRESS_FILE"
fi

# 输出结果
echo "TASKS_FILE: $TASKS_FILE"
echo "PROGRESS_FILE: $PROGRESS_FILE"
echo "STATUS: ready"