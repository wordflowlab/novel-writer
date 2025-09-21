#!/usr/bin/env bash
# 管理和验证故事时间线

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
TIMELINE="$STORY_DIR/spec/tracking/timeline.json"
PROGRESS="$STORY_DIR/progress.json"

# 命令参数
COMMAND="${1:-show}"
PARAM2="${2:-}"

# 初始化时间线文件
init_timeline() {
    if [ ! -f "$TIMELINE" ]; then
        echo "⚠️  未找到时间线文件，正在创建..." >&2
        mkdir -p "$STORY_DIR/spec/tracking"

        if [ -f "$SCRIPT_DIR/../../templates/tracking/timeline.json" ]; then
            cp "$SCRIPT_DIR/../../templates/tracking/timeline.json" "$TIMELINE"
            echo "✅ 时间线文件已创建"
        else
            echo "错误: 无法找到模板文件" >&2
            exit 1
        fi
    fi
}

# 显示时间线
show_timeline() {
    echo "📅 故事时间线"
    echo "━━━━━━━━━━━━━━━━━━━━"

    if [ -f "$TIMELINE" ]; then
        # 当前时间
        CURRENT_TIME=$(jq -r '.storyTime.current // "未设定"' "$TIMELINE")
        echo "⏰ 当前时间：$CURRENT_TIME"
        echo ""

        # 时间跨度计算
        START_TIME=$(jq -r '.storyTime.start // ""' "$TIMELINE")
        if [ -n "$START_TIME" ]; then
            echo "📍 起始时间：$START_TIME"

            # 计算已经历的事件数
            EVENT_COUNT=$(jq '.events | length' "$TIMELINE")
            echo "📊 记录事件：${EVENT_COUNT}个"
        fi

        echo ""
        echo "📖 重要事件："
        echo "───────────────"

        # 显示最近的事件
        jq -r '.events | sort_by(.chapter) | reverse | .[0:5][] |
            "第" + (.chapter | tostring) + "章 | " + .date + " | " + .event' \
            "$TIMELINE" 2>/dev/null || echo "  暂无事件记录"

        # 显示并行事件
        PARALLEL_COUNT=$(jq '.parallelEvents.timepoints | length' "$TIMELINE" 2>/dev/null || echo "0")
        if [ "$PARALLEL_COUNT" != "0" ] && [ "$PARALLEL_COUNT" != "null" ]; then
            echo ""
            echo "🔄 并行事件："
            jq -r '.parallelEvents.timepoints | to_entries[] |
                .key + ": " + (.value | join(", "))' "$TIMELINE" 2>/dev/null || true
        fi
    else
        echo "未找到时间线文件"
    fi
}

# 添加时间节点
add_event() {
    local chapter="${2:-}"
    local date="${3:-}"
    local event="${4:-}"

    if [ -z "$chapter" ] || [ -z "$date" ] || [ -z "$event" ]; then
        echo "用法: $0 add <章节号> <时间> <事件描述>" >&2
        echo "示例: $0 add 5 '万历三十年春' '主角抵达京城'" >&2
        exit 1
    fi

    if [ ! -f "$TIMELINE" ]; then
        init_timeline
    fi

    # 添加新事件
    TEMP_FILE=$(mktemp)
    jq --arg ch "$chapter" \
       --arg dt "$date" \
       --arg ev "$event" \
       '.events += [{
           chapter: ($ch | tonumber),
           date: $dt,
           event: $ev,
           duration: "",
           participants: []
       }] |
       .events |= sort_by(.chapter) |
       .lastUpdated = now | strftime("%Y-%m-%dT%H:%M:%S")' \
       "$TIMELINE" > "$TEMP_FILE"

    mv "$TEMP_FILE" "$TIMELINE"
    echo "✅ 事件已添加：第${chapter}章 - $date - $event"
}

# 检查时间连续性
check_continuity() {
    echo "🔍 检查时间线连续性"
    echo "━━━━━━━━━━━━━━━━━━━━"

    if [ ! -f "$TIMELINE" ]; then
        echo "错误: 时间线文件不存在" >&2
        exit 1
    fi

    # 检查事件顺序
    echo "检查章节顺序..."

    # 获取所有章节号并检查是否递增
    CHAPTERS=$(jq -r '.events | sort_by(.chapter) | .[].chapter' "$TIMELINE")

    prev_chapter=0
    issues=0

    for chapter in $CHAPTERS; do
        if [ "$chapter" -le "$prev_chapter" ]; then
            echo "⚠️  章节顺序异常：第${chapter}章出现在第${prev_chapter}章之后"
            ((issues++))
        fi
        prev_chapter=$chapter
    done

    # 检查时间跨度
    echo ""
    echo "检查时间跨度..."

    # 这里可以添加更复杂的时间逻辑检查
    # 比如检查旅行时间是否合理等

    if [ "$issues" -eq 0 ]; then
        echo ""
        echo "✅ 时间线检查通过，未发现逻辑问题"
    else
        echo ""
        echo "⚠️  发现${issues}个潜在问题，请检查"
    fi

    # 记录检查结果
    if [ -f "$TIMELINE" ]; then
        TEMP_FILE=$(mktemp)
        jq --arg date "$(date -Iseconds)" \
           --arg issues "$issues" \
           '.lastChecked = $date |
            .anomalies.lastCheckIssues = ($issues | tonumber)' \
           "$TIMELINE" > "$TEMP_FILE"
        mv "$TEMP_FILE" "$TIMELINE"
    fi
}

# 同步并行事件
sync_parallel() {
    local timepoint="${2:-}"
    local events="${3:-}"

    if [ -z "$timepoint" ] || [ -z "$events" ]; then
        echo "用法: $0 sync <时间点> <事件列表>" >&2
        echo "示例: $0 sync '万历三十年春' '战争爆发,使团到达'" >&2
        exit 1
    fi

    if [ ! -f "$TIMELINE" ]; then
        init_timeline
    fi

    # 将事件列表转换为JSON数组
    IFS=',' read -ra EVENT_ARRAY <<< "$events"
    JSON_ARRAY=$(printf '"%s",' "${EVENT_ARRAY[@]}" | sed 's/,$//')
    JSON_ARRAY="[${JSON_ARRAY}]"

    # 更新并行事件
    TEMP_FILE=$(mktemp)
    jq --arg tp "$timepoint" \
       --argjson events "$JSON_ARRAY" \
       '.parallelEvents.timepoints[$tp] = $events |
        .lastUpdated = now | strftime("%Y-%m-%dT%H:%M:%S")' \
       "$TIMELINE" > "$TEMP_FILE"

    mv "$TEMP_FILE" "$TIMELINE"
    echo "✅ 并行事件已同步：$timepoint"
}

# 主函数
main() {
    init_timeline

    case "$COMMAND" in
        show)
            show_timeline
            ;;
        add)
            add_event "$@"
            ;;
        check)
            check_continuity
            ;;
        sync)
            sync_parallel "$@"
            ;;
        *)
            echo "用法: $0 [show|add|check|sync] [参数...]" >&2
            echo "命令:" >&2
            echo "  show  - 显示时间线" >&2
            echo "  add   - 添加时间节点" >&2
            echo "  check - 检查连续性" >&2
            echo "  sync  - 同步并行事件" >&2
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"