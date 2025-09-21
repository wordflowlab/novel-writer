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

### 🆕 v0.4.0 新增功能

- 🔍 **情节追踪** - 追踪情节节点、伏笔和冲突发展
- ⏰ **时间线管理** - 维护故事时间轴，确保时间逻辑一致
- 👥 **关系矩阵** - 管理角色关系和派系动态
- 🌍 **世界观检查** - 验证设定一致性，避免矛盾
- ✅ **一致性检查** - 全方位验证小说的逻辑连贯性

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

#### 基础创作命令
1. **`/style`** - 设定创作风格和准则
2. **`/story`** - 创建故事大纲、角色和世界观
3. **`/outline`** - 规划详细的章节结构
4. **`/chapters`** - 生成具体的写作任务
5. **`/write`** - AI 辅助写作章节内容

#### 追踪管理命令 (v0.4.0 新增)
6. **`/plot-check`** - 检查情节发展的一致性
7. **`/timeline`** - 管理和验证故事时间线
8. **`/relations`** - 追踪角色关系变化
9. **`/world-check`** - 验证世界观设定一致性
10. **`/track`** - 综合追踪创作进度和内容

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

### `/plot-check` - 情节检查 (v0.4.0 新增)

检查情节发展的一致性和连贯性：
- 验证当前进度与大纲规划是否一致
- 追踪已埋设的伏笔和回收计划
- 确认冲突升级符合预期节奏
- 验证角色发展与规划一致

### `/timeline` - 时间线管理 (v0.4.0 新增)

维护和验证故事时间线：
- 追踪每个章节的时间点
- 管理同时发生的多线剧情
- 与真实历史事件对比（历史小说）
- 检查时间跨度的合理性

### `/relations` - 关系追踪 (v0.4.0 新增)

管理和追踪角色关系变化：
- 维护角色之间的关系图谱
- 记录关系的演变历程
- 追踪各势力派系的对立与合作
- 管理角色间的情感发展

### `/world-check` - 世界观检查 (v0.4.0 新增)

验证世界观设定的一致性：
- 验证规则、法则、体系的一致
- 检查地点、距离、方位的合理性
- 确保风俗、语言、传统的统一
- 验证能力范围和限制

### `/track` - 综合追踪 (v0.4.0 新增)

全面展示小说创作的各项进度和状态：
- 写作进度（字数、章节、完成率）
- 情节发展（主线进度、支线状态）
- 时间线（故事时间推进）
- 角色状态（角色发展和位置）
- 伏笔管理（埋设和回收状态）

## 📁 项目结构

```
my-novel/
├── .specify/          # Spec Kit 配置
│   ├── spec.md        # 命令规范文档
│   ├── memory/        # 创作记忆
│   └── scripts/       # 支持脚本
├── .claude/           # Claude 命令
│   └── commands/      # 斜杠命令文件
├── spec/              # 小说规格数据 (v0.4.0 新增)
│   ├── tracking/      # 动态追踪
│   │   ├── plot-tracker.json      # 情节追踪
│   │   ├── timeline.json          # 时间线
│   │   ├── relationships.json     # 关系矩阵
│   │   └── character-state.json   # 角色状态
│   └── knowledge/     # 知识库
│       ├── world-setting.md       # 世界观设定
│       ├── character-profiles.md  # 角色档案
│       └── locations.md           # 场景地点
├── stories/           # 故事内容
│   └── 001-故事名/
│       ├── story.md   # 故事大纲
│       ├── outline.md # 章节规划
│       ├── progress.json # 进度追踪
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

### 基础创作流程

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

### 质量保障流程 (v0.4.0 新增)

7. **情节检查**
   定期使用 `/plot-check` 确保情节发展与大纲一致，追踪伏笔状态

8. **时间线验证**
   使用 `/timeline` 管理时间节点，验证时间逻辑的合理性

9. **关系维护**
   使用 `/relations` 追踪角色关系变化，确保人物互动合理

10. **世界观验证**
    使用 `/world-check` 检查设定一致性，避免前后矛盾

11. **综合追踪**
    使用 `/track` 查看整体创作状态，获取全局视图

## 🎯 最佳实践

### 创作建议
- **保持一致性**：始终参考 `memory/writing-constitution.md` 中的风格设定
- **循序渐进**：按照工作流程顺序使用命令
- **版本管理**：使用 Git 管理你的创作版本
- **定期备份**：重要内容及时备份

### 质量控制 (v0.4.0 新增)
- **定期检查**：每写完 5-10 章执行一次 `/plot-check`
- **时间线同步**：每个重要事件后更新 `/timeline`
- **关系追踪**：角色关系发生变化时及时更新
- **设定记录**：新增世界观设定立即记录到知识库
- **综合验证**：每卷结束时运行 `/track` 全面检查

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

项目地址：[https://github.com/wordflowlab/novel-writer](https://github.com/wordflowlab/novel-writer)

## 📄 许可证

MIT License

## 🙏 致谢

本项目基于 [Spec Kit](https://github.com/sublayerapp/spec-kit) 架构设计，特此感谢！

---

**Novel Writer** - 让 AI 成为你的创作伙伴！ ✨📚