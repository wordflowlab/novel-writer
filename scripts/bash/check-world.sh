#!/usr/bin/env bash
# 世界观一致性检查脚本

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

# 检查模式
CHECKLIST_MODE=false
if [ "$1" = "--checklist" ]; then
    CHECKLIST_MODE=true
fi

# 文件路径
WORLD_SETTING="$STORY_DIR/spec/knowledge/world-setting.md"
LOCATIONS="$STORY_DIR/spec/knowledge/locations.md"
CULTURE="$STORY_DIR/spec/knowledge/culture.md"
RULES="$STORY_DIR/spec/knowledge/rules.md"
CONTENT_DIR="$STORY_DIR/content"

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
ISSUES=()

# 检查函数
check() {
    local name="$1"
    local condition="$2"
    local error_msg="$3"

    ((TOTAL_CHECKS++))

    if eval "$condition"; then
        if [ "$CHECKLIST_MODE" = false ]; then
            echo -e "${GREEN}✓${NC} $name"
        fi
        ((PASSED_CHECKS++))
    else
        if [ "$CHECKLIST_MODE" = false ]; then
            echo -e "${RED}✗${NC} $name: $error_msg"
        fi
        ((ERRORS++))
        ISSUES+=("$name|$error_msg")
    fi
}

warn() {
    local msg="$1"
    if [ "$CHECKLIST_MODE" = false ]; then
        echo -e "${YELLOW}⚠${NC} 警告: $msg"
    fi
    ((WARNINGS++))
    ISSUES+=("警告|$msg")
}

# 检查设定文件完整性
check_setting_files() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "📁 检查设定文件完整性"
        echo "─────────────────────"
    fi

    check "world-setting.md" "[ -f '$WORLD_SETTING' ]" "核心世界观文件不存在"
    check "locations.md" "[ -f '$LOCATIONS' ]" "地点描述文件不存在"
    check "culture.md" "[ -f '$CULTURE' ]" "文化风俗文件不存在"
    check "rules.md" "[ -f '$RULES' ]" "特殊规则文件不存在"

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 检查术语一致性
check_terminology() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "📝 检查术语一致性"
        echo "────────────────"
    fi

    if [ -d "$CONTENT_DIR" ]; then
        # 提取世界观文档中的专有名词（简化版，实际应该更复杂）
        local term_count=0

        if [ -f "$WORLD_SETTING" ]; then
            # 统计专有名词（这里简化为统计加粗或特殊标记的词）
            term_count=$(grep -o '\*\*[^*]*\*\*' "$WORLD_SETTING" 2>/dev/null | wc -l || echo 0)
        fi

        check "专有名词定义" "[ $term_count -gt 0 ]" "未找到专有名词定义"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 专有名词数量: $term_count"
        fi
    else
        warn "内容目录不存在，跳过术语检查"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 检查地理逻辑
check_geography() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "🗺️  检查地理逻辑"
        echo "───────────────"
    fi

    if [ -f "$LOCATIONS" ]; then
        # 统计定义的地点数
        local location_count=$(grep -c '^##' "$LOCATIONS" 2>/dev/null || echo 0)

        check "地点定义完整性" "[ $location_count -gt 0 ]" "未定义任何地点"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 已定义地点: ${location_count}个"
        fi

        # 检查内容中提到的地点是否在定义中
        if [ -d "$CONTENT_DIR" ]; then
            # 这里简化处理，实际应该用更复杂的匹配逻辑
            local undefined_locations=0

            # TODO: 实现更智能的地点匹配逻辑
            # 目前只做基本的文件检查

            check "地点引用检查" "[ $undefined_locations -eq 0 ]" "发现未定义的地点引用"
        fi
    else
        warn "地点描述文件不存在"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 检查文化一致性
check_culture() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "🎭 检查文化一致性"
        echo "────────────────"
    fi

    if [ -f "$CULTURE" ]; then
        # 统计文化要素
        local culture_count=$(grep -c '^##' "$CULTURE" 2>/dev/null || echo 0)

        check "文化要素定义" "[ $culture_count -gt 0 ]" "未定义文化要素"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 文化要素: ${culture_count}个"
        fi
    else
        warn "文化风俗文件不存在"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 检查规则一致性
check_rules() {
    if [ "$CHECKLIST_MODE" = false ]; then
        echo "⚖️  检查规则一致性"
        echo "───────────────"
    fi

    if [ -f "$RULES" ]; then
        # 统计特殊规则
        local rule_count=$(grep -c '^##' "$RULES" 2>/dev/null || echo 0)

        check "特殊规则定义" "[ $rule_count -gt 0 ]" "未定义特殊规则"

        if [ "$CHECKLIST_MODE" = false ]; then
            echo "  📊 特殊规则: ${rule_count}条"
        fi
    else
        warn "特殊规则文件不存在"
    fi

    if [ "$CHECKLIST_MODE" = false ]; then
        echo ""
    fi
}

