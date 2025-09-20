#!/usr/bin/env bash
# 写作章节

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

# 检查前置条件
if [ ! -f "$STORY_DIR/outline.md" ]; then
    echo "错误: 未找到章节规划，请先使用 /outline 命令" >&2
    exit 1
fi

# 确定要写作的章节（可以通过参数传入，或自动找下一章）
CHAPTER_NUM="${1:-}"

# 从 outline.md 解析卷册信息
parse_volume_info() {
    local outline_file="$1"
    local chapter_num="$2"

    # 尝试从 outline.md 中解析卷册信息
    # 格式示例: ### 第一卷：书生入世
    # - **章节范围**：第1-60章

    local volume_num=1
    while IFS= read -r line; do
        if [[ "$line" =~ ^###[[:space:]]+第.*卷 ]]; then
            # 找到卷册标题行，继续查找章节范围
            local next_line
            while IFS= read -r next_line; do
                if [[ "$next_line" =~ 章节范围.*第([0-9]+)-([0-9]+)章 ]]; then
                    local start_ch="${BASH_REMATCH[1]}"
                    local end_ch="${BASH_REMATCH[2]}"
                    if [ "$chapter_num" -ge "$start_ch" ] && [ "$chapter_num" -le "$end_ch" ]; then
                        echo "volume-${volume_num}"
                        return 0
                    fi
                    volume_num=$((volume_num + 1))
                    break
                elif [[ "$next_line" =~ ^### ]]; then
                    # 遇到下一个卷册标题，跳出
                    break
                fi
            done
        fi
    done < "$outline_file"

    # 如果无法从 outline.md 解析，使用默认规则
    # 每60章一卷
    local volume=$((($chapter_num - 1) / 60 + 1))
    echo "volume-${volume}"
}

# 确定章节所属卷册
determine_volume() {
    local chapter=$1
    local outline_file="$STORY_DIR/outline.md"

    if [ -f "$outline_file" ]; then
        # 尝试从 outline.md 解析
        parse_volume_info "$outline_file" "$chapter"
    else
        # 使用默认规则：每60章一卷
        local volume=$((($chapter - 1) / 60 + 1))
        echo "volume-${volume}"
    fi
}

if [ -z "$CHAPTER_NUM" ]; then
    # 自动查找下一个未写的章节
    CHAPTER_NUM=1
    found=false
    # 从 outline.md 获取总章节数，如果找不到，默认最多查找500章
    MAX_CHAPTERS=500
    if [ -f "$STORY_DIR/outline.md" ]; then
        # 尝试从 outline.md 中解析总章节数
        # 格式: - **总章节数**：240章
        TOTAL_CHAPTERS=$(grep -E "总章节数.*[0-9]+章" "$STORY_DIR/outline.md" | grep -o "[0-9]+" | head -1)
        if [ -n "$TOTAL_CHAPTERS" ]; then
            MAX_CHAPTERS=$TOTAL_CHAPTERS
        fi
    fi

    while [ "$CHAPTER_NUM" -le "$MAX_CHAPTERS" ] && [ "$found" = false ]; do
        VOLUME=$(determine_volume "$CHAPTER_NUM")
        CHAPTER_FMT=$(printf "%03d" "$CHAPTER_NUM")
        if [ ! -f "$STORY_DIR/chapters/$VOLUME/chapter-${CHAPTER_FMT}.md" ]; then
            found=true
        else
            CHAPTER_NUM=$((CHAPTER_NUM + 1))
        fi
    done
fi

# 格式化章节编号并确定所属卷册
CHAPTER_NUM_FMT=$(printf "%03d" "$CHAPTER_NUM")
VOLUME_DIR=$(determine_volume "$CHAPTER_NUM")
CHAPTER_FILE="$STORY_DIR/chapters/$VOLUME_DIR/chapter-${CHAPTER_NUM_FMT}.md"

# 创建章节文件（包括卷册目录）
mkdir -p "$(dirname "$CHAPTER_FILE")"
touch "$CHAPTER_FILE"

# 更新进度
PROGRESS_FILE="$STORY_DIR/progress.json"
if [ -f "$PROGRESS_FILE" ]; then
    # 这里应该更新 JSON，简化处理
    echo "已创建章节文件: $CHAPTER_FILE" >&2
fi

# 输出结果
echo "CHAPTER_FILE: $CHAPTER_FILE"
echo "CHAPTER_NUM: $CHAPTER_NUM"
echo "VOLUME: $VOLUME_DIR"
echo "STATUS: ready"