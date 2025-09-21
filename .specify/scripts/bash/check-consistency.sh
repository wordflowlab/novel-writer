#!/usr/bin/env bash
# 综合一致性检查脚本

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
PROGRESS="$STORY_DIR/progress.json"
PLOT_TRACKER="$STORY_DIR/spec/tracking/plot-tracker.json"
TIMELINE="$STORY_DIR/spec/tracking/timeline.json"
RELATIONSHIPS="$STORY_DIR/spec/tracking/relationships.json"
CHARACTER_STATE="$STORY_DIR/spec/tracking/character-state.json"

# ANSI颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 统计变量
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNINGS=0
ERRORS=0

# 检查函数
check() {
    local name="$1"
    local condition="$2"
    local error_msg="$3"

    ((TOTAL_CHECKS++))

    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $name"
        ((PASSED_CHECKS++))
    else
        echo -e "${RED}✗${NC} $name: $error_msg"
        ((ERRORS++))
    fi
}

warn() {
    local msg="$1"
    echo -e "${YELLOW}⚠${NC} 警告: $msg"
    ((WARNINGS++))
}

# 检查章节号一致性
check_chapter_consistency() {
    echo "📖 检查章节号一致性"
    echo "───────────────────"

    if [ -f "$PROGRESS" ] && [ -f "$PLOT_TRACKER" ]; then
        PROGRESS_CHAPTER=$(jq -r '.statistics.currentChapter // 0' "$PROGRESS")
        PLOT_CHAPTER=$(jq -r '.currentState.chapter // 0' "$PLOT_TRACKER")

        check "章节号同步" \
              "[ '$PROGRESS_CHAPTER' = '$PLOT_CHAPTER' ]" \
              "progress.json(${PROGRESS_CHAPTER}) != plot-tracker.json(${PLOT_CHAPTER})"

        if [ -f "$CHARACTER_STATE" ]; then
            CHAR_CHAPTER=$(jq -r '.protagonist.currentStatus.chapter // 0' "$CHARACTER_STATE")
            check "角色状态章节同步" \
                  "[ '$PROGRESS_CHAPTER' = '$CHAR_CHAPTER' ]" \
                  "与character-state.json(${CHAR_CHAPTER})不一致"
        fi
    else
        warn "部分追踪文件缺失，无法完成章节检查"
    fi

    echo ""
}

