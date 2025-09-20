#!/usr/bin/env bash
# 设置创作风格

set -e

# 加载通用函数
SCRIPT_DIR=$(dirname "$0")
source "$SCRIPT_DIR/common.sh"

# 获取项目根目录
PROJECT_ROOT=$(get_project_root)
MEMORY_DIR="$PROJECT_ROOT/memory"

# 创建 memory 目录
mkdir -p "$MEMORY_DIR"

# 创建或更新创作准则文件
CONSTITUTION_FILE="$MEMORY_DIR/writing-constitution.md"
TEMPLATE="$PROJECT_ROOT/templates/writing-constitution-template.md"

ensure_file "$CONSTITUTION_FILE" "$TEMPLATE"

# 输出结果
echo "CONSTITUTION_FILE: $CONSTITUTION_FILE"
echo "STATUS: ready"