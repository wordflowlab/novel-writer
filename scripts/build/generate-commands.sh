#!/usr/bin/env bash
set -euo pipefail

# generate-commands.sh
# 基于 spec-kit 架构，为 novel-writer 生成多平台命令
# 支持命名空间以避免与 spec-kit 冲突

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔨 Novel Writer 命令构建系统"
echo "================================"

# 清理旧的构建产物
rm -rf "$PROJECT_ROOT/dist"
mkdir -p "$PROJECT_ROOT/dist"

# 路径重写函数（将相对路径转换为 .specify/ 路径）
# 使用临时标记保护已经正确的 .specify/ 路径，避免重复添加前缀
rewrite_paths() {
  sed -E \
    -e 's@\.specify/memory/@__SPECIFY_MEMORY__@g' \
    -e 's@\.specify/scripts/@__SPECIFY_SCRIPTS__@g' \
    -e 's@\.specify/templates/@__SPECIFY_TEMPLATES__@g' \
    -e 's@(/?)memory/@.specify/memory/@g' \
    -e 's@(/?)scripts/@.specify/scripts/@g' \
    -e 's@(/?)templates/@.specify/templates/@g' \
    -e 's@__SPECIFY_MEMORY__@.specify/memory/@g' \
    -e 's@__SPECIFY_SCRIPTS__@.specify/scripts/@g' \
    -e 's@__SPECIFY_TEMPLATES__@.specify/templates/@g'
}

# 核心函数：生成命令文件
generate_commands() {
  local agent=$1           # claude, gemini, cursor, windsurf, roocode
  local ext=$2             # md 或 toml
  local arg_format=$3      # $ARGUMENTS 或 {{args}}
  local output_dir=$4      # 输出目录
  local script_variant=$5  # sh 或 ps
  local namespace=$6       # 命名空间前缀（如 "novel."）
  local frontmatter_type=$7 # full, partial, minimal, none (Markdown frontmatter 类型)

  mkdir -p "$output_dir"

  echo "  📝 生成 $agent 命令 ($script_variant 脚本, frontmatter: $frontmatter_type)..."

  for template in "$PROJECT_ROOT/templates/commands"/*.md; do
    [[ -f "$template" ]] || continue

    local name description argument_hint script_command body prompt_body
    name=$(basename "$template" .md)

    # 规范化行尾
    file_content=$(tr -d '\r' < "$template")

    # 提取 frontmatter 字段
    description=$(printf '%s\n' "$file_content" | awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}')
    argument_hint=$(printf '%s\n' "$file_content" | awk '/^argument-hint:/ {sub(/^argument-hint:[[:space:]]*/, ""); print; exit}')

    # 提取对应脚本变体的命令
    script_command=$(printf '%s\n' "$file_content" | awk -v sv="$script_variant" '/^[[:space:]]*'"$script_variant"':[[:space:]]*/ {sub(/^[[:space:]]*'"$script_variant"':[[:space:]]*/, ""); print; exit}')

    if [[ -z $script_command ]]; then
      echo "    ⚠️  警告: $template 中未找到 $script_variant 脚本" >&2
      script_command="echo 'Missing script command for $script_variant'"
    fi

    # 替换 {SCRIPT} 占位符
    body=$(printf '%s\n' "$file_content" | sed "s|{SCRIPT}|${script_command}|g")

    # 移除 scripts: section（因为已经替换了）
    body=$(printf '%s\n' "$body" | awk '
      /^---$/ { print; if (++dash_count == 1) in_frontmatter=1; else in_frontmatter=0; next }
      in_frontmatter && /^scripts:$/ { skip_scripts=1; next }
      in_frontmatter && /^[a-zA-Z].*:/ && skip_scripts { skip_scripts=0 }
      in_frontmatter && skip_scripts && /^[[:space:]]/ { next }
      { print }
    ')

    # 应用其他替换
    body=$(printf '%s\n' "$body" | sed "s/{ARGS}/$arg_format/g" | sed "s/\$ARGUMENTS/$arg_format/g" | sed "s/__AGENT__/$agent/g" | rewrite_paths)

    # 为 Gemini 提取纯 prompt 内容（移除 YAML frontmatter）
    prompt_body=$(printf '%s\n' "$body" | awk '
      /^---$/ { if (++dash_count == 2) { in_content=1; next } next }
      in_content { print }
    ')

    # 根据文件格式生成输出
    case $ext in
      toml)
        # TOML 格式 (Gemini, Qwen) - 只支持 description 和 prompt
        local output_file="${namespace}${name}.$ext"
        {
          [[ -n "$description" ]] && echo "description = \"$description\""
          [[ -n "$description" ]] && echo
          echo "prompt = \"\"\""
          echo "$prompt_body"
          echo "\"\"\""
        } > "$output_dir/$output_file"
        ;;
      md|prompt.md)
        # Markdown 格式 - 根据 frontmatter_type 生成不同的输出
        local output_file="${namespace}${name}.$ext"

        case $frontmatter_type in
          none)
            # 纯 Markdown，无 frontmatter (Cursor, GitHub Copilot, Codex, Auggie, CodeBuddy, Amazon Q)
            echo "$prompt_body" > "$output_dir/$output_file"
            ;;
          minimal)
            # 最小 frontmatter，只有 description (OpenCode)
            {
              echo "---"
              [[ -n "$description" ]] && echo "description: $description"
              echo "---"
              echo
              echo "$prompt_body"
            } > "$output_dir/$output_file"
            ;;
          partial)
            # 部分 frontmatter，description + argument-hint (Roo Code, Windsurf, Kilo Code)
            {
              echo "---"
              [[ -n "$description" ]] && echo "description: $description"
              [[ -n "$argument_hint" ]] && echo "argument-hint: $argument_hint"
              echo "---"
              echo
              echo "$prompt_body"
            } > "$output_dir/$output_file"
            ;;
          full|*)
            # 完整 frontmatter，包含所有字段 (Claude)
            echo "$body" > "$output_dir/$output_file"
            ;;
        esac
        ;;
    esac
  done

  echo "    ✅ 完成 ($(ls "$output_dir" | wc -l | tr -d ' ') 个文件)"
}

