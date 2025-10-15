#!/bin/bash

# 检查写作状态脚本
# 用于 /write 命令

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 检查是否为 checklist 模式
CHECKLIST_MODE=false
if [ "$1" = "--checklist" ]; then
    CHECKLIST_MODE=true
fi

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 获取当前故事
STORY_NAME=$(get_active_story)
STORY_DIR="stories/$STORY_NAME"

# 检查方法论文档
check_methodology_docs() {
    local missing=()

    [ ! -f "memory/constitution.md" ] && missing+=("宪法")
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
    local validation_rules="spec/tracking/validation-rules.json"
    local min_words=2000
    local max_words=4000

    # 读取验证规则（如果存在）
    if [ -f "$validation_rules" ]; then
        if command -v jq >/dev/null 2>&1; then
            min_words=$(jq -r '.rules.chapterMinWords // 2000' "$validation_rules")
            max_words=$(jq -r '.rules.chapterMaxWords // 4000' "$validation_rules")
        fi
    fi

    if [ -d "$content_dir" ]; then
        local chapter_count=$(ls "$content_dir"/*.md 2>/dev/null | wc -l)
        if [ $chapter_count -gt 0 ]; then
            echo ""
            echo "已完成章节：$chapter_count"
            echo "字数要求：${min_words}-${max_words} 字"
            echo ""
            echo "最近写作："
            for file in $(ls -t "$content_dir"/*.md 2>/dev/null | head -n 3); do
                local filename=$(basename "$file")
                local words=$(count_chinese_words "$file")
                local status="✅"

                if [ "$words" -lt "$min_words" ]; then
                    status="⚠️ 字数不足"
                elif [ "$words" -gt "$max_words" ]; then
                    status="⚠️ 字数超出"
                fi

                echo "  - $filename: $words 字 $status"
            done
        fi
    else
        echo ""
        echo "尚未开始写作"
    fi
}

# 生成 checklist 格式输出
output_checklist() {
    local has_constitution=false
    local has_specification=false
    local has_plan=false
    local has_tasks=false
    local pending=0
    local in_progress=0
    local completed=0
    local chapter_count=0
    local bad_chapters=0
    local min_words=2000
    local max_words=4000

    # 检查文档
    [ -f "memory/constitution.md" ] && has_constitution=true
    [ -f "$STORY_DIR/specification.md" ] && has_specification=true
    [ -f "$STORY_DIR/creative-plan.md" ] && has_plan=true
    [ -f "$STORY_DIR/tasks.md" ] && has_tasks=true

    # 统计任务
    if [ "$has_tasks" = true ]; then
        pending=$(grep -c "^- \[ \]" "$STORY_DIR/tasks.md" 2>/dev/null || echo 0)
        in_progress=$(grep -c "^- \[~\]" "$STORY_DIR/tasks.md" 2>/dev/null || echo 0)
        completed=$(grep -c "^- \[x\]" "$STORY_DIR/tasks.md" 2>/dev/null || echo 0)
    fi

    # 读取验证规则
    local validation_rules="$STORY_DIR/spec/tracking/validation-rules.json"
    if [ -f "$validation_rules" ] && command -v jq >/dev/null 2>&1; then
        min_words=$(jq -r '.rules.chapterMinWords // 2000' "$validation_rules")
        max_words=$(jq -r '.rules.chapterMaxWords // 4000' "$validation_rules")
    fi

    # 检查章节内容
    local content_dir="$STORY_DIR/content"
    if [ -d "$content_dir" ]; then
        chapter_count=$(ls "$content_dir"/*.md 2>/dev/null | wc -l | tr -d ' ')

        # 统计不符合字数要求的章节
        for file in "$content_dir"/*.md; do
            [ -f "$file" ] || continue
            local words=$(count_chinese_words "$file")
            if [ "$words" -lt "$min_words" ] || [ "$words" -gt "$max_words" ]; then
                bad_chapters=$((bad_chapters + 1))
            fi
        done
    fi

    # 计算总任务和完成率
    local total_tasks=$((pending + in_progress + completed))
    local completion_rate=0
    if [ $total_tasks -gt 0 ]; then
        completion_rate=$((completed * 100 / total_tasks))
    fi

    # 输出 checklist
    cat <<EOF
# 写作状态检查 Checklist

**检查时间**: $(date '+%Y-%m-%d %H:%M:%S')
**当前故事**: $STORY_NAME
**字数标准**: ${min_words}-${max_words} 字

---

## 文档完整性

- [$([ "$has_constitution" = true ] && echo "x" || echo " ")] CHK001 constitution.md 存在
- [$([ "$has_specification" = true ] && echo "x" || echo " ")] CHK002 specification.md 存在
- [$([ "$has_plan" = true ] && echo "x" || echo " ")] CHK003 creative-plan.md 存在
- [$([ "$has_tasks" = true ] && echo "x" || echo " ")] CHK004 tasks.md 存在

## 任务进度

EOF

    if [ "$has_tasks" = true ]; then
        echo "- [$([ $in_progress -gt 0 ] && echo "x" || echo " ")] CHK005 有进行中的任务（$in_progress 个）"
        echo "- [x] CHK006 待开始任务数量（$pending 个）"
        echo "- [$([ $completed -gt 0 ] && echo "x" || echo " ")] CHK007 已完成任务进度（$completed/$total_tasks = $completion_rate%）"
    else
        echo "- [ ] CHK005 有进行中的任务（tasks.md 不存在）"
        echo "- [ ] CHK006 待开始任务数量（tasks.md 不存在）"
        echo "- [ ] CHK007 已完成任务进度（tasks.md 不存在）"
    fi

    cat <<EOF

## 内容质量

- [$([ $chapter_count -gt 0 ] && echo "x" || echo " ")] CHK008 已完成章节数（$chapter_count 章）
EOF

    if [ $chapter_count -gt 0 ]; then
        echo "- [$([ $bad_chapters -eq 0 ] && echo "x" || echo "!")] CHK009 字数符合标准（$([ $bad_chapters -eq 0 ] && echo "全部符合" || echo "$bad_chapters 章不符合")）"
    else
        echo "- [ ] CHK009 字数符合标准（尚未开始写作）"
    fi

    cat <<EOF

---

## 后续行动

EOF

    local has_actions=false

    # 检查缺失文档
    if [ "$has_constitution" = false ] || [ "$has_specification" = false ] || [ "$has_plan" = false ] || [ "$has_tasks" = false ]; then
        echo "- [ ] 完成方法论文档（运行对应命令：/constitution, /specify, /plan, /tasks）"
        has_actions=true
    fi

    # 检查任务
    if [ $pending -gt 0 ] || [ $in_progress -gt 0 ]; then
        if [ $in_progress -gt 0 ]; then
            echo "- [ ] 继续进行中的任务（$in_progress 个）"
        else
            echo "- [ ] 开始下一个待写作任务（共 $pending 个）"
        fi
        has_actions=true
    fi

    # 检查章节质量
    if [ $bad_chapters -gt 0 ]; then
        echo "- [ ] 修复字数不符合要求的章节（$bad_chapters 章）"
        has_actions=true
    fi

    # 完成建议
    if [ $pending -eq 0 ] && [ $in_progress -eq 0 ] && [ $completed -gt 0 ]; then
        echo "- [ ] 运行 /analyze 进行综合验证"
        has_actions=true
    fi

    if [ "$has_actions" = false ]; then
        echo "*写作状态良好，无需特别行动*"
    fi

    cat <<EOF

---

**检查工具**: check-writing-state.sh
**版本**: 1.1 (支持 checklist 输出)
EOF
}

# 主流程
main() {
    # Checklist 模式直接输出并退出
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
        exit 0
    fi

    # 原有的详细输出模式
    echo "写作状态检查"
    echo "============"
    echo "当前故事：$STORY_NAME"
    echo ""

    if ! check_methodology_docs; then
        exit 1
    fi

    check_pending_tasks
    check_completed_content

    echo ""
    echo "准备就绪，可以开始写作"
}

main