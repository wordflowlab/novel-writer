#!/usr/bin/env bash
# 检测 analyze 命令应该执行的阶段
# 返回 JSON 格式的阶段信息

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取项目根目录和故事目录
PROJECT_ROOT=$(get_project_root)
STORY_DIR=$(get_current_story)

# 默认返回值
ANALYZE_TYPE="content"
CHAPTER_COUNT=0
HAS_SPEC=false
HAS_PLAN=false
HAS_TASKS=false
REASON=""

# 检查规格文件
if [ -f "$STORY_DIR/specification.md" ]; then
    HAS_SPEC=true
fi

# 检查计划文件
if [ -f "$STORY_DIR/creative-plan.md" ]; then
    HAS_PLAN=true
fi

# 检查任务文件
if [ -f "$STORY_DIR/tasks.md" ]; then
    HAS_TASKS=true
fi

# 统计章节数量
if [ -d "$STORY_DIR/content" ] || [ -d "$STORY_DIR/chapters" ]; then
    # 支持两种目录结构
    CONTENT_DIR="$STORY_DIR/content"
    [ ! -d "$CONTENT_DIR" ] && CONTENT_DIR="$STORY_DIR/chapters"

    if [ -d "$CONTENT_DIR" ]; then
        # 统计 .md 文件数量（排除索引文件）
        CHAPTER_COUNT=$(find "$CONTENT_DIR" -maxdepth 1 -type f -name "*.md" ! -name "README.md" ! -name "index.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
fi

# 决策逻辑
if [ "$CHAPTER_COUNT" -eq 0 ]; then
    # 无章节内容 → 框架分析
    ANALYZE_TYPE="framework"
    REASON="无章节内容，建议进行框架一致性分析"
elif [ "$CHAPTER_COUNT" -lt 3 ]; then
    # 章节数量不足 → 框架分析（但提示可以开始写作）
    ANALYZE_TYPE="framework"
    REASON="章节数量较少（$CHAPTER_COUNT 章），建议继续写作或进行框架验证"
else
    # 章节充足 → 内容分析
    ANALYZE_TYPE="content"
    REASON="已完成 $CHAPTER_COUNT 章，可进行内容质量分析"
fi

# 输出 JSON（支持 --json 参数）
if [[ "${1:-}" == "--json" ]]; then
    cat <<EOF
{
  "analyze_type": "$ANALYZE_TYPE",
  "chapter_count": $CHAPTER_COUNT,
  "has_spec": $HAS_SPEC,
  "has_plan": $HAS_PLAN,
  "has_tasks": $HAS_TASKS,
  "story_dir": "$STORY_DIR",
  "reason": "$REASON"
}
EOF
else
    # 人类可读输出
    echo "分析阶段检测结果"
    echo "=================="
    echo "故事目录: $STORY_DIR"
    echo "章节数量: $CHAPTER_COUNT"
    echo "规格文件: $([ "$HAS_SPEC" = true ] && echo "✅" || echo "❌")"
    echo "计划文件: $([ "$HAS_PLAN" = true ] && echo "✅" || echo "❌")"
    echo "任务文件: $([ "$HAS_TASKS" = true ] && echo "✅" || echo "❌")"
    echo ""
    echo "推荐模式: $ANALYZE_TYPE"
    echo "原因: $REASON"
fi