# 复制支持文件到构建目录
copy_support_files() {
  local base_dir=$1
  local script_variant=$2

  local spec_dir="$base_dir/.specify"
  mkdir -p "$spec_dir"

  # 复制 memory 目录（如果存在）
  if [[ -d "$PROJECT_ROOT/memory" ]]; then
    cp -r "$PROJECT_ROOT/memory" "$spec_dir/"
    echo "    📁 复制 memory/ → .specify/"
  fi

  # 复制对应的脚本变体目录
  if [[ -d "$PROJECT_ROOT/scripts" ]]; then
    mkdir -p "$spec_dir/scripts"
    case $script_variant in
      sh)
        if [[ -d "$PROJECT_ROOT/scripts/bash" ]]; then
          cp -r "$PROJECT_ROOT/scripts/bash" "$spec_dir/scripts/"
          echo "    📁 复制 scripts/bash/ → .specify/scripts/"
        fi
        ;;
      ps)
        if [[ -d "$PROJECT_ROOT/scripts/powershell" ]]; then
          cp -r "$PROJECT_ROOT/scripts/powershell" "$spec_dir/scripts/"
          echo "    📁 复制 scripts/powershell/ → .specify/scripts/"
        fi
        ;;
    esac

    # 复制顶层脚本文件
    find "$PROJECT_ROOT/scripts" -maxdepth 1 -type f -exec cp {} "$spec_dir/scripts/" \; 2>/dev/null || true
  fi

  # 复制 templates（排除 commands 目录）
  if [[ -d "$PROJECT_ROOT/templates" ]]; then
    mkdir -p "$spec_dir/templates"
    find "$PROJECT_ROOT/templates" -type f -not -path "*/commands/*" -not -path "*/commands-*/*" | while read -r file; do
      rel_path="${file#$PROJECT_ROOT/templates/}"
      target_dir="$spec_dir/templates/$(dirname "$rel_path")"
      mkdir -p "$target_dir"
      cp "$file" "$target_dir/"
    done
    echo "    📁 复制 templates/ → .specify/templates/"
  fi

  # 复制 experts 目录（如果存在）
  if [[ -d "$PROJECT_ROOT/experts" ]]; then
    cp -r "$PROJECT_ROOT/experts" "$spec_dir/"
    echo "    📁 复制 experts/ → .specify/experts/"
  fi

  # 复制 spec 目录（包括 presets、反AI检测规范等）
  if [[ -d "$PROJECT_ROOT/spec" ]]; then
    local target_spec_dir="$base_dir/spec"
    mkdir -p "$target_spec_dir"

    # 复制 spec 目录下的所有内容（但排除 tracking 和 knowledge 的具体内容，保留目录结构）
    for item in "$PROJECT_ROOT/spec"/*; do
      if [[ -e "$item" ]]; then
        item_name=$(basename "$item")
        # 复制 presets、config.json 等到项目根 spec/
        if [[ "$item_name" != "tracking" && "$item_name" != "knowledge" ]]; then
          cp -r "$item" "$target_spec_dir/"
        else
          # tracking 和 knowledge 只创建空目录（模板在 templates/ 中）
          mkdir -p "$target_spec_dir/$item_name"
        fi
      fi
    done
    echo "    📁 复制 spec/ (presets, config.json 等)"
  fi
}

# 构建特定平台的变体
build_variant() {
  local agent=$1
  local script=$2

  echo
  echo "🏗️  构建 $agent ($script 脚本)..."
  echo "--------------------------------"

  local base_dir="$PROJECT_ROOT/dist/$agent"
  mkdir -p "$base_dir"

  # 复制支持文件
  copy_support_files "$base_dir" "$script"

  # 生成命令文件
  case $agent in
    claude)
      mkdir -p "$base_dir/.claude/commands"
      generate_commands claude md "\$ARGUMENTS" "$base_dir/.claude/commands" "$script" "novel." "full"
      ;;
    gemini)
      mkdir -p "$base_dir/.gemini/commands/novel"
      generate_commands gemini toml "{{args}}" "$base_dir/.gemini/commands/novel" "$script" "" ""
      ;;
    cursor)
      mkdir -p "$base_dir/.cursor/commands"
      generate_commands cursor md "\$ARGUMENTS" "$base_dir/.cursor/commands" "$script" "" "none"
      ;;
    windsurf)
      mkdir -p "$base_dir/.windsurf/workflows"
      generate_commands windsurf md "\$ARGUMENTS" "$base_dir/.windsurf/workflows" "$script" "" "partial"
      ;;
    roocode)
      mkdir -p "$base_dir/.roo/commands"
      generate_commands roocode md "\$ARGUMENTS" "$base_dir/.roo/commands" "$script" "" "partial"
      ;;
    copilot)
      mkdir -p "$base_dir/.github/prompts"
      generate_commands copilot prompt.md "\$ARGUMENTS" "$base_dir/.github/prompts" "$script" "" "none"
      ;;
    qwen)
      mkdir -p "$base_dir/.qwen/commands"
      generate_commands qwen toml "{{args}}" "$base_dir/.qwen/commands" "$script" "" ""
      ;;
    opencode)
      mkdir -p "$base_dir/.opencode/command"
      generate_commands opencode md "\$ARGUMENTS" "$base_dir/.opencode/command" "$script" "" "minimal"
      ;;
    codex)
      mkdir -p "$base_dir/.codex/prompts"
      generate_commands codex md "\$ARGUMENTS" "$base_dir/.codex/prompts" "$script" "novel-" "none"
      ;;
    kilocode)
      mkdir -p "$base_dir/.kilocode/workflows"
      generate_commands kilocode md "\$ARGUMENTS" "$base_dir/.kilocode/workflows" "$script" "" "partial"
      ;;
    auggie)
      mkdir -p "$base_dir/.augment/commands"
      generate_commands auggie md "\$ARGUMENTS" "$base_dir/.augment/commands" "$script" "" "none"
      ;;
    codebuddy)
      mkdir -p "$base_dir/.codebuddy/commands"
      generate_commands codebuddy md "\$ARGUMENTS" "$base_dir/.codebuddy/commands" "$script" "" "none"
      ;;
    q)
      mkdir -p "$base_dir/.amazonq/prompts"
      generate_commands q md "\$ARGUMENTS" "$base_dir/.amazonq/prompts" "$script" "" "none"
      ;;
  esac

  echo "  ✅ $agent 构建完成"
}

# 支持的平台和脚本类型
ALL_AGENTS=(claude gemini cursor windsurf roocode copilot qwen opencode codex kilocode auggie codebuddy q)
ALL_SCRIPTS=(sh ps)

# 解析命令行参数
AGENTS=()
SCRIPTS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --agents=*)
      IFS=',' read -ra AGENTS <<< "${1#*=}"
      shift
      ;;
    --scripts=*)
      IFS=',' read -ra SCRIPTS <<< "${1#*=}"
      shift
      ;;
    --help)
      echo "用法: $0 [选项]"
      echo
      echo "选项:"
      echo "  --agents=AGENT1,AGENT2   指定要构建的平台 (默认: 全部)"
      echo "                           可选: claude,gemini,cursor,windsurf,roocode,copilot,qwen,opencode,codex,kilocode,auggie,codebuddy,q"
      echo "  --scripts=SCRIPT1,...    指定脚本类型 (默认: 全部)"
      echo "                           可选: sh,ps"
      echo "  --help                   显示此帮助信息"
      echo
      echo "示例:"
      echo "  $0                                    # 构建所有平台和脚本"
      echo "  $0 --agents=claude --scripts=sh       # 只构建 Claude (sh)"
      echo "  $0 --agents=claude,gemini             # 构建 Claude 和 Gemini (所有脚本)"
      exit 0
      ;;
    *)
      echo "未知参数: $1"
      echo "使用 --help 查看帮助"
      exit 1
      ;;
  esac
done

# 如果未指定，使用全部
[[ ${#AGENTS[@]} -eq 0 ]] && AGENTS=("${ALL_AGENTS[@]}")
[[ ${#SCRIPTS[@]} -eq 0 ]] && SCRIPTS=("${ALL_SCRIPTS[@]}")

echo "📋 构建配置:"
echo "  平台: ${AGENTS[*]}"
echo "  脚本: ${SCRIPTS[*]}"

# 执行构建
for agent in "${AGENTS[@]}"; do
  for script in "${SCRIPTS[@]}"; do
    build_variant "$agent" "$script"
  done
done

echo
echo "================================"
echo "✅ 构建完成！"
echo
echo "📦 构建产物位于: $PROJECT_ROOT/dist/"
echo
echo "目录结构:"
tree -L 3 "$PROJECT_ROOT/dist/" 2>/dev/null || find "$PROJECT_ROOT/dist/" -type d | head -20

echo
echo "💡 提示:"
echo "  - Claude 用户: 使用 /novel.constitution, /novel.specify 等命令"
echo "  - Gemini 用户: 使用 /novel:constitution, /novel:specify 等命令"
echo "  - 其他用户: 使用 /constitution, /specify 等命令"
