#!/usr/bin/env bash
# 风格管理器 - 支持初始设定和外部建议整合

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 获取项目根目录
PROJECT_ROOT=$(get_project_root)
MEMORY_DIR="$PROJECT_ROOT/.specify/memory"
SPEC_DIR="$PROJECT_ROOT/spec"
KNOWLEDGE_DIR="$SPEC_DIR/knowledge"
TRACKING_DIR="$SPEC_DIR/tracking"

# 命令模式
MODE=${1:-init}
shift || true

# 创建必要目录
mkdir -p "$MEMORY_DIR" "$KNOWLEDGE_DIR" "$TRACKING_DIR"

# 函数：初始化风格设定
init_style() {
    echo "📝 初始化创作风格..."

    # 创建或更新创作准则文件
    CONSTITUTION_FILE="$MEMORY_DIR/writing-constitution.md"
    TEMPLATE="$PROJECT_ROOT/.specify/templates/writing-constitution-template.md"

    ensure_file "$CONSTITUTION_FILE" "$TEMPLATE"

    # 可选：融合个人语料摘要，增强个体表达一致性
    integrate_personal_voice "$CONSTITUTION_FILE"

    # 固定专章：个人表达基线（自动同步）
    sync_personal_baseline "$CONSTITUTION_FILE"

    # 输出结果
    echo "CONSTITUTION_FILE: $CONSTITUTION_FILE"
    echo "STATUS: ready"
    echo "✅ 创作风格初始化完成"
}

# 从 personal-voice.md 提取要点并追加到创作准则
integrate_personal_voice() {
    local constitution_file="$1"
    local pv_file="$PROJECT_ROOT/.specify/memory/personal-voice.md"

    if [ -f "$pv_file" ]; then
        local tmp="/tmp/pv_summary_$$.md"
        echo "" > "$tmp"
        echo "## 个人语料摘要（自动引用）" >> "$tmp"
        echo "来源：.specify/memory/personal-voice.md" >> "$tmp"
        echo "" >> "$tmp"

        # 提取二级标题与紧邻的前2条列表项作为摘要
        awk '
            /^## / { if(h>6) exit; h++; if(cnt>0) {print ""}; print $0; lc=0; next }
            /^- / && lc<2 { print $0; lc++; next }
        ' "$pv_file" >> "$tmp"

        # 防止重复追加：检测是否已存在本次摘要（按日期+章节标题近似判断）
        if ! grep -q "个人语料摘要（自动引用）" "$constitution_file"; then
            echo "" >> "$constitution_file"
            cat "$tmp" >> "$constitution_file"
            echo "    ✅ 已引用个人语料摘要"
        fi
        rm -f "$tmp"
    fi
}

