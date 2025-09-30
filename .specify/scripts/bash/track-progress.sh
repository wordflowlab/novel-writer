#!/bin/bash

# track-progress.sh - 综合追踪小说创作进度
# 支持 --check 深度验证和 --fix 自动修复

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 解析参数
MODE="report"  # 默认模式
if [[ "$1" == "--check" ]]; then
    MODE="check"
elif [[ "$1" == "--fix" ]]; then
    MODE="fix"
elif [[ "$1" == "--brief" ]]; then
    MODE="brief"
elif [[ "$1" == "--plot" ]]; then
    MODE="plot"
elif [[ "$1" == "--stats" ]]; then
    MODE="stats"
fi

echo -e "${BLUE}📊 执行追踪分析...${NC}"
echo ""

# 检查基础文件是否存在
check_files() {
    local has_files=false

    if [[ -f "stories/current/progress.json" ]]; then
        has_files=true
    fi

    if [[ -f "spec/tracking/plot-tracker.json" ]]; then
        has_files=true
    fi

    if [[ "$has_files" == false ]]; then
        echo -e "${YELLOW}⚠️ 未找到追踪文件，请先初始化项目${NC}"
        exit 1
    fi
}

# 基础报告功能
show_basic_report() {
    echo -e "${GREEN}📖 小说创作综合报告${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # 读取进度信息
    if [[ -f "stories/current/progress.json" ]]; then
        echo -e "${BLUE}✍️ 写作进度${NC}"
        # 这里AI会读取并显示进度信息
        echo "  章节完成情况等待分析..."
    fi

    # 读取情节追踪
    if [[ -f "spec/tracking/plot-tracker.json" ]]; then
        echo -e "${BLUE}📍 情节状态${NC}"
        echo "  主线进度等待分析..."
    fi

    echo ""
}

# 深度验证模式
run_deep_check() {
    echo -e "${GREEN}🔍 执行深度验证...${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Phase 1: 基础验证
    echo -e "${BLUE}Phase 1: 基础验证${NC}"
    echo "  [P] 执行情节一致性检查..."
    echo "  [P] 执行时间线验证..."
    echo "  [P] 执行关系验证..."
    echo "  [P] 执行世界观验证..."

    # Phase 2: 角色深度验证
    echo -e "${BLUE}Phase 2: 角色深度验证${NC}"

    # 检查验证规则文件
    if [[ -f "spec/tracking/validation-rules.json" ]]; then
        echo "  ✅ 加载验证规则"
        echo "  扫描章节中的角色名称..."
        echo "  对比character-state.json..."
        echo "  检查称呼准确性..."

        # 生成验证任务（内部使用）
        cat << EOF > /tmp/validation-tasks.md
# 验证任务 (自动生成)

## Phase 1: 基础验证 [并行]
- [ ] T001 [P] 执行plot-check逻辑
- [ ] T002 [P] 执行timeline逻辑
- [ ] T003 [P] 执行relations逻辑
- [ ] T004 [P] 执行world-check逻辑

## Phase 2: 角色验证
- [ ] T005 加载validation-rules.json
- [ ] T006 扫描章节角色名称
- [ ] T007 验证名称一致性
- [ ] T008 检查称呼准确性
- [ ] T009 验证行为一致性

## Phase 3: 生成报告
- [ ] T010 汇总结果
- [ ] T011 标记问题
- [ ] T012 生成建议
EOF

        echo -e "${GREEN}  ✅ 验证任务已生成${NC}"
    else
        echo -e "${YELLOW}  ⚠️ 未找到验证规则文件${NC}"
        echo "  建议创建 spec/tracking/validation-rules.json"
    fi

    # Phase 3: 生成报告
    echo -e "${BLUE}Phase 3: 生成验证报告${NC}"
    echo ""
    echo "📊 深度验证报告"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "AI将分析所有章节并生成详细报告..."
    echo ""
    echo -e "${YELLOW}💡 提示：发现问题后可运行 $0 --fix 自动修复${NC}"
}

# 自动修复模式
run_auto_fix() {
    echo -e "${GREEN}🔧 执行自动修复...${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ ! -f "spec/tracking/validation-rules.json" ]]; then
        echo -e "${RED}❌ 需要先运行 --check 生成验证报告${NC}"
        exit 1
    fi

    # 生成修复任务
    cat << EOF > /tmp/fix-tasks.md
# 修复任务 (自动生成)

## Phase 1: 简单修复 [可自动]
- [ ] F001 读取验证报告
- [ ] F002 [P] 修复角色名称错误
- [ ] F003 [P] 修复称呼错误
- [ ] F004 [P] 修复简单拼写

## Phase 2: 生成报告
- [ ] F005 汇总修复结果
- [ ] F006 更新追踪文件
EOF

    echo "  生成修复任务..."
    echo "  执行自动修复..."
    echo ""
    echo "🔧 自动修复报告"
    echo "━━━━━━━━━━━━━━━━━━━"
    echo "AI将自动修复简单问题..."
    echo ""
    echo -e "${GREEN}修复完成后建议重新运行 $0 --check 验证${NC}"
}

# 主执行逻辑
check_files

case $MODE in
    "check")
        run_deep_check
        ;;
    "fix")
        run_auto_fix
        ;;
    "brief"|"plot"|"stats")
        echo "显示${MODE}模式的报告..."
        show_basic_report
        ;;
    *)
        show_basic_report
        echo -e "${BLUE}💡 可用选项：${NC}"
        echo "  --check : 深度验证所有内容"
        echo "  --fix   : 自动修复简单问题"
        echo "  --brief : 显示简要信息"
        echo "  --plot  : 仅显示情节追踪"
        echo "  --stats : 仅显示统计数据"
        ;;
esac

echo ""
echo -e "${GREEN}✅ 追踪分析完成${NC}"