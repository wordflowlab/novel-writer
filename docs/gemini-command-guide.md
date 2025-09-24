# Gemini 命令开发指南

本指南说明如何为 novel-writer 项目开发同时支持 Markdown 和 TOML 格式的斜杠命令。

## 目录结构

```
templates/
├── commands/              # Markdown 格式（Claude/Cursor/Windsurf）
│   └── example.md
└── commands-gemini/       # TOML 格式（Gemini CLI）
    └── example.toml
```

## 开发新命令

### 步骤 1：创建 Markdown 版本

在 `templates/commands/` 目录创建 markdown 文件：

```markdown
---
description: 命令的简短描述
scripts:
  sh: .specify/scripts/bash/example.sh
  ps: .specify/scripts/powershell/example.ps1
---

# 命令名称

命令的详细说明...

## AI 执行指南

详细的执行步骤...
```

### 步骤 2：创建 TOML 版本

在 `templates/commands-gemini/` 目录创建对应的 TOML 文件：

```toml
description = "命令的简短描述"

prompt = """
命令的执行提示。

用户输入：{{args}}

## 执行步骤

### 1. 步骤一
详细说明...

### 2. 步骤二
使用工具...

## 注意事项
- 要点1
- 要点2
"""
```

## TOML 格式规范

### 变量占位符
- `{{args}}` - 用户输入的参数

### Shell 命令执行
- `!{command}` - 执行 shell 命令并获取输出
- 示例：`!{date '+%Y-%m-%d'}` 获取当前日期

### 文件内容注入
- `@{file}` - 注入文件内容
- 示例：`@{spec/knowledge/world-setting.md}`

### 工具调用
Gemini 使用的工具名称：
- `read_file` - 读取文件
- `write_file` - 创建文件
- `edit_file` - 编辑文件
- `run_shell_command` - 执行命令
- `glob_files` - 搜索文件

## 命名空间命令

对于带命名空间的命令（如 `/track:init`），使用子目录：

```
templates/commands-gemini/
├── track/
│   └── init.toml      # 对应 /track:init
├── plot/
│   └── check.toml     # 对应 /plot:check
└── world/
    └── check.toml     # 对应 /world:check
```

## 示例：完整的命令对

### Markdown 版本 (templates/commands/example.md)

```markdown
---
description: 示例命令 - 展示如何创建双格式命令
scripts:
  sh: .specify/scripts/bash/example.sh
---

# 示例命令

这是一个示例命令的说明。

## AI 执行指南

当用户输入 `/example` 时：

1. 读取配置文件
2. 执行相应操作
3. 生成结果报告
```

### TOML 版本 (templates/commands-gemini/example.toml)

```toml
description = "示例命令 - 展示如何创建双格式命令"

prompt = """
执行示例命令。

用户输入：{{args}}

## 执行步骤

1. 读取配置
   使用 read_file 读取 .specify/config.json

2. 执行操作
   运行脚本：!{.specify/scripts/bash/example.sh}

3. 生成报告
   使用 write_file 创建报告文件

## 完成提示
✅ 示例命令执行完成！
"""
```

## 插件命令支持

插件也应该提供双格式支持：

```
plugins/example-plugin/
├── commands/              # Markdown 格式
│   └── plugin-cmd.md
├── commands-gemini/       # TOML 格式（可选）
│   └── plugin-cmd.toml
└── config.yaml
```

## 测试命令

### 测试 Markdown 格式
```bash
novel init test-project --ai claude
# 检查 .claude/commands/ 目录
```

### 测试 TOML 格式
```bash
novel init test-project --ai gemini
# 检查 .gemini/commands/ 目录
```

### 测试所有格式
```bash
novel init test-project --all
# 检查所有 AI 目录
```

## 最佳实践

1. **保持一致性**：两种格式的功能应该完全一致
2. **简洁明了**：TOML 版本的 prompt 应该更简洁
3. **工具适配**：使用各自平台的工具调用格式
4. **测试充分**：在两种环境中都要测试
5. **文档完善**：更新命令列表和使用说明

## 注意事项

1. TOML 格式不支持 YAML frontmatter
2. Gemini 的工具调用格式与 Claude/Cursor 不同
3. 路径处理要考虑不同平台差异
4. 命名空间使用目录结构而非文件名

## 维护建议

- 定期检查两种格式的同步性
- 使用版本控制跟踪变更
- 为新功能同时创建两种格式
- 保持向后兼容性

---
更新日期：2024
版本：1.0.0