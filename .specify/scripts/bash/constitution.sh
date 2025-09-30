#!/bin/bash

# 小说创作宪法管理脚本
# 用于 /constitution 命令

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 获取命令参数
COMMAND="${1:-check}"

# Get project root
PROJECT_ROOT=$(get_project_root)
cd "$PROJECT_ROOT"

# 定义文件路径
CONSTITUTION_FILE="memory/novel-constitution.md"
OLD_CONSTITUTION_FILE=".specify/memory/writing-constitution.md"

case "$COMMAND" in
    check)
        # 检查宪法文件是否存在
        if [ -f "$CONSTITUTION_FILE" ]; then
            echo "✅ 宪法文件已存在：$CONSTITUTION_FILE"
            # 提取版本信息
            VERSION=$(grep -E "^- 版本：" "$CONSTITUTION_FILE" 2>/dev/null | cut -d'：' -f2 | tr -d ' ' || echo "未知")
            UPDATED=$(grep -E "^- 最后修订：" "$CONSTITUTION_FILE" 2>/dev/null | cut -d'：' -f2 | tr -d ' ' || echo "未知")
            echo "  版本：$VERSION"
            echo "  最后修订：$UPDATED"
            exit 0
        elif [ -f "$OLD_CONSTITUTION_FILE" ]; then
            echo "⚠️ 发现旧版创作准则文件"
            echo "  位置：$OLD_CONSTITUTION_FILE"
            echo "  建议：运行 /constitution 升级为完整宪法"
            exit 0
        else
            echo "❌ 尚未创建宪法文件"
            echo "  建议：运行 /constitution 创建创作宪法"
            exit 1
        fi
        ;;

    init)
        # 初始化宪法文件
        mkdir -p "$(dirname "$CONSTITUTION_FILE")"

        if [ -f "$CONSTITUTION_FILE" ]; then
            echo "宪法文件已存在，准备更新"
        else
            echo "准备创建新的宪法文件"

            # 如果存在旧文件，提示迁移
            if [ -f "$OLD_CONSTITUTION_FILE" ]; then
                echo "检测到旧版创作准则，将作为参考"
            fi
        fi
        ;;

    validate)
        # 验证宪法文件格式
        if [ ! -f "$CONSTITUTION_FILE" ]; then
            echo "错误：宪法文件不存在"
            exit 1
        fi

        echo "验证宪法文件..."

        # 检查必要章节
        REQUIRED_SECTIONS=("核心价值观" "质量标准" "创作风格" "内容规范" "读者契约")
        MISSING_SECTIONS=()

        for section in "${REQUIRED_SECTIONS[@]}"; do
            if ! grep -q "## .* $section" "$CONSTITUTION_FILE"; then
                MISSING_SECTIONS+=("$section")
            fi
        done

        if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
            echo "⚠️ 缺少以下章节："
            for section in "${MISSING_SECTIONS[@]}"; do
                echo "  - $section"
            done
        else
            echo "✅ 所有必要章节都存在"
        fi

        # 检查版本信息
        if grep -q "^- 版本：" "$CONSTITUTION_FILE"; then
            echo "✅ 版本信息完整"
        else
            echo "⚠️ 缺少版本信息"
        fi
        ;;

    export)
        # 导出宪法摘要
        if [ ! -f "$CONSTITUTION_FILE" ]; then
            echo "错误：宪法文件不存在"
            exit 1
        fi

        echo "# 创作宪法摘要"
        echo ""

        # 提取核心原则
        echo "## 核心原则"
        grep -A 1 "^### 原则" "$CONSTITUTION_FILE" | grep "^**声明**" | cut -d'：' -f2- || echo "（未找到原则声明）"

        echo ""
        echo "## 质量底线"
        grep -A 1 "^### 标准" "$CONSTITUTION_FILE" | grep "^**要求**" | cut -d'：' -f2- || echo "（未找到质量标准）"

        echo ""
        echo "详细内容请查看：$CONSTITUTION_FILE"
        ;;

    *)
        echo "未知命令：$COMMAND"
        echo "支持的命令：check, init, validate, export"
        exit 1
        ;;
esac