# 用固定专章方式同步 personal-voice 关键点（可重复执行，幂等）
sync_personal_baseline() {
    local constitution_file="$1"
    local pv_file="$PROJECT_ROOT/.specify/memory/personal-voice.md"
    [ -f "$pv_file" ] || return 0

    local tmp="/tmp/pv_baseline_$$.md"
    echo "<!-- BEGIN: PERSONAL_BASELINE_AUTO -->" > "$tmp"
    echo "## 个人表达基线（自动同步）" >> "$tmp"
    echo "来源：.specify/memory/personal-voice.md（只读镜像，修改请在源文件）" >> "$tmp"
    echo "" >> "$tmp"

    # 函数：按标题抓取前N条列表
    fetch_section() {
        local title="$1"; local n="$2"; local label="$3"
        echo "### $label" >> "$tmp"
        awk -v t="$title" -v n="$n" '
            BEGIN{hit=0;cnt=0}
            $0 ~ "^## " t "$" {hit=1; next}
            hit==1 && $0 ~ /^## / {hit=0}
            hit==1 && $0 ~ /^- / && cnt<n {print $0; cnt++}
        ' "$pv_file" >> "$tmp"
        echo "" >> "$tmp"
    }

    fetch_section "口头禅与常用表达" 6 "口头禅与常用表达"
    fetch_section "固定句式与节奏偏好" 6 "固定句式与节奏偏好"
    fetch_section "行业/地域词汇（口音、俚语、术语）" 6 "行业/地域词汇"
    fetch_section "比喻口味与意象库" 8 "比喻与意象"
    fetch_section "写作忌口与避讳" 6 "写作忌口"

    echo "<!-- END: PERSONAL_BASELINE_AUTO -->" >> "$tmp"

    # 将标记块写入或替换到创作准则
    if grep -q "<!-- BEGIN: PERSONAL_BASELINE_AUTO -->" "$constitution_file"; then
        # 替换现有块
        awk -v RS='' -v ORS='\n\n' -v file="$tmp" '
            BEGIN{while((getline l<file)>0){blk=blk l "\n"}} 
            { gsub(/<!-- BEGIN: PERSONAL_BASELINE_AUTO -->[\s\S]*<!-- END: PERSONAL_BASELINE_AUTO -->/, blk) }1
        ' "$constitution_file" > "$constitution_file.tmp" && mv "$constitution_file.tmp" "$constitution_file"
    else
        echo "" >> "$constitution_file"
        cat "$tmp" >> "$constitution_file"
    fi

    rm -f "$tmp"
    echo "    ✅ 已同步个人表达基线"
}

# 函数：解析JSON建议
parse_json_suggestions() {
    local input="$1"
    local temp_file="/tmp/suggestions_$$.json"

    # 保存输入到临时文件
    echo "$input" > "$temp_file"

    # 验证JSON格式
    if ! python3 -m json.tool "$temp_file" > /dev/null 2>&1; then
        echo "❌ JSON格式无效"
        rm -f "$temp_file"
        return 1
    fi

    # 提取关键信息
    local source=$(python3 -c "import json; data=json.load(open('$temp_file')); print(data.get('source', 'Unknown'))")
    local date=$(python3 -c "import json; data=json.load(open('$temp_file')); print(data.get('analysis_date', '$(date +%Y-%m-%d)'))")

    echo "📊 解析来自 $source 的建议 ($date)"

    # 处理各类建议
    process_style_suggestions "$temp_file"
    process_character_suggestions "$temp_file"
    process_plot_suggestions "$temp_file"
    process_world_suggestions "$temp_file"
    process_dialogue_suggestions "$temp_file"

    # 清理临时文件
    rm -f "$temp_file"
}

# 函数：解析Markdown建议
parse_markdown_suggestions() {
    local input="$1"
    local temp_file="/tmp/suggestions_$$.md"

    echo "$input" > "$temp_file"

    echo "📊 解析Markdown格式建议..."

    # 提取基础信息
    local source=$(grep "分析工具：" "$temp_file" | sed 's/.*分析工具：//')
    local date=$(grep "分析日期：" "$temp_file" | sed 's/.*分析日期：//')

    echo "来源：${source:-Unknown}"
    echo "日期：${date:-$(date +%Y-%m-%d)}"

    # 处理建议（简化版）
    process_markdown_style "$temp_file"
    process_markdown_characters "$temp_file"

    rm -f "$temp_file"
}

