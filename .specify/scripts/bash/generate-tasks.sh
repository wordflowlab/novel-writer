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

# 获取当前日期
CURRENT_DATE=$(date '+%Y-%m-%d')
CURRENT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')

# 创建任务文件，预先填充基础信息
TASKS_FILE="$STORY_DIR/tasks.md"
cat > "$TASKS_FILE" << EOF
# 写作任务清单

## 任务概览
- **创建日期**：${CURRENT_DATE}
- **最后更新**：${CURRENT_DATE}
- **任务状态**：待生成

---
EOF

# 创建进度追踪文件
PROGRESS_FILE="$STORY_DIR/progress.json"
if [ ! -f "$PROGRESS_FILE" ]; then
    cat > "$PROGRESS_FILE" << EOF
{
  "created_at": "${CURRENT_DATETIME}",
  "updated_at": "${CURRENT_DATETIME}",
  "total_chapters": 0,
  "completed": 0,
  "in_progress": 0,
  "word_count": 0
}
EOF
fi

# 输出结果
echo "TASKS_FILE: $TASKS_FILE"
echo "PROGRESS_FILE: $PROGRESS_FILE"
echo "CURRENT_DATE: $CURRENT_DATE"
echo "STATUS: ready"