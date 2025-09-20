# Novel Writer - AI 驱动的中文小说创作工具

[![npm version](https://badge.fury.io/js/novel-writer-cn.svg)](https://www.npmjs.com/package/novel-writer-cn)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 🚀 基于 Spec Kit 架构的 AI 智能小说创作助手

## ✨ 特性

- 📚 **AI 斜杠命令** - 在 Claude、Cursor、Gemini 等 AI 助手中直接使用
- 🎯 **结构化创作** - 从风格设定到章节写作的完整工作流
- 🤖 **智能辅助** - AI 理解上下文，提供针对性创作建议
- 📝 **中文优化** - 专为中文小说创作设计的命令和模板
- 🔄 **跨平台支持** - Windows PowerShell 和 Unix/Linux Bash 脚本

## 🚀 快速开始

### 安装

```bash
npm install -g novel-writer-cn
```

### 初始化项目

```bash
# 创建新的小说项目
novel init my-novel

# 或在当前目录初始化
novel init --here
```

### 在 AI 助手中使用斜杠命令

初始化后，在 Claude、Cursor 或其他 AI 助手中使用以下斜杠命令：

1. **`/style`** - 设定创作风格和准则
2. **`/story`** - 创建故事大纲、角色和世界观
3. **`/outline`** - 规划详细的章节结构
4. **`/chapters`** - 生成具体的写作任务
5. **`/write`** - AI 辅助写作章节内容

## 📖 斜杠命令详解

### `/style` - 设定创作风格

设定你的创作风格，包括：
- 叙事视角（第一人称/第三人称）
- 文字风格（简洁明快/华丽优美）
- 创作原则
- 质量标准

### `/story` - 创建故事大纲

创建完整的故事设定：
- 故事概述和核心冲突
- 主要角色设定
- 世界观和背景
- 情节大纲（起承转合）

示例：
```
/story 一个关于穿越者在修仙世界的冒险故事
```

### `/outline` - 章节规划

制定详细的章节结构：
- 总体结构和章节数
- 卷/部划分
- 每章主要事件
- 节奏控制和高潮分布

### `/chapters` - 任务分解

将章节规划分解为可执行的任务：
- 章节写作任务
- 角色完善任务
- 世界观补充
- 修订任务

### `/write` - 章节写作

AI 辅助创作具体章节内容：
- 根据大纲创作
- 保持风格一致
- 角色性格连贯
- 情节逻辑清晰

## 📁 项目结构

```
my-novel/
├── .specify/          # Spec Kit 配置
│   └── spec.md        # 命令规范文档
├── memory/            # 创作记忆
│   └── writing-constitution.md
├── stories/           # 故事内容
│   └── 001-故事名/
│       ├── story.md   # 故事大纲
│       ├── outline.md # 章节规划
│       ├── tasks.md   # 任务列表
│       └── chapters/  # 章节内容
└── scripts/           # 支持脚本
    ├── bash/          # Unix/Linux/Mac
    └── powershell/    # Windows
```

## 🤖 支持的 AI 助手

- **Claude** (推荐) - Anthropic 的 AI 助手
- **Cursor** - AI 代码编辑器
- **Gemini** - Google 的 AI 助手
- 其他支持斜杠命令的 AI 工具

## 🛠️ CLI 命令

### `novel init [name]`

初始化小说项目

**选项：**
- `--here` - 在当前目录初始化
- `--ai <type>` - 选择 AI 助手类型 (claude/cursor/gemini)

### `novel check`

检查项目配置和状态

## 📚 工作流程

1. **初始化项目**
   ```bash
   novel init my-novel
   cd my-novel
   ```

2. **设定创作风格**
   在 AI 助手中使用 `/style` 命令设定你的创作风格

3. **创建故事大纲**
   使用 `/story` 命令，提供故事描述，AI 会帮助创建完整大纲

4. **规划章节**
   使用 `/outline` 命令制定详细的章节结构

5. **生成任务**
   使用 `/chapters` 命令将规划分解为具体任务

6. **开始写作**
   使用 `/write` 命令，AI 会根据大纲协助创作

## 🎯 最佳实践

- **保持一致性**：始终参考 `memory/writing-constitution.md` 中的风格设定
- **循序渐进**：按照工作流程顺序使用命令
- **版本管理**：使用 Git 管理你的创作版本
- **定期备份**：重要内容及时备份

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

项目地址：[https://github.com/wordflowlab/novel-writer](https://github.com/wordflowlab/novel-writer)

## 📄 许可证

MIT License

## 🙏 致谢

本项目基于 [Spec Kit](https://github.com/sublayerapp/spec-kit) 架构设计，特此感谢！

---

**Novel Writer** - 让 AI 成为你的创作伙伴！ ✨📚