# 函数：处理风格建议
process_style_suggestions() {
    local json_file="$1"

    # 检查是否有风格建议
    local has_style=$(python3 -c "
import json
data = json.load(open('$json_file'))
print('yes' if 'style' in data.get('suggestions', {}) else 'no')
")

    if [ "$has_style" = "yes" ]; then
        echo "  📝 处理风格建议..."

        # 更新writing-constitution.md
        local constitution_file="$MEMORY_DIR/writing-constitution.md"
        local temp_update="/tmp/constitution_update_$$.md"

        # 提取风格建议并追加
        python3 -c "
import json
data = json.load(open('$json_file'))
style = data.get('suggestions', {}).get('style', {})
items = style.get('items', [])

with open('$temp_update', 'w') as f:
    f.write('\n## 外部建议优化 ($(date +%Y-%m-%d))\n\n')
    for item in items:
        f.write(f\"### {item.get('type', '未分类')}\n\")
        f.write(f\"- **问题**：{item.get('current', '')}\n\")
        f.write(f\"- **建议**：{item.get('suggestion', '')}\n\")
        f.write(f\"- **预期效果**：{item.get('impact', '')}\n\n\")
"

        if [ -f "$temp_update" ]; then
            cat "$temp_update" >> "$constitution_file"
            rm -f "$temp_update"
            echo "    ✅ 已更新创作准则"
        fi
    fi
}

# 函数：处理角色建议
process_character_suggestions() {
    local json_file="$1"

    local has_chars=$(python3 -c "
import json
data = json.load(open('$json_file'))
print('yes' if 'characters' in data.get('suggestions', {}) else 'no')
")

    if [ "$has_chars" = "yes" ]; then
        echo "  👥 处理角色建议..."

        # 更新角色档案
        local profiles_file="$KNOWLEDGE_DIR/character-profiles.md"
        local temp_update="/tmp/profiles_update_$$.md"

        python3 -c "
import json
data = json.load(open('$json_file'))
chars = data.get('suggestions', {}).get('characters', {})
items = chars.get('items', [])

with open('$temp_update', 'w') as f:
    f.write('\n## 角色优化建议 ($(date +%Y-%m-%d))\n\n')
    for item in items:
        f.write(f\"### {item.get('character', '未知角色')}\n\")
        f.write(f\"- **问题**：{item.get('issue', '')}\n\")
        f.write(f\"- **建议**：{item.get('suggestion', '')}\n\")
        f.write(f\"- **发展曲线**：{item.get('development_curve', '')}\n\")
        chapters = item.get('chapters_affected', [])
        if chapters:
            f.write(f\"- **影响章节**：{', '.join(map(str, chapters))}\n\")
        f.write('\n')
"

        if [ -f "$temp_update" ] && [ -f "$profiles_file" ]; then
            cat "$temp_update" >> "$profiles_file"
            rm -f "$temp_update"
            echo "    ✅ 已更新角色档案"
        fi
    fi
}

# 函数：处理情节建议
process_plot_suggestions() {
    local json_file="$1"

    local has_plot=$(python3 -c "
import json
data = json.load(open('$json_file'))
print('yes' if 'plot' in data.get('suggestions', {}) else 'no')
")

    if [ "$has_plot" = "yes" ]; then
        echo "  📖 处理情节建议..."

        # 更新情节追踪器
        local plot_file="$TRACKING_DIR/plot-tracker.json"

        if [ -f "$plot_file" ]; then
            python3 -c "
import json

# 读取现有追踪文件
with open('$plot_file', 'r') as f:
    tracker = json.load(f)

# 读取建议
data = json.load(open('$json_file'))
plot = data.get('suggestions', {}).get('plot', {})
items = plot.get('items', [])

# 添加建议到追踪器
if 'suggestions' not in tracker:
    tracker['suggestions'] = []

for item in items:
    tracker['suggestions'].append({
        'date': '$(date +%Y-%m-%d)',
        'type': item.get('type', ''),
        'location': item.get('location', ''),
        'suggestion': item.get('suggestion', ''),
        'importance': item.get('importance', 'medium'),
        'status': 'pending'
    })

# 保存更新
with open('$plot_file', 'w') as f:
    json.dump(tracker, f, indent=2, ensure_ascii=False)
"
            echo "    ✅ 已更新情节追踪器"
        fi
    fi
}

# 函数：处理世界观建议
process_world_suggestions() {
    local json_file="$1"

    local has_world=$(python3 -c "
import json
data = json.load(open('$json_file'))
print('yes' if 'worldbuilding' in data.get('suggestions', {}) else 'no')
")

    if [ "$has_world" = "yes" ]; then
        echo "  🌍 处理世界观建议..."

        # 更新世界观设定
        local world_file="$KNOWLEDGE_DIR/world-setting.md"
        local temp_update="/tmp/world_update_$$.md"

        python3 -c "
import json
data = json.load(open('$json_file'))
world = data.get('suggestions', {}).get('worldbuilding', {})
items = world.get('items', [])

with open('$temp_update', 'w') as f:
    f.write('\n## 世界观完善建议 ($(date +%Y-%m-%d))\n\n')
    for item in items:
        f.write(f\"### {item.get('aspect', '未分类')}\n\")
        f.write(f\"- **问题**：{item.get('issue', '')}\n\")
        f.write(f\"- **建议**：{item.get('suggestion', '')}\n\")
        chapters = item.get('reference_chapters', [])
        if chapters:
            f.write(f\"- **参考章节**：{', '.join(map(str, chapters))}\n\")
        f.write('\n')
"

        if [ -f "$temp_update" ] && [ -f "$world_file" ]; then
            cat "$temp_update" >> "$world_file"
            rm -f "$temp_update"
            echo "    ✅ 已更新世界观设定"
        fi
    fi
}

# 函数：处理对话建议
process_dialogue_suggestions() {
    local json_file="$1"

    local has_dialogue=$(python3 -c "
import json
data = json.load(open('$json_file'))
print('yes' if 'dialogue' in data.get('suggestions', {}) else 'no')
")

    if [ "$has_dialogue" = "yes" ]; then
        echo "  💬 处理对话建议..."

        # 创建或更新角色语言规范
        local voices_file="$KNOWLEDGE_DIR/character-voices.md"

        if [ ! -f "$voices_file" ]; then
            echo "# 角色语言规范" > "$voices_file"
            echo "" >> "$voices_file"
            echo "## 通用原则" >> "$voices_file"
            echo "" >> "$voices_file"
        fi

        local temp_update="/tmp/voices_update_$$.md"

        python3 -c "
import json
data = json.load(open('$json_file'))
dialogue = data.get('suggestions', {}).get('dialogue', {})
items = dialogue.get('items', [])

with open('$temp_update', 'w') as f:
    f.write('\n## 对话优化建议 ($(date +%Y-%m-%d))\n\n')
    for item in items:
        f.write(f\"### {item.get('character', '通用')}\n\")
        f.write(f\"- **问题**：{item.get('issue', '')}\n\")
        f.write(f\"- **建议**：{item.get('suggestion', '')}\n\")

        examples = item.get('examples', [])
        alternatives = item.get('alternatives', [])

        if examples and alternatives:
            f.write('- **替换示例**：\n')
            for i, ex in enumerate(examples):
                if i < len(alternatives):
                    f.write(f\"  - {ex} → {alternatives[i]}\n\")
        f.write('\n')
"

        if [ -f "$temp_update" ]; then
            cat "$temp_update" >> "$voices_file"
            rm -f "$temp_update"
            echo "    ✅ 已更新对话规范"
        fi
    fi
}

# 函数：处理Markdown风格建议
process_markdown_style() {
    local md_file="$1"

    if grep -q "写作风格建议" "$md_file"; then
        echo "  📝 处理风格建议..."

        # 提取风格部分并追加到constitution
        local constitution_file="$MEMORY_DIR/writing-constitution.md"

        echo "" >> "$constitution_file"
        echo "## 外部建议优化 ($(date +%Y-%m-%d))" >> "$constitution_file"
        echo "" >> "$constitution_file"

        # 提取风格建议部分（简化处理）
        awk '/## 写作风格建议/,/## [^写]/' "$md_file" | grep -v "^##" >> "$constitution_file"

        echo "    ✅ 已更新创作准则"
    fi
}

# 函数：处理Markdown角色建议
process_markdown_characters() {
    local md_file="$1"

    if grep -q "角色优化建议" "$md_file"; then
        echo "  👥 处理角色建议..."

        local profiles_file="$KNOWLEDGE_DIR/character-profiles.md"

        if [ -f "$profiles_file" ]; then
            echo "" >> "$profiles_file"
            echo "## 外部优化建议 ($(date +%Y-%m-%d))" >> "$profiles_file"
            echo "" >> "$profiles_file"

            # 提取角色建议部分
            awk '/## 角色优化建议/,/## [^角]/' "$md_file" | grep -v "^##" >> "$profiles_file"

            echo "    ✅ 已更新角色档案"
        fi
    fi
}

# 函数：更新改进日志
update_improvement_log() {
    local source="$1"
    local summary="$2"

    local log_file="$KNOWLEDGE_DIR/improvement-log.md"

    # 如果文件不存在，创建头部
    if [ ! -f "$log_file" ]; then
        cat > "$log_file" << EOF
# 改进建议历史

记录所有外部AI建议和采纳情况。

EOF
    fi

    # 追加新记录
    cat >> "$log_file" << EOF

## $(date +%Y-%m-%d) - $source

### 建议摘要
$summary

### 采纳状态
- [x] 已自动整合到规范文件
- [ ] 待人工审核确认
- [ ] 待实施修订

### 影响文件
EOF

    # 列出被修改的文件
    echo "- writing-constitution.md" >> "$log_file"
    [ -f "$KNOWLEDGE_DIR/character-profiles.md" ] && echo "- character-profiles.md" >> "$log_file"
    [ -f "$TRACKING_DIR/plot-tracker.json" ] && echo "- plot-tracker.json" >> "$log_file"
    [ -f "$KNOWLEDGE_DIR/world-setting.md" ] && echo "- world-setting.md" >> "$log_file"
    [ -f "$KNOWLEDGE_DIR/character-voices.md" ] && echo "- character-voices.md" >> "$log_file"

    echo "" >> "$log_file"
    echo "---" >> "$log_file"
}

# 函数：整合外部建议
refine_style() {
    echo "🔄 开始整合外部建议..."

    # 读取输入（从标准输入或参数）
    local input="$*"
    if [ -z "$input" ]; then
        # 尝试从标准输入读取
        if [ ! -t 0 ]; then
            input=$(cat)
        else
            echo "请提供建议内容"
            exit 1
        fi
    fi

    # 自动检测格式 - 改进检测逻辑
    if echo "$input" | grep -q '"version"' && echo "$input" | grep -q '"suggestions"'; then
        echo "检测到JSON格式"
        parse_json_suggestions "$input"
        update_improvement_log "外部AI" "已处理JSON格式建议"
    elif echo "$input" | grep -q "# 小说创作建议报告"; then
        echo "检测到Markdown格式"
        parse_markdown_suggestions "$input"
        update_improvement_log "外部AI" "已处理Markdown格式建议"
    else
        echo "❌ 无法识别建议格式"
        echo "请使用标准JSON或Markdown格式"
        echo "参考：docs/ai-suggestion-prompt-template.md"
        exit 1
    fi

    # 生成报告
    echo ""
    echo "✅ 建议整合完成"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 整合报告："
    echo "  - 更新文件：$(find $MEMORY_DIR $KNOWLEDGE_DIR $TRACKING_DIR -type f -mmin -1 2>/dev/null | wc -l) 个"
    echo "  - 建议来源：外部AI分析"
    echo "  - 处理时间：$(date +%H:%M:%S)"
    echo ""
    echo "📋 下一步行动："
    echo "  1. 查看 improvement-log.md 了解详情"
    echo "  2. 使用 /write 创作时会应用新规范"
    echo "  3. 建议对相关章节进行修订"
    echo ""
    echo "详见：$KNOWLEDGE_DIR/improvement-log.md"
}

# 函数：合并多源建议
merge_suggestions() {
    echo "🔀 合并多源建议..."
    echo "（功能开发中）"
    # TODO: 实现多源建议智能合并
}

# 主逻辑
case "$MODE" in
    init)
        init_style
        ;;
    refine)
        refine_style "$@"
        ;;
    merge)
        merge_suggestions "$@"
        ;;
    *)
        echo "❌ 未知模式: $MODE"
        echo "可用模式: init, refine, merge"
        exit 1
        ;;
esac
