#!/bin/bash

# 检查写作状态脚本
# 用于 /write 命令

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 获取当前故事
STORY_NAME=$(get_active_story)
STORY_DIR="stories/$STORY_NAME"

echo "写作状态检查"
echo "============"
echo "当前故事：$STORY_NAME"
echo ""

# 检查方法论文档
check_methodology_docs() {
    local missing=()

    [ ! -f "memory/novel-constitution.md" ] && missing+=("宪法")
    [ ! -f "$STORY_DIR/specification.md" ] && missing+=("规格")
    [ ! -f "$STORY_DIR/creative-plan.md" ] && missing+=("计划")
    [ ! -f "$STORY_DIR/tasks.md" ] && missing+=("任务")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "⚠️ 缺少以下基准文档："
        for doc in "${missing[@]}"; do
            echo "  - $doc"
        done
        echo ""
        echo "建议按照七步方法论完成前置步骤："
        echo "1. /constitution - 创建创作宪法"
        echo "2. /specify - 定义故事规格"
        echo "3. /clarify - 澄清关键决策"
        echo "4. /plan - 制定创作计划"
        echo "5. /tasks - 生成任务清单"
        return 1
    fi

    echo "✅ 方法论文档完整"
    return 0
}

# 检查待写作任务
check_pending_tasks() {
    local tasks_file="$STORY_DIR/tasks.md"

    if [ ! -f "$tasks_file" ]; then
        echo "❌ 任务文件不存在"
        return 1
    fi

    # 统计任务状态
    local pending=$(grep -c "^- \[ \]" "$tasks_file" 2>/dev/null || echo 0)
    local in_progress=$(grep -c "^- \[~\]" "$tasks_file" 2>/dev/null || echo 0)
    local completed=$(grep -c "^- \[x\]" "$tasks_file" 2>/dev/null || echo 0)

    echo ""
    echo "任务状态："
    echo "  待开始：$pending"
    echo "  进行中：$in_progress"
    echo "  已完成：$completed"

    if [ $pending -eq 0 ] && [ $in_progress -eq 0 ]; then
        echo ""
        echo "🎉 所有任务已完成！"
        echo "建议运行 /analyze 进行综合验证"
        return 0
    fi

    # 显示下一个待写作任务
    echo ""
    echo "下一个写作任务："
    grep "^- \[ \]" "$tasks_file" | head -n 1 || echo "（无待处理任务）"
}

# 检查已完成内容
check_completed_content() {
    local content_dir="$STORY_DIR/content"

    if [ -d "$content_dir" ]; then
        local chapter_count=$(ls "$content_dir"/*.md 2>/dev/null | wc -l)
        if [ $chapter_count -gt 0 ]; then
            echo ""
            echo "已完成章节：$chapter_count"
            echo "最近写作："
            ls -lt "$content_dir"/*.md 2>/dev/null | head -n 3 | awk '{print "  -", $9}'
        fi
    else
        echo ""
        echo "尚未开始写作"
    fi
}

# 主流程
main() {
    if ! check_methodology_docs; then
        exit 1
    fi

    check_pending_tasks
    check_completed_content

    echo ""
    echo "准备就绪，可以开始写作"
}

main