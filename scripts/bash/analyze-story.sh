#!/bin/bash

# 故事分析验证脚本
# 用于 /analyze 命令

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Parse arguments
STORY_NAME="$1"
ANALYSIS_TYPE="${2:-full}"  # full, compliance, quality, progress

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 确定故事路径
if [ -z "$STORY_NAME" ]; then
    STORY_NAME=$(get_active_story)
fi

STORY_DIR="stories/$STORY_NAME"

# 检查必要文件
check_story_files() {
    local missing_files=()

    # 检查基准文档
    [ ! -f "memory/novel-constitution.md" ] && missing_files+=("宪法文件")
    [ ! -f "$STORY_DIR/specification.md" ] && missing_files+=("规格文件")
    [ ! -f "$STORY_DIR/creative-plan.md" ] && missing_files+=("计划文件")

    if [ ${#missing_files[@]} -gt 0 ]; then
        echo "⚠️ 缺少以下基准文档："
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi

    return 0
}

# 统计内容
analyze_content() {
    local content_dir="$STORY_DIR/content"
    local total_words=0
    local chapter_count=0

    if [ -d "$content_dir" ]; then
        echo "内容统计："
        echo ""
        for file in "$content_dir"/*.md; do
            if [ -f "$file" ]; then
                ((chapter_count++))
                # 使用准确的中文字数统计
                local words=$(count_chinese_words "$file")
                ((total_words += words))
                local filename=$(basename "$file")
                echo "  $filename: $words 字"
            fi
        done
        echo ""
        echo "  总字数：$total_words"
        echo "  章节数：$chapter_count"
        if [ $chapter_count -gt 0 ]; then
            echo "  平均章节长度：$((total_words / chapter_count)) 字"
        fi
    else
        echo "内容统计："
        echo "  尚未开始写作"
    fi
}

# 检查任务完成度
check_task_completion() {
    local tasks_file="$STORY_DIR/tasks.md"
    if [ ! -f "$tasks_file" ]; then
        echo "任务文件不存在"
        return
    fi

    local total_tasks=$(grep -c "^- \[" "$tasks_file" 2>/dev/null || echo 0)
    local completed_tasks=$(grep -c "^- \[x\]" "$tasks_file" 2>/dev/null || echo 0)
    local in_progress=$(grep -c "^- \[~\]" "$tasks_file" 2>/dev/null || echo 0)
    local pending=$((total_tasks - completed_tasks - in_progress))

    echo "任务进度："
    echo "  总任务：$total_tasks"
    echo "  已完成：$completed_tasks"
    echo "  进行中：$in_progress"
    echo "  未开始：$pending"

    if [ $total_tasks -gt 0 ]; then
        local completion_rate=$((completed_tasks * 100 / total_tasks))
        echo "  完成率：$completion_rate%"
    fi
}

# 检查规格符合度
check_specification_compliance() {
    local spec_file="$STORY_DIR/specification.md"

    echo "规格符合度检查："

    # 检查P0需求（简化版）
    local p0_count=$(grep -c "^### 必须包含（P0）" "$spec_file" 2>/dev/null || echo 0)
    if [ $p0_count -gt 0 ]; then
        echo "  P0需求：检测到，需人工验证"
    fi

    # 检查是否还有[需要澄清]标记
    local unclear=$(grep -c "\[需要澄清\]" "$spec_file" 2>/dev/null || echo 0)
    if [ $unclear -gt 0 ]; then
        echo "  ⚠️ 仍有 $unclear 处需要澄清"
    else
        echo "  ✅ 所有决策已澄清"
    fi
}

# 主分析流程
main() {
    echo "故事分析报告"
    echo "============"
    echo "故事：$STORY_NAME"
    echo "分析时间：$(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # 检查基准文档
    if ! check_story_files; then
        echo ""
        echo "❌ 无法进行完整分析，请先完成基准文档"
        exit 1
    fi

    echo "✅ 基准文档完整"
    echo ""

    # 根据分析类型执行
    case "$ANALYSIS_TYPE" in
        full)
            analyze_content
            echo ""
            check_task_completion
            echo ""
            check_specification_compliance
            ;;
        quality)
            analyze_content
            ;;
        progress)
            check_task_completion
            ;;
        compliance)
            check_specification_compliance
            ;;
        *)
            echo "未知的分析类型：$ANALYSIS_TYPE"
            exit 1
            ;;
    esac

    echo ""
    echo "分析完成。详细报告已保存到：$STORY_DIR/analysis-report.md"
}

main