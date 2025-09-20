# Novel Writer - AI 驱动的中文小说创作工具

[![npm version](https://badge.fury.io/js/%40novel%2Fwriter.svg)](https://badge.fury.io/js/%40novel%2Fwriter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> 🚀 基于结构化工作流和 AI 技术的智能小说创作助手

## ✨ 特性

- 📚 **结构化创作流程** - 从构思到成稿的完整工作流
- 🤖 **AI 智能辅助** - 支持 Claude、Gemini、通义千问等 AI 助手
- 🎯 **中文优化** - 专为中文小说创作设计
- 📝 **丰富的模板** - 提供多种类型小说的创作模板
- 🔄 **版本管理** - 集成 Git 进行草稿版本控制
- 📊 **进度追踪** - 实时跟踪创作进度和字数统计

## 🚀 快速开始

### 安装

```bash
# 使用 npm 安装
npm install -g @novel/writer

# 或使用 yarn
yarn global add @novel/writer

# 或使用 pnpm
pnpm add -g @novel/writer
```

### 创建第一本小说

```bash
# 1. 初始化小说项目
novel init "我的第一本小说" --ai claude --genre 科幻

# 2. 进入项目目录
cd 我的第一本小说

# 3. 设定创作风格
novel style

# 4. 创建故事大纲
novel story

# 5. 规划章节结构
novel outline

# 6. 开始写作第一章
novel write --chapter 1
```

## 📖 命令详解

### `novel init <name>`
初始化一个新的小说项目

**参数：**
- `name` - 小说项目名称

**选项：**
- `--ai <type>` - 选择 AI 助手 (claude/gemini/qwen)
- `--genre <type>` - 小说类型 (科幻/奇幻/现实/历史/言情/悬疑)

**示例：**
```bash
novel init "星际漫游" --ai claude --genre 科幻
```

### `novel style`
设定个人写作风格和创作准则

**选项：**
- `--template <name>` - 使用预设模板 (网文/文学/轻小说)

**示例：**
```bash
novel style --template 网文
```

### `novel story [description]`
创建故事大纲、角色设定和世界观

**参数：**
- `description` - 故事的简要描述（可选）

**选项：**
- `--interactive` - 交互式创建

**示例：**
```bash
novel story "一个关于时间旅行者拯救世界的故事"
```

### `novel outline`
制定详细的章节结构和情节安排

**选项：**
- `--chapters <number>` - 预计章节数（默认 30）
- `--words-per-chapter <number>` - 每章字数（默认 3000）

**示例：**
```bash
novel outline --chapters 50 --words-per-chapter 4000
```

### `novel tasks`
将章节分解为具体的写作任务

**选项：**
- `--priority` - 按优先级排序任务

**示例：**
```bash
novel tasks --priority
```

### `novel write`
AI 辅助执行实际内容创作

**选项：**
- `--chapter <number>` - 指定章节编号
- `--mode <type>` - 创作模式 (draft/refine)

**示例：**
```bash
novel write --chapter 1 --mode draft
```

## 📁 项目结构

创建的小说项目包含以下目录结构：

```
我的小说/
├── .novel/           # 配置文件目录
│   ├── config.json   # 项目配置
│   ├── style.json    # 风格设置
│   └── story.json    # 故事数据
├── chapters/         # 章节内容
├── characters/       # 角色设定
├── world/           # 世界观设定
├── outlines/        # 章节大纲
├── drafts/          # 草稿
└── notes/           # 创作笔记
```

## 🎨 创作模板

### 预设风格模板

- **网文风格** - 爽点密集、节奏明快、代入感强
- **文学风格** - 深度思考、人性探索、艺术表达
- **轻小说风格** - 轻松愉快、角色可爱、日常温馨

### 小说类型模板

支持多种小说类型：
- 科幻、奇幻、现实、历史
- 言情、悬疑、武侠、仙侠

## 🤝 AI 助手集成

### 支持的 AI 助手

- **Claude** - Anthropic 的 AI 助手
- **Gemini** - Google 的 AI 助手
- **通义千问** - 阿里云的 AI 助手

### 配置 AI 助手

在项目根目录创建 `.env` 文件：

```env
# Claude API
CLAUDE_API_KEY=your_claude_api_key

# Gemini API
GEMINI_API_KEY=your_gemini_api_key

# 通义千问 API
QWEN_API_KEY=your_qwen_api_key
```

## 📊 功能特色

### 智能创作辅助
- 自动生成故事大纲
- 角色性格分析
- 情节逻辑检查
- 文风一致性维护

### 进度管理
- 字数统计
- 更新计划
- 任务追踪
- 里程碑设置

### 版本控制
- Git 集成
- 草稿管理
- 修订历史
- 多版本对比

## 🛠️ 开发

### 本地开发

```bash
# 克隆仓库
git clone https://github.com/novel-writer/novel-writer.git

# 安装依赖
cd novel-writer
npm install

# 开发模式
npm run dev

# 构建
npm run build
```

### 项目结构

```
novel-writer/
├── src/
│   ├── cli.ts          # CLI 入口
│   ├── commands/       # 命令实现
│   ├── templates/      # 模板引擎
│   └── utils/          # 工具函数
├── templates/          # 创作模板
└── package.json        # 项目配置
```

## 📚 文档

- [使用指南](https://github.com/novel-writer/novel-writer/wiki/使用指南)
- [API 文档](https://github.com/novel-writer/novel-writer/wiki/API文档)
- [贡献指南](https://github.com/novel-writer/novel-writer/blob/main/CONTRIBUTING.md)

## 🤔 常见问题

### Q: 支持哪些操作系统？
A: 支持 Windows、macOS 和 Linux。

### Q: 需要付费吗？
A: Novel Writer 本身免费开源，但使用 AI 助手可能需要相应的 API 密钥。

### Q: 可以离线使用吗？
A: 基础功能可以离线使用，但 AI 辅助功能需要网络连接。

### Q: 如何备份我的小说？
A: 项目集成了 Git，可以使用 Git 命令进行版本管理和备份。

## 🙏 致谢

本项目参考了 [Spec Kit](https://github.com/github/spec-kit) 的架构设计，特此感谢！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 👥 贡献

欢迎提交 Issue 和 Pull Request！

## 📮 联系我们

- GitHub: [https://github.com/novel-writer/novel-writer](https://github.com/novel-writer/novel-writer)
- Email: support@novelwriter.io

---

**Novel Writer** - 让创作更简单，让故事更精彩！ ✨📚