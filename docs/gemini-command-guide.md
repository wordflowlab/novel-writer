# Gemini 命令开发指南

本指南说明如何为 novel-writer 项目开发跨平台斜杠命令（Claude、Gemini、Cursor、Windsurf、Roo Code）。

## 架构概述（v0.15.0+）

Novel Writer 使用**单一源 + 构建系统**架构：

```
templates/
└── commands/                  # 单一源文件（Markdown 格式）
    ├── analyze.md
    ├── specify.md
    └── ...

scripts/build/
└── generate-commands.sh       # 构建脚本（自动生成所有平台命令）

dist/                          # 构建产物（发布到 npm）
├── claude/.claude/commands/   # 带 novel.* 前缀
│   ├── novel.analyze.md
│   └── novel.specify.md
├── gemini/.gemini/commands/novel/  # novel/ 子目录
│   ├── analyze.toml
│   └── specify.toml
├── cursor/.cursor/commands/   # 标准命名
├── windsurf/.windsurf/workflows/
└── roocode/.roocode/commands/
```

### 核心原则

1. **单一源**：只维护 `templates/commands/` 中的 Markdown 文件
2. **构建生成**：运行 `npm run build:commands` 自动生成所有平台命令
3. **命名空间**：自动添加命名空间前缀（Claude: `novel.*`，Gemini: `novel/`）
4. **发布时构建**：`npm publish` 时自动构建，用户获得的是构建产物

## 开发新命令

### 步骤 1：创建源文件（唯一需要手动操作的步骤）

在 `templates/commands/` 目录创建 Markdown 文件：

```markdown
---
description: 命令的简短描述
argument-hint: [参数提示]
allowed-tools: Read(//stories/**), Write(//stories/**), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/example.sh
  ps: .specify/scripts/powershell/example.ps1
---

用户输入：$ARGUMENTS

# 命令名称

命令的详细说明...

## AI 执行指南

详细的执行步骤...
```

### 步骤 2：构建所有平台版本（自动）

```bash
npm run build:commands
```

这个命令会自动：
1. 读取 `templates/commands/` 中的所有命令
2. 为 Claude 生成 `novel.*.md` 格式（带命名空间前缀）
3. 为 Gemini 转换为 TOML 格式并放入 `novel/` 子目录
4. 为其他平台生成标准格式
5. 输出到 `dist/` 目录

## 构建系统详解

### 自动转换规则

构建脚本 `scripts/build/generate-commands.sh` 会自动处理：

#### 1. 命名空间添加
- **Claude**: `analyze.md` → `novel.analyze.md`
- **Gemini**: `analyze.md` → `novel/analyze.toml`（子目录）
- **其他平台**: `analyze.md`（无命名空间）

#### 2. 格式转换（Markdown → TOML）
```markdown
---
description: 分析创作质量
---

用户输入：$ARGUMENTS
内容...
```

自动转换为：
```toml
description = "分析创作质量"

prompt = """
用户输入：{{args}}
内容...
"""
```

#### 3. 变量替换
- `$ARGUMENTS` → `{{args}}` （Gemini 格式）
- 脚本路径自动复制到 `.specify/scripts/`

### 构建命令

```bash
# 构建所有平台
npm run build:commands

# 手动构建（开发用）
bash scripts/build/generate-commands.sh \
  --agents=claude,gemini,cursor,windsurf,roocode \
  --scripts=sh

# 只构建特定平台
bash scripts/build/generate-commands.sh --agents=claude,gemini
```

## TOML 格式规范（自动生成）

构建系统会自动处理以下转换，**无需手动创建 TOML 文件**：

### 变量占位符
- Markdown: `$ARGUMENTS` → TOML: `{{args}}`

### 工具调用
Gemini 使用的工具名称（参考）：
- `read_file` - 读取文件
- `write_file` - 创建文件
- `edit_file` - 编辑文件
- `run_shell_command` - 执行命令
- `glob_files` - 搜索文件

## 开发示例

### 步骤 1：创建源文件

在 `templates/commands/example.md` 创建：

```markdown
---
description: 示例命令 - 展示命令开发流程
argument-hint: [可选参数说明]
allowed-tools: Read(//**), Write(//stories/**), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/example.sh
---

用户输入：$ARGUMENTS

# 示例命令

这是一个示例命令的说明。

## AI 执行指南

当用户输入 `/example` 时：

1. 读取配置文件
2. 执行相应操作
3. 生成结果报告
```

### 步骤 2：运行构建

```bash
npm run build:commands
```

### 步骤 3：验证构建产物

构建后自动生成：

**Claude 版本** (`dist/claude/.claude/commands/novel.example.md`):
```markdown
---
description: 示例命令 - 展示命令开发流程
argument-hint: [可选参数说明]
allowed-tools: Read(//**), Write(//stories/**), Bash(*)
model: claude-sonnet-4-5-20250929
---

用户输入：$ARGUMENTS
...
```

