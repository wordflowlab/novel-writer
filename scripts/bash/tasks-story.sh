#!/bin/bash

# 任务分解脚本
# 用于 /tasks 命令

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
STORY_NAME=""
if [ $# -gt 0 ]; then
    STORY_NAME="$1"
fi

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 确定故事名称
if [ -z "$STORY_NAME" ]; then
    STORY_NAME=$(get_active_story)
fi

STORY_DIR="stories/$STORY_NAME"
SPEC_FILE="$STORY_DIR/specification.md"
PLAN_FILE="$STORY_DIR/creative-plan.md"
TASKS_FILE="$STORY_DIR/tasks.md"

echo "任务分解"
echo "========"
echo "故事：$STORY_NAME"
echo ""

# 检查前置文档
missing=()

if [ ! -f "memory/constitution.md" ]; then
    missing+=("宪法文件")
fi

if [ ! -f "$SPEC_FILE" ]; then
    missing+=("规格文件")
fi

if [ ! -f "$PLAN_FILE" ]; then
    missing+=("计划文件")
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo "⚠️ 缺少以下前置文档："
    for doc in "${missing[@]}"; do
        echo "  - $doc"
    done
    echo ""
    echo "请先完成："
    if [ ! -f "memory/constitution.md" ]; then
        echo "  1. /constitution - 创建创作宪法"
    fi
    if [ ! -f "$SPEC_FILE" ]; then
        echo "  2. /specify - 定义故事规格"
    fi
    if [ ! -f "$PLAN_FILE" ]; then
        echo "  3. /plan - 制定创作计划"
    fi
    exit 1
fi

# 检查任务文件
if [ -f "$TASKS_FILE" ]; then
    echo ""
    echo "📋 任务文件已存在，将更新现有任务"

    # 显示任务统计
    total_tasks=$(grep -c "^- \[" "$TASKS_FILE" 2>/dev/null || echo "0")
    completed_tasks=$(grep -c "^- \[x\]" "$TASKS_FILE" 2>/dev/null || echo "0")
    echo "  总任务数：$total_tasks"
    echo "  已完成：$completed_tasks"
else
    echo ""
    echo "📝 将创建新的任务清单"
fi

echo ""
echo "任务文件路径：$TASKS_FILE"
echo ""
echo "准备就绪，可以分解任务"
echo ""
echo "任务分解将包括："
echo "  - 章节写作任务（基于计划）"
echo "  - 角色档案完善"
echo "  - 世界观文档补充"
echo "  - 质量检查节点"
echo "  - 验证和修订任务"