# 为什么 Novel Writer 不支持 OpenAI Codex

## TL;DR

Novel Writer 目前**不支持** OpenAI Codex CLI，主要原因是：

1. **Codex Custom Prompts 功能受限** - 仅支持纯文本提示，无法执行脚本和文件操作
2. **Novel Writer 命令复杂度高** - 93% 的命令（13/14）依赖脚本进行状态管理和自动化验证
3. **等待官方 Slash Commands** - 一旦 Codex 支持完整的 slash commands 功能，我们会立即适配

**推荐替代方案**：使用 [Claude Code](https://claude.ai)、[Cursor](https://cursor.sh) 或 [Google Gemini CLI](https://ai.google.dev/gemini-api/docs/cli)，它们完全支持 Novel Writer 的所有功能。

---

## 📊 技术对比分析

### Codex Custom Prompts vs Novel Writer Commands

| 维度 | Codex Custom Prompts | Novel Writer Commands | 兼容性 |
|------|---------------------|----------------------|--------|
| **文件格式** | 纯 Markdown | Markdown + YAML Frontmatter | ⚠️ 部分 |
| **脚本执行** | ❌ 不支持 | ✅ Bash + PowerShell | ❌ 冲突 |
| **文件操作** | ❌ 需 AI 手动执行 | ✅ 自动化检查和创建 | ❌ 冲突 |
| **状态管理** | ❌ 无结构化返回 | ✅ JSON 格式状态数据 | ❌ 冲突 |
| **参数系统** | ✅ `$1..$9`, `$ARGUMENTS` | ✅ `$ARGUMENTS`, `{SCRIPT}` | ✅ 兼容 |
| **位置** | 全局 `~/.codex/prompts/` | 项目级 `.claude/commands/` | ⚠️ 不同 |
| **复杂度** | 简单提示 | 完整工作流引擎 | ❌ 冲突 |

### 关键差异：脚本执行能力

**Codex Custom Prompts** 的核心限制：

```markdown
<!-- Codex prompt 文件示例 -->
帮我检查故事目录，统计章节数量，然后决定使用框架分析还是内容分析。

步骤：
1. 查找 stories/*/content/ 目录
2. 统计 .md 文件数量
3. 如果章节数 < 3，使用框架分析
4. 否则使用内容分析
```

❌ **问题**：
- 完全依赖 AI 理解和手动执行
- 无法保证执行的准确性和一致性
- 无法返回结构化数据供后续命令使用

**Novel Writer Commands** 的实现：

```yaml
---
description: 智能双模式分析
scripts:
  sh: .specify/scripts/bash/check-analyze-stage.sh --json
  ps: .specify/scripts/powershell/check-analyze-stage.ps1 -Json
---
```

```bash
#!/bin/bash
# check-analyze-stage.sh - 返回结构化的分析阶段数据

# 统计章节数
CHAPTER_COUNT=$(find "$CONTENT_DIR" -maxdepth 1 -type f -name "*.md" | wc -l)

# 检查文件
HAS_SPEC=$([ -f "$STORY_DIR/specification.md" ] && echo true || echo false)

# 返回 JSON
echo "{\"type\": \"$ANALYZE_TYPE\", \"chapters\": $CHAPTER_COUNT, \"hasSpec\": $HAS_SPEC}"
```

✅ **优势**：
- 自动化执行，100% 准确
- 返回结构化数据供 AI 使用
- 前置条件自动验证
- 跨平台兼容（Bash + PowerShell）

---

## 🔍 命令系统依赖分析

### 统计数据

Novel Writer 共有 **14 个核心命令**：

- ✅ **纯提示型**：1 个（7%）- `expert`
- ❌ **脚本依赖型**：13 个（93%）- 其他所有命令

### 脚本依赖的命令清单

| 命令 | 脚本功能 | 能否用纯提示替代？ |
|------|---------|------------------|
| `/analyze` | 检测阶段、统计章节、返回 JSON | ❌ 需准确计数 |
| `/clarify` | 查找故事文件、提取路径、JSON 输出 | ❌ 需路径准确性 |
| `/constitution` | 检查文件版本、迁移旧文件、初始化 | ❌ 需文件操作 |
| `/plan` | 验证规格、检查依赖、创建目录 | ❌ 需状态验证 |
| `/plot-check` | 加载追踪数据、验证节点、对比大纲 | ❌ 需数据解析 |
| `/relations` | 管理关系矩阵、更新 JSON、验证一致性 | ❌ 需结构化数据 |
| `/specify` | 创建规格文件、验证模板、返回状态 | ❌ 需文件管理 |
| `/tasks` | 生成任务清单、分配优先级、JSON 格式 | ❌ 需结构化输出 |
| `/timeline` | 解析时间节点、验证逻辑、可视化数据 | ❌ 需时间计算 |
| `/track-init` | 初始化追踪系统、创建 JSON 文件 | ❌ 需数据初始化 |
| `/track` | 统计进度、计算完成率、聚合数据 | ❌ 需多源数据 |
| `/world-check` | 验证设定一致性、对比知识库 | ❌ 需多文件对比 |
| `/write` | 检查写作状态、加载上下文、验证依赖 | ❌ 需状态检查 |

**结论**：仅有 `/expert` 命令（纯 AI 对话）可以用 Codex prompts 实现。

---

## 🏗️ 架构设计哲学差异

### Codex Custom Prompts：轻量化快速提示

**设计目标**：
- 快速保存常用提示
- 减少重复输入
- 个人效率工具

**适用场景**：
```markdown
<!-- ~/.codex/prompts/explain.md -->
请详细解释以下代码的工作原理：

$ARGUMENTS
```

**特点**：
- 🎯 简单直接
- ⚡ 快速启动
- 👤 个人化

### Novel Writer Commands：工作流引擎

**设计目标**：
- 系统化创作流程
- 自动化状态管理
- 跨项目一致性

**适用场景**：
```yaml
# 七步方法论的完整工作流
constitution → specify → clarify → plan → tasks → write → analyze
     ↓            ↓         ↓        ↓       ↓       ↓        ↓
  [检查]     [验证]    [问答]   [依赖]  [分解]  [状态] [多模式]
```

**特点**：
- 🏛️ 结构化流程
- 🤖 自动化验证
- 📊 数据驱动

---

## 🚀 未来支持的可能性

### 条件 1：Codex 官方支持 Slash Commands

如果 OpenAI Codex 推出类似 Claude Code 的 slash commands 功能，支持：

- ✅ 脚本执行（类似 `scripts` frontmatter）
- ✅ 文件系统操作工具
- ✅ 结构化数据返回（JSON）
- ✅ 项目级命令目录

**承诺**：Novel Writer 会在第一时间适配。

### 条件 2：Codex Prompts 增强为命令系统

如果 Codex 的 prompts 功能升级，支持：

```toml
# 类似 Gemini CLI 的 TOML 格式
description = "智能分析命令"

[scripts]
sh = ".specify/scripts/bash/check-analyze-stage.sh"

[tools]
file_operations = true
json_output = true
```

**承诺**：我们会立即提供 Codex 格式的命令文件。

### 条件 3：降级支持（不推荐）

**方案**：将脚本逻辑转为详细的 AI 指令

**示例**：
```markdown
<!-- analyze.md - Codex 降级版本 -->
请执行以下步骤：

1. 使用工具检查 stories/*/content/ 目录
2. 统计 .md 文件数量，忽略 README.md 和 index.md
3. 检查 specification.md、creative-plan.md、tasks.md 是否存在
4. 根据以下逻辑决定分析类型：
   - 章节数 = 0 → 框架分析
   - 章节数 < 3 → 框架分析（建议继续写作）
   - 章节数 ≥ 3 → 内容分析
...
```

**为什么不推荐**：
- ❌ 可靠性大幅降低（依赖 AI 理解）
- ❌ 一致性无法保证（每次执行可能不同）
- ❌ 无法处理复杂边界情况
- ❌ 失去自动化验证能力
- ❌ 用户体验严重下降

---

## ✅ 推荐的 AI 工具

Novel Writer **完整支持**以下 AI 工具，它们都支持完整的命令系统：

### 1. Claude Code（推荐）

**特点**：
- ✅ 原生支持 Markdown + YAML frontmatter
- ✅ 强大的上下文理解能力
- ✅ 优秀的中文处理
- ✅ 项目级命令目录 `.claude/commands/`

**安装**：
```bash
novel init my-novel --ai claude
```

**适用场景**：所有用户，特别是中文小说创作

---

### 2. Cursor

**特点**：
- ✅ AI 代码编辑器，写作和编辑一体化
- ✅ 完整支持 slash commands
- ✅ 实时预览和编辑
- ✅ 命令目录 `.cursor/commands/`

**安装**：
```bash
novel init my-novel --ai cursor
```

**适用场景**：喜欢集成开发环境的用户

---

### 3. Google Gemini CLI

**特点**：
- ✅ Google 最新 AI 模型
- ✅ TOML 格式命令系统
- ✅ Novel Writer 提供完整的 TOML 转换
- ✅ 命令目录 `.gemini/commands/`（带命名空间）

**安装**：
```bash
novel init my-novel --ai gemini
```

**适用场景**：Google 生态用户，喜欢 TOML 格式

---

### 4. 多平台支持（推荐）

**一次初始化，支持所有平台**：
```bash
novel init my-novel --all
```

生成所有 AI 工具的命令配置：
- `.claude/commands/` - Claude Code
- `.cursor/commands/` - Cursor
- `.gemini/commands/` - Gemini CLI
- `.windsurf/workflows/` - Windsurf

**适用场景**：团队协作，多工具切换

---

## ❓ FAQ

### Q1: Codex prompts 完全不能用吗？

**A**: 可以用于**简单提示**，比如：

```markdown
<!-- ~/.codex/prompts/brainstorm.md -->
帮我快速头脑风暴关于「$ARGUMENTS」的5个创意角度。
每个角度不超过2句话。
```

但**无法用于 Novel Writer 的核心工作流命令**（constitution、specify、write 等）。

---

### Q2: 为什么其他工具可以，Codex 不行？

**A**: 功能支持不同：

| 功能 | Codex Prompts | Claude/Cursor | Gemini CLI |
|------|--------------|---------------|------------|
| 纯文本提示 | ✅ | ✅ | ✅ |
| YAML Frontmatter | ❌ | ✅ | ❌（用 TOML） |
| 脚本执行 | ❌ | ✅ | ✅ |
| 工具调用 | 有限 | 强大 | 强大 |
| 项目级配置 | ❌ | ✅ | ✅ |

Codex 的 Custom Prompts 定位是**个人快捷提示**，而非**项目级命令系统**。

---

### Q3: 未来会支持吗？

**A**: 会，前提是：

1. **官方支持**：Codex 推出 slash commands 或增强 prompts 功能
2. **社区需求**：有足够多的用户需要 Codex 支持
3. **技术可行**：不损害现有用户的体验和功能

我们会持续关注 Codex 的更新，一旦条件满足，会**第一时间适配**。

---

### Q4: 我就是想用 Codex，怎么办？

**A**: 可以尝试以下方案：

**方案 1**：手动复制纯提示命令
```bash
# 复制 expert 命令到 Codex prompts
cp .claude/commands/expert.md ~/.codex/prompts/novel-expert.md
# 使用 /novel-expert 调用
```

**方案 2**：自己编写轻量级 prompts
```markdown
<!-- ~/.codex/prompts/novel-brainstorm.md -->
基于小说创作场景，帮我头脑风暴：$ARGUMENTS
参考文件：.specify/memory/writing-constitution.md
```

**方案 3**：混合使用
- **Codex**：快速对话、头脑风暴、探索性写作
- **Claude/Cursor**：核心工作流（constitution → write → analyze）

---

### Q5: Codex 有什么优势？

**A**: Codex 的优势在于：

- ⚡ 轻量快速启动
- 🌍 全局可用（不限项目）
- 👤 个人化提示管理
- 🆓 可能的成本优势

但这些优势**与 Novel Writer 的设计目标不匹配**：

- Novel Writer 专注于**项目级创作流程**
- 需要**跨会话的状态持久化**
- 强调**自动化验证和数据管理**

---

## 📚 相关资源

- [OpenAI Codex 文档](https://developers.openai.com/codex/)
- [Codex Custom Prompts 指南](https://github.com/openai/codex/blob/main/docs/prompts.md)
- [Novel Writer 安装指南](installation.md)
- [Gemini 命令开发指南](gemini-command-guide.md)
- [Novel Writer 快速开始](quickstart.md)

---

## 💬 反馈与讨论

如果你对 Codex 支持有强烈需求，或有其他建议，欢迎：

- 📧 提交 [GitHub Issue](https://github.com/wordflowlab/novel-writer/issues)
- 💬 加入社区讨论
- 🤝 贡献代码或文档

我们会根据社区反馈调整开发优先级。

---

**最后更新**：2025-10-04
**版本**：v0.12.1