**Gemini 版本** (`dist/gemini/.gemini/commands/novel/example.toml`):
```toml
description = "示例命令 - 展示命令开发流程"

prompt = """
用户输入：{{args}}

# 示例命令

这是一个示例命令的说明。

## AI 执行指南

当用户输入 `/example` 时：

1. 读取配置文件
2. 执行相应操作
3. 生成结果报告
"""
```

## 插件命令支持

插件现在也使用单一源架构，CLI 会自动处理构建。

插件目录结构（v0.15.0+）：
```
plugins/example-plugin/
├── commands-claude/       # 单一源（Markdown）
│   └── plugin-cmd.md
├── dist/                  # 构建产物（自动生成）
│   ├── claude/
│   ├── gemini/
│   └── ...
└── config.yaml
```

## 测试命令

### 1. 构建测试
```bash
# 清理旧构建
rm -rf dist/

# 构建所有平台
npm run build:commands

# 检查构建产物
ls dist/claude/.claude/commands/novel.*
ls dist/gemini/.gemini/commands/novel/
```

### 2. 初始化测试
```bash
# 测试 Claude 安装
novel init test-project --ai claude
ls test-project/.claude/commands/novel.*

# 测试 Gemini 安装
novel init test-project-gemini --ai gemini
ls test-project-gemini/.gemini/commands/novel/

# 测试所有平台
novel init test-all --all
```

### 3. 升级测试
```bash
# 在现有项目测试升级
cd existing-project
novel upgrade
ls .claude/commands/novel.*
```

## 最佳实践

### 开发流程
1. **单一源维护**：只编辑 `templates/commands/` 中的 Markdown 文件
2. **及时构建**：修改后立即运行 `npm run build:commands` 验证
3. **测试覆盖**：至少在 Claude 和 Gemini 两个平台测试
4. **命名一致**：文件名使用小写和连字符（如 `plot-check.md`）
5. **文档同步**：更新命令时同步更新 README.md

### 代码质量
1. **描述清晰**：`description` 字段简洁明确（< 50 字符）
2. **参数提示**：使用 `argument-hint` 提供参数示例（仅 Claude）
3. **权限最小化**：`allowed-tools` 只授予必要权限（仅 Claude）
4. **模型适配**：根据任务复杂度选择合适的 `model`（仅 Claude）
5. **脚本路径**：确保 `scripts.sh` 和 `scripts.ps` 正确
6. **Gemini 兼容**：记住 Gemini 只支持 `description` 和 `prompt`

### 命名空间原则
1. **避免冲突**：命名空间确保与其他工具（如 spec-kit）不冲突
2. **用户透明**：用户仍使用 `/specify` 而非 `/novel.specify`
3. **文件组织**：
   - Claude: 使用 `novel.*` 前缀
   - Gemini: 使用 `novel/` 子目录
   - 其他平台：标准命名（无命名空间）

## 构建系统维护

### 修改构建脚本

如需修改构建逻辑，编辑 `scripts/build/generate-commands.sh`：

```bash
# 关键函数
generate_commands() {
  local agent=$1      # claude, gemini, etc.
  local format=$2     # md, toml
  local args_var=$3   # $ARGUMENTS or {{args}}
  local output_dir=$4
  local script=$5
  local namespace=$6  # novel (for claude) or empty
}
```

### 添加新平台

1. 在 `generate-commands.sh` 中添加平台配置
2. 实现格式转换逻辑（如需要）
3. 更新 `package.json` 的 `build:commands` 脚本
4. 测试构建和安装流程

## 故障排查

### 构建失败
```bash
# 检查源文件语法
head -20 templates/commands/problematic.md

# 手动运行构建查看详细错误
bash -x scripts/build/generate-commands.sh --agents=claude
```

### 命令不生效
```bash
# 检查构建产物是否存在
ls dist/claude/.claude/commands/

# 检查 npm pack 是否包含构建产物
npm pack --dry-run | grep dist/

# 检查安装后的文件
npm list -g novel-writer-cn
ls ~/.npm-global/lib/node_modules/novel-writer-cn/dist/
```

### 命名空间问题
```bash
# Claude 文件必须有 novel.* 前缀
ls .claude/commands/ | grep ^novel\\.

# Gemini 文件必须在 novel/ 子目录
ls .gemini/commands/novel/
```

## 版本兼容性

### v0.15.0+ (当前)
- ✅ 单一源 + 构建系统
- ✅ 命名空间支持
- ✅ 自动格式转换

### v0.12.2-v0.14.x (旧版)
- ⚠️ 双源模式（commands-claude/ + commands-gemini/）
- ⚠️ 手动维护多个格式
- ⚠️ 无命名空间

### 迁移建议
旧项目升级到 v0.15.0+:
```bash
novel upgrade  # 自动迁移到新架构
```

---
更新日期：2025-10-11
版本：2.0.0 (v0.15.0+ 架构)