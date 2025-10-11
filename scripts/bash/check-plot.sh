#!/usr/bin/env bash
# 检查情节发展的一致性和连贯性

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 检查模式
CHECKLIST_MODE=false
if [ "$1" = "--checklist" ]; then
    CHECKLIST_MODE=true
fi

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

# 生成 checklist 格式输出
output_checklist() {
    # 检查必要文件（静默）
    check_required_files > /dev/null 2>&1 || true

    # 获取当前进度
    get_current_progress

    # 收集数据
    local main_plot="未设定"
    local plot_status="unknown"
    local completed_count=0
    local upcoming_count=0
    local total_foreshadow=0
    local active_foreshadow=0
    local resolved_foreshadow=0
    local overdue_foreshadow=0
    local active_conflicts=0

    if [ -f "$PLOT_TRACKER" ]; then
        main_plot=$(jq -r '.plotlines.main.currentNode // "未设定"' "$PLOT_TRACKER")
        plot_status=$(jq -r '.plotlines.main.status // "unknown"' "$PLOT_TRACKER")
        completed_count=$(jq '.plotlines.main.completedNodes | length' "$PLOT_TRACKER")
        upcoming_count=$(jq '.plotlines.main.upcomingNodes | length' "$PLOT_TRACKER")

        total_foreshadow=$(jq '.foreshadowing | length' "$PLOT_TRACKER")
        active_foreshadow=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER")
        resolved_foreshadow=$(jq '[.foreshadowing[] | select(.status == "resolved")] | length' "$PLOT_TRACKER")

        overdue_foreshadow=$(jq --arg current "$CURRENT_CHAPTER" '
            [.foreshadowing[] |
             select(.status == "active" and .planted.chapter and
                    (($current | tonumber) - .planted.chapter) > 30)] |
            length' "$PLOT_TRACKER")

        active_conflicts=$(jq '.conflicts.active | length' "$PLOT_TRACKER")
    fi

    # 输出 checklist 格式
    cat <<EOF
# 情节对齐检查 Checklist

**检查时间**: $(date '+%Y-%m-%d %H:%M:%S')
**检查对象**: plot-tracker.json, outline.md, progress.json
**当前进度**: 第 ${CURRENT_CHAPTER} 章（第 ${CURRENT_VOLUME} 卷）

---

## 文件完整性

- [$([ -f "$PLOT_TRACKER" ] && echo "x" || echo " ")] CHK001 plot-tracker.json 存在
- [$([ -f "$OUTLINE" ] && echo "x" || echo " ")] CHK002 outline.md 存在
- [$([ -f "$PROGRESS" ] && echo "x" || echo " ")] CHK003 progress.json 存在

## 情节进度

- [$([ "$plot_status" != "unknown" ] && echo "x" || echo " ")] CHK004 主线情节状态已更新（当前：$plot_status）
- [x] CHK005 主线情节节点进度：$main_plot
- [$([ $completed_count -gt 0 ] && echo "x" || echo " ")] CHK006 已完成情节节点（$completed_count 个）
- [$([ $upcoming_count -gt 0 ] && echo "x" || echo " ")] CHK007 后续情节节点已规划（$upcoming_count 个）

## 伏笔管理

EOF

    if [ $total_foreshadow -gt 0 ]; then
        echo "- [x] CHK008 伏笔记录存在（总计 $total_foreshadow 个）"
        echo "- [x] CHK009 伏笔状态跟踪（活跃 $active_foreshadow 个，已回收 $resolved_foreshadow 个）"

        if [ $overdue_foreshadow -eq 0 ]; then
            echo "- [x] CHK010 伏笔回收及时（无超过30章未处理）"
        else
            echo "- [!] CHK010 伏笔回收及时（⚠️ ${overdue_foreshadow}个超过30章未处理）"
        fi

        if [ $active_foreshadow -le 5 ]; then
            echo "- [x] CHK011 活跃伏笔数量合理（$active_foreshadow ≤ 5）"
        elif [ $active_foreshadow -le 10 ]; then
            echo "- [!] CHK011 活跃伏笔数量偏多（$active_foreshadow 个，建议回收部分）"
        else
            echo "- [!] CHK011 活跃伏笔数量过多（⚠️ $active_foreshadow > 10，可能造成混乱）"
        fi
    else
        echo "- [ ] CHK008 伏笔记录存在（未找到伏笔记录）"
        echo "- [ ] CHK009 伏笔状态跟踪（无数据）"
        echo "- [ ] CHK010 伏笔回收及时（无数据）"
        echo "- [ ] CHK011 活跃伏笔数量合理（无数据）"
    fi

    cat <<EOF

## 冲突发展

EOF

    if [ $active_conflicts -gt 0 ]; then
        echo "- [x] CHK012 存在活跃冲突（$active_conflicts 个）"
    elif [ $CURRENT_CHAPTER -gt 5 ]; then
        echo "- [!] CHK012 存在活跃冲突（⚠️ 当前无活跃冲突，建议引入矛盾点）"
    else
        echo "- [x] CHK012 存在活跃冲突（前期章节，可暂无冲突）"
    fi

    cat <<EOF

## 节奏建议

EOF

    # 基于当前章节给出检查项
    if [ $CURRENT_CHAPTER -lt 10 ]; then
        echo "- [ ] CHK013 前10章钩子设置（确保有足够吸引力）"
    elif [ $CURRENT_CHAPTER -lt 30 ]; then
        echo "- [ ] CHK014 第一个小高潮准备（检查冲突强度）"
    elif [ $((CURRENT_CHAPTER % 60)) -gt 50 ]; then
        echo "- [ ] CHK015 卷尾高潮设置（准备悬念和高潮）"
    else
        echo "- [x] CHK016 节奏正常（无特殊节点提醒）"
    fi

    cat <<EOF

---

## 后续行动

EOF

    # 动态生成后续行动
    local has_actions=false

    if [ $overdue_foreshadow -gt 0 ]; then
        echo "- [ ] 回收超期伏笔（${overdue_foreshadow}个）"
        has_actions=true
    fi

    if [ $active_foreshadow -gt 10 ]; then
        echo "- [ ] 减少活跃伏笔数量（当前 $active_foreshadow 个）"
        has_actions=true
    fi

    if [ $active_conflicts -eq 0 ] && [ $CURRENT_CHAPTER -gt 5 ]; then
        echo "- [ ] 引入新的冲突点"
        has_actions=true
    fi

    if [ $upcoming_count -eq 0 ]; then
        echo "- [ ] 规划后续情节节点"
        has_actions=true
    fi

    if [ "$has_actions" = false ]; then
        echo "*当前情节发展良好，无需特别行动*"
    fi

    cat <<EOF

---

**检查工具**: check-plot.sh
**版本**: 1.1 (支持 checklist 输出)
EOF
}

# 主函数
main() {
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
    else
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
    fi

    # 更新检查时间
    if [ -f "$PLOT_TRACKER" ]; then
        TEMP_FILE=$(mktemp)
        jq --arg date "$(date -Iseconds)" '.lastUpdated = $date' "$PLOT_TRACKER" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$PLOT_TRACKER"
    fi
}

# 执行主函数
main