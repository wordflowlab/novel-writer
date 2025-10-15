#!/bin/bash

# 创作计划脚本
# 用于 /plan 命令

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
CLARIFY_FILE="$STORY_DIR/clarification.md"
PLAN_FILE="$STORY_DIR/creative-plan.md"

echo "创作计划制定"
echo "============"
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
    exit 1
fi

# 检查是否有未澄清的点
if [ -f "$SPEC_FILE" ]; then
    unclear_count=$(grep -o '\[需要澄清\]' "$SPEC_FILE" | wc -l | tr -d ' ')

    if [ "$unclear_count" -gt 0 ]; then
        echo "⚠️ 规格中有 $unclear_count 处需要澄清"
        echo "建议先运行 /clarify 澄清关键决策"
        echo ""
    fi
fi

# 检查澄清记录
if [ -f "$CLARIFY_FILE" ]; then
    echo "✅ 已完成澄清，将基于澄清决策制定计划"
else
    echo "📝 未找到澄清记录，将基于原始规格制定计划"
fi

# 检查计划文件
if [ -f "$PLAN_FILE" ]; then
    echo ""
    echo "📋 计划文件已存在，将更新现有计划"

    # 显示当前版本
    if grep -q "版本：" "$PLAN_FILE"; then
        version=$(grep "版本：" "$PLAN_FILE" | head -1 | sed 's/.*版本：//')
        echo "  当前版本：$version"
    fi
else
    echo ""
    echo "📝 将创建新的创作计划"
fi

echo ""
echo "计划文件路径：$PLAN_FILE"
echo ""
echo "准备就绪，可以制定创作计划"