# 检查时间线连续性
check_timeline_consistency() {
    echo "⏰ 检查时间线连续性"
    echo "───────────────────"

    if [ -f "$TIMELINE" ]; then
        # 检查时间事件是否按章节递增
        TIMELINE_ISSUES=$(jq '
            .events |
            sort_by(.chapter) |
            . as $sorted |
            reduce range(1; length) as $i (0;
                if $sorted[$i].chapter <= $sorted[$i-1].chapter then . + 1 else . end
            )' "$TIMELINE")

        check "时间事件顺序" \
              "[ '$TIMELINE_ISSUES' = '0' ]" \
              "发现${TIMELINE_ISSUES}个乱序事件"

        # 检查当前时间是否更新
        CURRENT_TIME=$(jq -r '.storyTime.current // ""' "$TIMELINE")
        check "当前时间设置" \
              "[ -n '$CURRENT_TIME' ]" \
              "当前故事时间未设置"
    else
        warn "时间线文件不存在"
    fi

    echo ""
}

# 检查角色状态合理性
check_character_consistency() {
    echo "👥 检查角色状态合理性"
    echo "─────────────────────"

    if [ -f "$CHARACTER_STATE" ] && [ -f "$RELATIONSHIPS" ]; then
        # 检查主角是否存在于两个文件中
        PROTAG_NAME=$(jq -r '.protagonist.name // ""' "$CHARACTER_STATE")

        if [ -n "$PROTAG_NAME" ]; then
            HAS_RELATIONS=$(jq --arg name "$PROTAG_NAME" \
                'has($name)' "$RELATIONSHIPS" 2>/dev/null || echo "false")

            check "主角关系记录" \
                  "[ '$HAS_RELATIONS' = 'true' ]" \
                  "主角'$PROTAG_NAME'在relationships.json中无记录"
        fi

        # 检查角色位置逻辑
        LAST_LOCATION=$(jq -r '.protagonist.currentStatus.location // ""' "$CHARACTER_STATE")
        check "主角位置记录" \
              "[ -n '$LAST_LOCATION' ]" \
              "主角当前位置未记录"
    else
        warn "角色追踪文件不完整"
    fi

    echo ""
}

# 检查伏笔回收计划
check_foreshadowing_plan() {
    echo "🎯 检查伏笔管理"
    echo "──────────────"

    if [ -f "$PLOT_TRACKER" ]; then
        # 统计伏笔状态
        TOTAL_FORESHADOW=$(jq '.foreshadowing | length' "$PLOT_TRACKER")
        ACTIVE_FORESHADOW=$(jq '[.foreshadowing[] | select(.status == "active")] | length' "$PLOT_TRACKER")

        if [ -f "$PROGRESS" ]; then
            CURRENT_CHAPTER=$(jq -r '.statistics.currentChapter // 0' "$PROGRESS")

            # 检查超期未回收的伏笔
            OVERDUE=$(jq --arg current "$CURRENT_CHAPTER" '
                [.foreshadowing[] |
                 select(.status == "active" and .planted.chapter and
                        (($current | tonumber) - .planted.chapter) > 50)] |
                length' "$PLOT_TRACKER")

            check "伏笔回收及时性" \
                  "[ '$OVERDUE' = '0' ]" \
                  "有${OVERDUE}个伏笔超过50章未回收"
        fi

        echo "  📊 伏笔统计: 总计${TOTAL_FORESHADOW}个，活跃${ACTIVE_FORESHADOW}个"

        # 警告过多活跃伏笔
        if [ "$ACTIVE_FORESHADOW" -gt 10 ]; then
            warn "活跃伏笔过多(${ACTIVE_FORESHADOW}个)，可能造成读者困惑"
        fi
    else
        warn "情节追踪文件不存在"
    fi

    echo ""
}

# 检查文件完整性
check_file_integrity() {
    echo "📁 检查文件完整性"
    echo "────────────────"

    check "progress.json" "[ -f '$PROGRESS' ]" "文件不存在"
    check "plot-tracker.json" "[ -f '$PLOT_TRACKER' ]" "文件不存在"
    check "timeline.json" "[ -f '$TIMELINE' ]" "文件不存在"
    check "relationships.json" "[ -f '$RELATIONSHIPS' ]" "文件不存在"
    check "character-state.json" "[ -f '$CHARACTER_STATE' ]" "文件不存在"

    # 检查JSON格式是否有效
    for file in "$PROGRESS" "$PLOT_TRACKER" "$TIMELINE" "$RELATIONSHIPS" "$CHARACTER_STATE"; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            if jq empty "$file" 2>/dev/null; then
                check "$filename格式" "true" ""
            else
                check "$filename格式" "false" "JSON格式无效"
            fi
        fi
    done

    echo ""
}

# 生成报告
generate_report() {
    echo "═══════════════════════════════════════"
    echo "📊 综合一致性检查报告"
    echo "═══════════════════════════════════════"
    echo ""

    check_file_integrity
    check_chapter_consistency
    check_timeline_consistency
    check_character_consistency
    check_foreshadowing_plan

    echo "═══════════════════════════════════════"
    echo "📈 检查结果汇总"
    echo "───────────────────"
    echo "  总检查项: ${TOTAL_CHECKS}"
    echo -e "  ${GREEN}通过: ${PASSED_CHECKS}${NC}"
    echo -e "  ${YELLOW}警告: ${WARNINGS}${NC}"
    echo -e "  ${RED}错误: ${ERRORS}${NC}"

    if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ 完美！所有检查项全部通过${NC}"
    elif [ "$ERRORS" -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}⚠️  存在${WARNINGS}个警告，建议关注${NC}"
    else
        echo ""
        echo -e "${RED}❌ 发现${ERRORS}个错误，需要修正${NC}"
    fi

    echo "═══════════════════════════════════════"
    echo ""
    echo "检查时间: $(date '+%Y-%m-%d %H:%M:%S')"

    # 记录检查结果
    if [ -f "$STORY_DIR/spec/tracking" ]; then
        echo "{
            \"timestamp\": \"$(date -Iseconds)\",
            \"total\": $TOTAL_CHECKS,
            \"passed\": $PASSED_CHECKS,
            \"warnings\": $WARNINGS,
            \"errors\": $ERRORS
        }" > "$STORY_DIR/spec/tracking/.last-check.json"
    fi
}

# 主函数
main() {
    generate_report

    # 根据结果返回适当的退出码
    if [ "$ERRORS" -gt 0 ]; then
        exit 1
    elif [ "$WARNINGS" -gt 0 ]; then
        exit 0  # 警告不算失败
    else
        exit 0
    fi
}

# 执行主函数
main