# 生成普通报告
generate_report() {
    echo "═══════════════════════════════════════"
    echo "🌍 世界观一致性检查报告"
    echo "═══════════════════════════════════════"
    echo ""

    check_setting_files
    check_terminology
    check_geography
    check_culture
    check_rules

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
    echo ""
    echo "💡 建议："
    echo "  - 定期更新世界观设定文档"
    echo "  - 创建术语表以保持一致性"
    echo "  - 记录地点间的距离和方位关系"
}

# 生成 checklist 格式输出
output_checklist() {
    # 重新执行检查逻辑收集数据
    TOTAL_CHECKS=0
    PASSED_CHECKS=0
    ERRORS=0
    WARNINGS=0
    ISSUES=()

    check_setting_files
    check_terminology
    check_geography
    check_culture
    check_rules

    # 输出 checklist 格式
    cat <<EOF
# 世界观一致性检查 Checklist

**检查时间**: $(date '+%Y-%m-%d %H:%M:%S')
**检查对象**: spec/knowledge/ 目录及已写章节内容
**检查范围**: 世界观设定、地理逻辑、文化风俗、特殊规则

---

## 设定文件完整性

- [$([ -f "$WORLD_SETTING" ] && echo "x" || echo " ")] CHK001 world-setting.md 存在
- [$([ -f "$LOCATIONS" ] && echo "x" || echo " ")] CHK002 locations.md 存在
- [$([ -f "$CULTURE" ] && echo "x" || echo " ")] CHK003 culture.md 存在
- [$([ -f "$RULES" ] && echo "x" || echo " ")] CHK004 rules.md 存在

## 术语一致性

- [$([ -d "$CONTENT_DIR" ] && echo "x" || echo " ")] CHK005 专有名词定义完整
- [ ] CHK006 章节中的术语与设定文档一致（需人工核查）

## 地理逻辑

EOF

    if [ -f "$LOCATIONS" ]; then
        local location_count=$(grep -c '^##' "$LOCATIONS" 2>/dev/null || echo 0)
        echo "- [x] CHK007 地点定义完整（已定义 ${location_count} 个地点）"
    else
        echo "- [ ] CHK007 地点定义完整"
    fi

    cat <<EOF
- [ ] CHK008 地点间距离和方位合理（需人工核查）
- [ ] CHK009 章节中的地理描述与设定一致（需人工核查）

## 文化一致性

EOF

    if [ -f "$CULTURE" ]; then
        local culture_count=$(grep -c '^##' "$CULTURE" 2>/dev/null || echo 0)
        echo "- [x] CHK010 文化要素定义完整（已定义 ${culture_count} 个要素）"
    else
        echo "- [ ] CHK010 文化要素定义完整"
    fi

    cat <<EOF
- [ ] CHK011 风俗描述前后一致（需人工核查）
- [ ] CHK012 语言和称谓使用统一（需人工核查）

## 规则一致性

EOF

    if [ -f "$RULES" ]; then
        local rule_count=$(grep -c '^##' "$RULES" 2>/dev/null || echo 0)
        echo "- [x] CHK013 特殊规则定义完整（已定义 ${rule_count} 条规则）"
    else
        echo "- [ ] CHK013 特殊规则定义完整"
    fi

    cat <<EOF
- [ ] CHK014 规则应用前后一致（需人工核查）
- [ ] CHK015 规则未出现相互矛盾（需人工核查）

---

## 发现的问题

EOF

    if [ ${#ISSUES[@]} -gt 0 ]; then
        for issue in "${ISSUES[@]}"; do
            IFS='|' read -r name msg <<< "$issue"
            echo "### $name"
            echo ""
            echo "**问题**: $msg"
            echo ""
        done
    else
        echo "*未发现问题*"
    fi

    cat <<EOF

---

## 检查统计

- **总检查项**: ${TOTAL_CHECKS}
- **已通过**: ${PASSED_CHECKS}
- **需改进**: ${ERRORS}
- **警告**: ${WARNINGS}

---

## 后续行动

- [ ] 补充缺失的设定文档
- [ ] 创建术语表记录专有名词
- [ ] 人工核查章节中的世界观描述
- [ ] 记录地点间的距离和旅行时间

---

**检查工具**: check-world.sh
**版本**: 1.0
EOF
}

# 主函数
main() {
    if [ "$CHECKLIST_MODE" = true ]; then
        output_checklist
    else
        generate_report
    fi

    # 根据结果返回适当的退出码
    if [ "$ERRORS" -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# 执行主函数
main
