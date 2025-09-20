#!/usr/bin/env bash
# 通用函数库

# 获取项目根目录
get_project_root() {
    if [ -f ".specify/config.json" ]; then
        pwd
    else
        # 向上查找包含 .specify 的目录
        current=$(pwd)
        while [ "$current" != "/" ]; do
            if [ -f "$current/.specify/config.json" ]; then
                echo "$current"
                return 0
            fi
            current=$(dirname "$current")
        done
        echo "错误: 未找到小说项目根目录" >&2
        exit 1
    fi
}

# 获取当前故事目录
get_current_story() {
    PROJECT_ROOT=$(get_project_root)
    STORIES_DIR="$PROJECT_ROOT/stories"

    # 找到最新的故事目录
    if [ -d "$STORIES_DIR" ]; then
        latest=$(ls -t "$STORIES_DIR" 2>/dev/null | head -1)
        if [ -n "$latest" ]; then
            echo "$STORIES_DIR/$latest"
        fi
    fi
}

# 创建带编号的目录
create_numbered_dir() {
    base_dir="$1"
    prefix="$2"

    mkdir -p "$base_dir"

    # 找到最高编号
    highest=0
    for dir in "$base_dir"/*; do
        [ -d "$dir" ] || continue
        dirname=$(basename "$dir")
        number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
        number=$((10#$number))
        if [ "$number" -gt "$highest" ]; then
            highest=$number
        fi
    done

    # 返回下一个编号
    next=$((highest + 1))
    printf "%03d" "$next"
}

# 输出 JSON（用于与 AI 助手通信）
output_json() {
    echo "$1"
}

# 确保文件存在
ensure_file() {
    file="$1"
    template="$2"

    if [ ! -f "$file" ]; then
        if [ -f "$template" ]; then
            cp "$template" "$file"
        else
            touch "$file"
        fi
    fi
}