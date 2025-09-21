#!/usr/bin/env bash
# 检查情节发展的一致性和连贯性

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

# 文件路径
PLOT_TRACKER="$STORY_DIR/spec/tracking/plot-tracker.json"
OUTLINE="$STORY_DIR/outline.md"
PROGRESS="$STORY_DIR/progress.json"

# 检查必要文件
check_required_files() {
    local missing=false

    if [ ! -f "$PLOT_TRACKER" ]; then
        echo "⚠️  未找到情节追踪文件，正在创建..." >&2
        mkdir -p "$STORY_DIR/spec/tracking"
        # 复制模板
        if [ -f "$SCRIPT_DIR/../../templates/tracking/plot-tracker.json" ]; then
            cp "$SCRIPT_DIR/../../templates/tracking/plot-tracker.json" "$PLOT_TRACKER"
        else
            echo "错误: 无法找到模板文件" >&2
            exit 1
        fi
    fi

    if [ ! -f "$OUTLINE" ]; then
        echo "错误: 未找到章节大纲 (outline.md)" >&2
        echo "请先使用 /outline 命令创建大纲" >&2
        exit 1
    fi
}

# 读取当前进度
get_current_progress() {
    if [ -f "$PROGRESS" ]; then
        CURRENT_CHAPTER=$(jq -r '.statistics.currentChapter // 1' "$PROGRESS")
        CURRENT_VOLUME=$(jq -r '.statistics.currentVolume // 1' "$PROGRESS")
    else
        CURRENT_CHAPTER=$(jq -r '.currentState.chapter // 1' "$PLOT_TRACKER")
        CURRENT_VOLUME=$(jq -r '.currentState.volume // 1' "$PLOT_TRACKER")
    fi
}

# 分析情节对齐
analyze_plot_alignment() {
    echo "📊 情节发展检查报告"
    echo "━━━━━━━━━━━━━━━━━━━━"

    # 当前进度
    echo "📍 当前进度：第${CURRENT_CHAPTER}章（第${CURRENT_VOLUME}卷）"

    # 读取情节追踪数据
    if [ -f "$PLOT_TRACKER" ]; then
        MAIN_PLOT=$(jq -r '.plotlines.main.currentNode // "未设定"' "$PLOT_TRACKER")
        PLOT_STATUS=$(jq -r '.plotlines.main.status // "unknown"' "$PLOT_TRACKER")
        echo "📖 主线进度：$MAIN_PLOT [$PLOT_STATUS]"

        # 完成的节点
        COMPLETED_COUNT=$(jq '.plotlines.main.completedNodes | length' "$PLOT_TRACKER")
        echo ""
        echo "✅ 已完成节点：${COMPLETED_COUNT}个"
        jq -r '.plotlines.main.completedNodes[]? | "  • " + .' "$PLOT_TRACKER" 2>/dev/null || true

        # 即将到来的节点
        UPCOMING_COUNT=$(jq '.plotlines.main.upcomingNodes | length' "$PLOT_TRACKER")
        if [ "$UPCOMING_COUNT" -gt 0 ]; then
            echo ""
            echo "→ 接下来的节点："
            jq -r '.plotlines.main.upcomingNodes[0:3][]? | "  • " + .' "$PLOT_TRACKER" 2>/dev/null || true
        fi
    fi
}

# 检查伏笔状态
check_foreshadowing() {
    echo ""
    echo "🎯 伏笔追踪"
    echo "───────────"

    if [ -f "$PLOT_TRACKER" ]; then
        # 统计伏笔
        TOTAL_FORESHADOW=$(jq '.foreshadowing | length' "$PLOT_TRACKER")
        ACTIVE_FORESHADOW=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER")
        RESOLVED_FORESHADOW=$(jq '[.foreshadowing[] | select(.status == "resolved")] | length' "$PLOT_TRACKER")

        echo "统计：总计${TOTAL_FORESHADOW}个，活跃${ACTIVE_FORESHADOW}个，已回收${RESOLVED_FORESHADOW}个"

        # 列出待处理的伏笔
        if [ "$ACTIVE_FORESHADOW" -gt 0 ]; then
            echo ""
            echo "⚠️ 待处理伏笔："
            jq -r '.foreshadowing[] | select(.status == "active") |
                "  • " + .content + "（第" + (.planted.chapter | tostring) + "章埋设）"' \
                "$PLOT_TRACKER" 2>/dev/null || true
        fi

        # 检查是否有过期的伏笔（超过30章未处理）
        OVERDUE=$(jq --arg current "$CURRENT_CHAPTER" '
            [.foreshadowing[] |
             select(.status == "active" and .planted.chapter and
                    (($current | tonumber) - .planted.chapter) > 30)] |
            length' "$PLOT_TRACKER")

        if [ "$OVERDUE" -gt 0 ]; then
            echo ""
            echo "⚠️ 警告：有${OVERDUE}个伏笔超过30章未处理"
        fi
    fi
}

# 检查冲突发展
check_conflicts() {
    echo ""
    echo "⚔️ 冲突追踪"
    echo "───────────"

    if [ -f "$PLOT_TRACKER" ]; then
        ACTIVE_CONFLICTS=$(jq '.conflicts.active | length' "$PLOT_TRACKER")

        if [ "$ACTIVE_CONFLICTS" -gt 0 ]; then
            echo "当前活跃冲突：${ACTIVE_CONFLICTS}个"
            jq -r '.conflicts.active[] |
                "  • " + .name + " [" + .intensity + "]"' \
                "$PLOT_TRACKER" 2>/dev/null || true
        else
            echo "暂无活跃冲突"
        fi
    fi
}

# 生成建议
generate_suggestions() {
    echo ""
    echo "💡 建议"
    echo "───────"

    # 基于当前章节给出建议
    if [ "$CURRENT_CHAPTER" -lt 10 ]; then
        echo "• 前10章是关键，确保有足够的钩子吸引读者"
    elif [ "$CURRENT_CHAPTER" -lt 30 ]; then
        echo "• 接近第一个小高潮，检查冲突是否足够激烈"
    elif [ "$((CURRENT_CHAPTER % 60))" -gt 50 ]; then
        echo "• 接近卷尾，准备高潮和悬念设置"
    fi

    # 基于伏笔状态给建议
    if [ "$ACTIVE_FORESHADOW" -gt 5 ]; then
        echo "• 活跃伏笔较多，考虑在接下来几章回收部分"
    fi

    # 基于冲突状态给建议
    if [ "$ACTIVE_CONFLICTS" -eq 0 ] && [ "$CURRENT_CHAPTER" -gt 5 ]; then
        echo "• 当前无活跃冲突，考虑引入新的矛盾点"
    fi
}

# 主函数
main() {
    echo "🔍 开始检查情节一致性..."
    echo ""

    # 检查必要文件
    check_required_files

    # 获取当前进度
    get_current_progress

    # 执行各项检查
    analyze_plot_alignment
    check_foreshadowing
    check_conflicts
    generate_suggestions

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━"
    echo "✅ 检查完成"

    # 更新检查时间
    if [ -f "$PLOT_TRACKER" ]; then
        TEMP_FILE=$(mktemp)
        jq --arg date "$(date -Iseconds)" '.lastUpdated = $date' "$PLOT_TRACKER" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$PLOT_TRACKER"
    fi
}

# 执行主函数
main