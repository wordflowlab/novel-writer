# 更新日志

## [0.18.1] - 2025-10-15

### 🏗️ 架构优化

#### 类型知识插件化
- **迁移类型知识文件**：将 `spec/knowledge/genres/` 的5个类型知识文件迁移到 `plugins/genre-knowledge/knowledge/genres/`
  - `fantasy.md` (669行) - 奇幻/玄幻类型指导
  - `scifi.md` (530行) - 科幻类型指导
  - `romance.md` (378行) - 言情类型指导
  - `mystery.md` (353行) - 悬疑推理类型指导
  - `shuangwen.md` (236行) - 爽文类型指导

#### 真正的可选插件架构
- **核心命令优化**：
  - 移除核心命令对插件的硬编码依赖
  - 添加 `plugins/**` 通配符权限，支持所有插件
  - 保留 `<!-- PLUGIN_HOOK -->` 标记供用户手动启用插件
- **用户体验改进**：
  - 用户安装插件后只需复制粘贴增强提示词到 PLUGIN_HOOK 标记处
  - 无需修改 allowed-tools（已有 plugins/** 权限）
  - 插件功能完全可选，不影响核心功能

#### 设计理念
- ✅ **清晰职责**：`spec/knowledge/` 专注于用户创建的项目知识，插件专注于系统提供的可选功能
- ✅ **可选安装**：不需要类型知识的用户无需加载插件
- ✅ **单一数据源**：类型知识只存在于插件中，避免重复和混乱
- ✅ **架构简洁**：无技术债务，无向后兼容代码

### 📝 影响范围
- `spec/knowledge/genres/` - 已删除
- `plugins/genre-knowledge/` - 包含7个知识文件
- `templates/commands/clarify.md` - 移除插件硬编码，添加 plugins/** 权限
- `templates/commands/plan.md` - 移除插件硬编码，添加 plugins/** 权限
- `templates/commands/analyze.md` - 移除插件硬编码，添加 plugins/** 权限

---

## [0.15.0] - 2025-10-11

### ✨ 重大改进：多平台命令格式优化

#### 问题背景
之前的构建系统将 Claude 特有的 YAML frontmatter 字段（`allowed-tools`, `model`, `disable-model-invocation`）复制给了所有 13 个 AI 平台，但这些字段在其他平台中不被支持或不需要，导致兼容性问题。

#### 核心修复
- **平台特定格式生成**：根据每个 AI 平台的实际支持情况生成正确的命令文件格式
- **格式分类体系**：
  - **纯 Markdown（无 frontmatter）**：Cursor, GitHub Copilot, Codex CLI, Auggie CLI, CodeBuddy, Amazon Q Developer
  - **最小 frontmatter（只 description）**：OpenCode
  - **部分 frontmatter（description + argument-hint）**：Roo Code, Windsurf, Kilo Code
  - **完整 frontmatter（所有字段）**：Claude Code
  - **TOML 格式（description + prompt）**：Gemini CLI, Qwen Code

#### 技术实现
- **构建脚本增强**（`scripts/build/generate-commands.sh`）：
  - 添加 `frontmatter_type` 参数到 `generate_commands` 函数
  - 实现 4 种 frontmatter 生成策略（none/minimal/partial/full）
  - 为所有 13 个平台指定正确的格式类型
  - 提取 `argument_hint` 字段以支持部分 frontmatter

- **TOML 格式修复**：
  - Gemini 和 Qwen 的 TOML 文件只包含 `description` 和 `prompt` 字段
  - 参数占位符正确使用 `{{args}}` 而非 `$ARGUMENTS`
  - 移除不支持的元数据字段

#### 验证结果
✅ 所有 13 个 AI 平台的命令文件格式已验证通过
✅ 每个平台只包含其支持的字段，符合官方文档规范
✅ 提高了各平台的兼容性，减少了文件冗余
✅ 避免了潜在的解析错误

#### 影响范围
- 📦 **构建系统**：`npm run build:commands` 生成正确格式的命令文件
- 🎯 **13个平台**：Claude, Gemini, Cursor, Windsurf, Roo Code, GitHub Copilot, Qwen Code, OpenCode, Codex CLI, Kilo Code, Auggie CLI, CodeBuddy, Amazon Q Developer
- 📁 **182个文件**：每个平台 14 个命令文件，格式全部正确

### 📚 文档
感谢社区反馈，帮助我们发现并修复了多平台兼容性问题。

## [0.14.2] - 2025-10-10

### 🐛 问题修复

- **中文字数统计问题**：修复 `wc -w` 对中文字数统计极不准确的问题
  - 新增 `count_chinese_words()` 函数，准确性提升 12+ 倍
  - 排除 Markdown 标记、代码块、空格、标点符号
  - 只统计实际文字内容
  - 性能优秀（处理 3000 字约 10ms）

### ✨ 新增功能

- **字数统计函数**（`scripts/bash/common.sh`）
  - `count_chinese_words()` - 准确的中文字数统计
  - `show_word_count_info()` - 显示友好的字数验证信息

- **脚本增强**
  - `analyze-story.sh` - 显示每章详细字数统计
  - `check-writing-state.sh` - 自动验证章节字数是否达标
  - 从 `validation-rules.json` 读取字数要求配置

- **命令模板更新**
  - `/write` 命令添加字数验证说明
  - 警告不要使用 `wc -w` 统计中文
  - AI 写作完成后自动显示准确字数

### 📚 新增文档

- **使用指南**：`docs/word-count-guide.md` - 完整的字数统计使用说明
- **测试脚本**：`scripts/bash/test-word-count.sh` - 验证统计准确性
- **修复说明**：`WORD_COUNT_FIX.md` - 问题诊断和解决方案

### 🎯 解决的问题

- AI 写作时提示"字数不够"，但实际字数已超过要求
- 使用 `wc -w` 统计中文章节字数结果严重偏低（121/164 vs 2000+）
- 同一文件多次统计结果不一致

### ⚠️ 重要提醒

- ❌ 不要使用 `wc -w` 统计中文字数（极不准确）
- ❌ 不要使用 `wc -m` 统计字数（包含太多无关字符）
- ✅ 使用 `count_chinese_words` 函数获得准确结果

## [0.14.0] - 2025-10-09

### ✨ 新增功能

- **Roo Code 斜杠命令支持**：`novel init` 与 `novel upgrade` 现在支持生成 `.roo/commands` 目录，并自动输出 Roo Code 兼容的 Markdown 命令
- **插件系统集成**：插件命令注入流程同步扩展至 Roo Code，确保安装的插件可在 Roo Code 中即时使用

### 📚 文档更新

- README 与 CHANGELOG 新增 Roo Code 支持说明，同时更新可用 AI 列表提示

## [0.13.7] - 2025-10-06

### 🐛 问题修复

- **插件命令文件命名优化**：修复插件安装后命令文件名过于复杂的问题
  - 移除不必要的 `plugin-{pluginName}-` 前缀
  - 插件命令文件名简化：`plugin-book-analysis-book-analyze.md` → `book-analyze.md`
  - 保持与核心命令一致的命名风格
  - 适用于所有 AI 平台（Claude、Cursor、Windsurf、Gemini）

## [0.13.6] - 2025-10-06

### 🐛 问题修复

- **CLI 帮助文本更新**：修复 `novel init` 初始化后显示的帮助文本
  - 更新核心命令列表为正确的七步方法论命令（constitution, specify, clarify, plan, tasks, write, analyze）
  - 移除已废弃的旧命令（method, style, story, outline, chapters）
  - 更新推荐流程为：`constitution → specify → clarify → plan → tasks → write → analyze`

## [0.12.2] - 2025-10-04

### ✨ 新增功能：Claude Code 增强层

#### 核心改进
为 **Claude Code** 用户提供专属增强版本命令，同时**保持与其他平台（Gemini、Cursor、Windsurf）的完整兼容性**。

#### 1. 构建系统设计（v0.15.0+ 已升级为单一源+构建系统）
- **单一源**：`templates/commands/` - 命令源文件（原 `commands-claude/`）
- **构建系统**：`scripts/build/generate-commands.sh` - 自动生成所有平台命令
- **命名空间**：Claude 使用 `novel.*` 前缀，Gemini 使用 `novel/` 子目录，避免与 spec-kit 冲突
- **发布流程**：构建时自动生成 `dist/` 目录，用户初始化时直接复制

#### 2. Claude Code 专属特性

**增强的 Frontmatter 字段**：
- `argument-hint` - 命令参数自动补全提示
- `allowed-tools` - 细粒度工具权限控制（如 `Bash(find:*)`, `Read(//**)`)
- `model` - 为每个命令指定最适合的 AI 模型（默认 `claude-sonnet-4-5-20250929`）
- `disable-model-invocation` - 控制 SlashCommand 工具是否可自动调用

**动态上下文加载**：
- 支持内联 bash 执行：`!`command``
- 实时获取项目状态（章节数、字数、追踪文件等）
- 减少用户手动输入，提升命令智能化

#### 3. 增强的命令列表

**P0 命令（3个）**：
- `/analyze` - 添加阶段检测、章节列表、字数统计动态上下文
- `/write` - 添加待办任务、最新章节、进度状态动态加载
- `/clarify` - 添加故事文件路径、规格检测动态上下文

**P1 命令（3个）**：
- `/track` - 添加追踪文件状态、进度统计、章节列表、字数统计
- `/specify` - 添加宪法检测、规格文件检测、路径信息
- `/plan` - 添加规格状态、计划文件检测、待澄清项统计

**P2 命令（5个）**：
- `/tasks` - 添加计划/规格文件检测、线索管理规格摘要
- `/plot-check` - 添加追踪文件状态、进度检测、章节统计
- `/timeline` - 添加时间线状态、时间节点统计、章节映射
- `/relations` - 添加关系网络状态、角色/派系统计
- `/world-check` - 添加知识库检测、设定统计、专有名词统计

#### 4. CLI 逻辑优化

修改 `src/cli.ts` 支持优先级选择：
```typescript
// 为 Claude 生成命令时，优先使用增强版本
if (await fs.pathExists(claudeEnhancedPath)) {
  commandContent = await fs.readFile(claudeEnhancedPath, 'utf-8');
  console.log(chalk.gray(`    💎 Claude 增强: ${file}`));
}
```

#### 5. 兼容性保证
- ✅ 不修改其他平台的命令目录（`.claude`、`.cursor`、`.gemini` 等）
- ✅ 基础命令保持不变，确保 Gemini/Cursor/Windsurf 正常使用
- ✅ Claude 增强层是可选的，不影响现有用户
- ✅ 所有增强特性仅在 Claude Code 环境生效

### 📚 文档更新
- **README.md**：新增 v0.12.2 Claude Code 增强层特性说明
- **CHANGELOG.md**：详细记录增强功能和实现细节

### 🎯 设计理念
**增强而不破坏兼容性**：
- ❌ 不创建新命令或新平台特定命令
- ✅ 分层架构，优先级选择
- ✅ Claude 用户获得最佳体验
- ✅ 其他平台用户体验不受影响

---

## [0.12.1] - 2025-10-01

### ✨ 新增功能:智能双模式 analyze

#### 核心改进
`/analyze` 命令升级为**智能双模式**,根据创作阶段自动选择分析类型,**无需新增命令**。

#### 1. 智能阶段检测
- **自动判断**: 系统检测章节数量,自动决定执行框架分析还是内容分析
- **手动指定**: 支持 `--type=framework` 或 `--type=content` 强制指定模式
- **脚本支持**: 新增 `scripts/bash/check-analyze-stage.sh` 和 `scripts/powershell/check-analyze-stage.ps1`

#### 2. 模式A: 框架一致性分析 (write 之前)
- **覆盖率分析**: 检查规格需求是否都有对应的计划和任务
- **一致性检查**: 验证规格/计划/任务之间是否存在矛盾
- **逻辑预警**: 分析故事线设计中的潜在逻辑漏洞
- **准备评估**: 评估是否可以开始写作

#### 3. 模式B: 内容质量分析 (write 之后)
- **宪法合规**: 验证作品是否符合创作原则
- **规格符合**: 检查实现是否满足规格要求
- **内容质量**: 分析逻辑、人物、节奏等
- **改进建议**: 提供具体的 P0/P1/P2 修复建议

#### 4. 决策逻辑
```
章节数 = 0     → 框架分析
章节数 < 3     → 框架分析 (建议继续写作)
章节数 ≥ 3     → 内容分析
用户指定 --type → 强制使用指定模式
```

### 📚 文档更新
- **README.md**: 更新 `/analyze` 命令说明,展示智能双模式
- **docs/writing/analyze-placement-rationale.md**: 新增"附录:智能双模式设计"章节
- **命令模板**: 完全重写 analyze 命令,详细说明两种分析模式

### 🎯 设计理念
**克制而不简陋**:
- ❌ 不创建两个命令 (`/framework-analyze`, `/content-analyze`)
- ✅ 一个 `/analyze` 命令,智能判断场景
- ✅ 90% 自动处理,10% 可手动控制
- ✅ 满足多种需求,保持命令简洁

### 💡 社区反馈驱动
感谢 @曾喜胜 Anson 提出的需求,既要"write 之前的框架分析",也要"write 之后的内容审查"。
我们通过智能化设计,在不增加命令的前提下,满足了两种需求。

---

## [0.12.0] - 2025-09-30

### ✨ 新增功能:多线索管理系统

#### 核心改进
**无需新增命令**,通过增强现有命令模板,实现完整的多线索管理能力。

#### 1. specification.md 增强 (/specify 命令)
新增**第五章:线索管理规格**,包含5个管理表格:
- **5.1 线索定义表**: 定义所有线索的ID、类型、优先级、冲突
- **5.2 线索节奏规划**: 规划每条线索在不同卷的活跃程度(⭐⭐⭐/⭐⭐/⭐)
- **5.3 线索交汇点规划**: 预先规划线索交汇时机,避免AI随意发挥
- **5.4 伏笔管理表**: 管理伏笔的埋设与揭晓,确保不遗漏
- **5.5 线索修改决策矩阵**: 修改线索时的影响评估清单

#### 2. creative-plan.md 增强 (/plan 命令)
章节段表格增加"活跃线索"和"交汇点"列:
- 标注每个章节段推进哪些线索
- ⭐⭐⭐ 主推进 / ⭐⭐ 辅助 / ⭐ 背景
- 明确交汇点所在章节

#### 3. tasks.md 增强 (/tasks 命令)
每个写作任务增加线索相关字段:
- **涉及线索**: 本章推进哪些线索及优先级
- **交汇点**: 本章是否为交汇点
- **伏笔埋设/揭晓**: 本章涉及的伏笔操作

#### 4. plot-tracker.json 增强 (/track-init 命令)
`/track --init` 自动从specification.md第五章读取:
- 所有线索定义 (从5.1节)
- 所有交汇点 (从5.3节)
- 所有伏笔 (从5.4节)
- 生成完整的追踪数据结构

#### 5. 实战指南更新 (docs/writing/practical-guide.md)
新增**第六章:多线索管理指南**,包含:
- 真实问题场景(来自网友反馈)
- 4步解决方案
- 基于《重返1984》的完整使用示例
- 三大痛点的解决方式对比表

### 🎯 解决的核心问题
来自网友的真实困惑:
> "主线和支线的穿插,很难给AI讲清楚如何保持并行,而且在适当的时候进行交叉和揭晓之前的线索。尤其是再剧情设定不定时修改的情况下,简直就是灾难。"

#### 三大痛点及解决方式
| 痛点 | 解决方式 | 具体文件 |
|------|---------|---------|
| **并行推进** | tasks.md每章标记"涉及线索" | W040标注PL-01⭐⭐⭐、PL-02⭐⭐ |
| **交汇时机** | specification.md 5.3节预先规划 | X-001定在40章,避免AI随意 |
| **修改一致性** | 5.5修改决策矩阵 + `/track --check` | 修改PL-02时自动提示影响范围 |

### 📐 设计原则
- ✅ **符合"如无必要请勿增加"原则**: 完全使用现有7个命令
- ✅ **符合SDD方法论**: 线索管理分布在specify→plan→tasks→track
- ✅ **有写作理论支撑**: Story Grid的Grid Spreadsheet、Save the Cat的B Story理念
- ✅ **解决真实痛点**: 来自用户实际需求,非臆想功能

### 📝 文档改进
- 详细的使用示例(基于《重返1984》5条线索)
- 完整的输入提示词模板
- 影响评估和一致性验证流程

## [0.11.0] - 2025-09-30

### ✨ 新增功能
- **SDD方法论实战指南**: 新增 `docs/writing/practical-guide.md` (约10000字)
  - 基于《重返1984》小说的完整SDD实战案例
  - 详细讲解SDD的分层递归应用(整本书/一卷/章节段/单章)
  - 提供4个完整场景的实际输入提示词示例
  - 增加好坏提示词对比
  - 增加完整对话流程展示
  - 回答"AI写着偏离了怎么更新outline"等实际问题

- **可视化图表**: 新增3个SVG图表辅助理解
  - `sdd-levels.svg` - SDD分层递归示意图
  - `sdd-flow.svg` - SDD完整循环流程图
  - `prompt-structure.svg` - 好的提示词结构图

### 📝 文档改进
- 强调SDD的核心: 规格驱动 + 分层递归 + 允许偏离 + 频繁验证
- 每个场景包含:
  - ❌ 不好的提示词示例
  - ✅ 好的提示词示例
  - 💬 完整对话流程 (用户→AI→确认→完成)
- 提供提示词结构模板(情况说明/修改意图/需要更新/期望输出)

### 🎯 解决的问题
- 如何在写作中途调整剧情方向
- 如何处理AI写出的优秀偏离内容
- 不同粒度修改时应该用什么命令组合
- 如何写出让AI理解的提示词

## [0.10.5] - 2025-09-30

### 🐛 Bug 修复
- **common.sh 缺少函数**：添加 `get_active_story()` 函数
  - 修复脚本执行时 "get_active_story: 未找到命令" 错误
  - 同步到 `.specify/scripts/bash/` 和 `scripts/bash/`

### 📝 影响范围
修复后以下脚本能正常执行：
- `check-writing-state.sh`
- `plan-story.sh`
- `tasks-story.sh`
- `analyze-story.sh`

## [0.10.4] - 2025-09-30

### 🐛 Bug 修复
- **七步方法论脚本缺失**：补全 Bash 脚本支持
  - 创建 `plan-story.sh` - 创作计划脚本
  - 创建 `tasks-story.sh` - 任务分解脚本
  - 复制 `analyze-story.sh` - 综合验证脚本
  - 复制 `constitution.sh` - 创作宪法脚本
  - 复制 `specify-story.sh` - 故事规格脚本

### 📝 文件更新
- 更新 `/tasks` 命令模板脚本引用从 `generate-tasks.sh` 改为 `tasks-story.sh`
- 同步所有脚本到 `.specify/scripts/bash/` 和 `scripts/bash/`
- 同步命令模板到 `.claude/commands/`

### 🔧 影响范围
修复后所有七步方法论命令（`/constitution`, `/specify`, `/clarify`, `/plan`, `/tasks`, `/write`, `/analyze`）都能在 Bash 环境下正常执行。

## [0.10.3] - 2025-09-30

### 🔧 破坏性变更
- **移除旧格式兼容**：完全移除对旧 `story.md` 格式的支持
  - 所有脚本现在只支持新格式 `specification.md`
  - `/clarify` 命令只查找 `specification.md`
  - `/specify` 命令移除了迁移逻辑
  - `/track-init` 和相关追踪脚本更新为新格式
  - 更新提示信息从 `/story` 改为 `/specify`

### 📝 文件更新
- **Bash 脚本**：
  - 更新 `clarify-story.sh` 只支持 `specification.md`
  - 更新 `specify-story.sh` 移除 `story.md` 兼容逻辑
  - 更新 `init-tracking.sh` 查找 `specification.md`
  - 更新 `generate-tasks.sh` 检查 `specification.md`

- **PowerShell 脚本**：
  - 更新 `clarify-story.ps1` 只支持 `specification.md`
  - 更新 `specify-story.ps1` 移除 `story.md` 兼容逻辑

- **配置文件**：
  - 更新 `.gitignore` 添加 `*.backup` 规则

### ⚠️ 迁移提示
如果您的项目还在使用 `story.md`，请手动将其重命名为 `specification.md`：
```bash
mv stories/your-story/story.md stories/your-story/specification.md
```

## [0.10.2] - 2025-09-30

### 🐛 Bug 修复
- **命令模板缺失**：补全七步方法论命令模板
  - 添加 `/constitution` - 创作宪法命令
  - 添加 `/specify` - 故事规格命令
  - 添加 `/plan` - 创作计划命令
  - 添加 `/tasks` - 任务分解命令
  - 添加 `/analyze` - 综合验证命令
- **影响范围**：修复后 `novel init` 创建的新项目将包含所有命令模板

## [0.10.1] - 2025-09-30

### 🔧 系统完善
- **脚本体系重构**：统一管理 Bash 和 PowerShell 脚本至 `.specify/scripts/`
- **命令同步更新**：完善 Claude Code 和 Gemini 命令模板
- **追踪系统增强**：
  - 新增 `/track-init` 命令用于初始化追踪系统
  - 完善进度追踪和验证规则
  - 添加时间线、情节、世界观一致性检查脚本
- **命令优化**：
  - 更新 `/clarify`、`/expert`、`/write`、`/relations` 等命令
  - 删除冗余命令：`/story`、`/style`、`/outline`、`/chapters`
- **文档改进**：更新工作流程和快速开始指南

### 📦 项目结构
- 移动脚本文件到 `.specify` 目录以更好地组织
- 添加子模块支持（BMAD-METHOD、spec-kit）
- 完善模板文件和配置文件

## [0.10.0] - 2025-09-29

### 🎉 重大更新
- **七步方法论体系**：引入完整的规格驱动开发（SDD）创作流程
  - `/constitution` - 创作宪法，定义最高层级的创作原则
  - `/specify` - 故事规格，像 PRD 一样定义故事需求
  - `/clarify` - 澄清决策，通过交互式问答明确关键点
  - `/plan` - 创作计划，制定技术实现方案
  - `/tasks` - 任务分解，生成可执行的任务清单
  - `/write` - 章节写作（重构以适配新流程）
  - `/analyze` - 综合验证，全方位质量检查

### 🔧 系统重构
- **删除冗余命令**：移除 story、style、outline、chapters、method 等旧命令
- **跨平台同步**：PowerShell 脚本和 Gemini TOML 命令完全同步
- **文档体系升级**：
  - 创建 `METHODOLOGY.md` - 完整的方法论说明
  - 创建 `MIGRATION.md` - 版本迁移指南
  - 更新所有平台的命令支持

### 📝 理念升级
- 从"工具集合"升级为"方法论框架"
- 从"零散命令"转变为"系统化流程"
- 强调"规格驱动"而非"灵感驱动"
- 实现"需求定义"到"内容生成"的完整链路

### ⚠️ 破坏性变更
- 删除了以下旧命令（已被新命令替代）：
  - `/story` → `/specify`
  - `/style` → `/constitution`
  - `/outline` → `/plan`
  - `/chapters` → `/tasks`
  - `/method` → 成为可选辅助
- 文件结构调整：
  - `stories/*/chapters/` → `stories/*/content/`
  - 新增多个方法论相关文件

## [0.9.0] - 2025-09-29

### 🎯 方法论升级
- 引入 spec-kit 的规格驱动开发理念
- **`/clarify` 命令** - 交互式澄清故事大纲中的关键决策点
- 结构化创作流程：story → clarify → outline
- 智能问答：AI 识别模糊点，通过5个精准问题明确创作方向

## [0.8.4] - 2025-09-26

### 🎉 新功能
- Authentic Voice 真实人声插件（提升原创度与自然度）
  - `/authentic-voice` 真实人声创作模式（取材卡 + 个体词库）
  - `/authenticity-audit` 人味自查与行级改写建议
  - 专家 `authentic-editor`：更细致的人声编辑
- 离线文本自查脚本：`scripts/bash/text-audit.sh`
  - 统计连接词/空话密度、句长均值/方差、连续长/短句、抽象词密度示例
  - 支持项目级配置：`spec/knowledge/audit-config.json`

### 📚 模板与文档
- 新增写作准则模板：`templates/writing-constitution-template.md`
- 新增人味自查配置模板：`templates/knowledge/audit-config.json`
- README 增加“真实人声一键示例”和插件推荐使用说明

### 🔧 流程改进
- `/style` 初始化自动引用 `.specify/memory/personal-voice.md`：
  - 追加“个人语料摘要（自动引用）”
  - 同步“个人表达基线（自动同步）”固定专章（幂等更新）
- CLI 帮助中展示 `authentic-voice` 可用插件项

## [0.8.3] - 2025-09-25

### 🎉 新功能
- **完整插件 Gemini 支持**：所有插件都支持 Gemini CLI
  - translate 插件：3 个 TOML 命令
  - book-analysis 插件：6 个 TOML 命令
  - 作者风格插件：13 个 TOML 命令（王钰、十年雪落、路遥）
  - stardust-dreams 插件：4 个 TOML 命令

### 🔧 技术改进
- 标准化插件命令格式
- 简化复杂命令为 AI 友好格式
- 优化 TOML 命令结构

### 📝 插件更新
- 所有 6 个官方插件现在都支持双格式（Markdown + TOML）
- 共新增 26 个 TOML 格式命令文件
- 插件系统完全兼容 Gemini CLI

## [0.8.2] - 2025-09-25

### 🎉 新功能
- **Google Gemini CLI 支持**：完整的 Gemini CLI 斜杠命令集成
  - 新增 13 个 TOML 格式的命令定义
  - 支持命名空间命令（如 `/track:init`、`/plot:check`）
  - 插件系统同时支持 Markdown 和 TOML 双格式
  - 智能格式转换和降级机制

### 📚 新增文档
- **Gemini 开发指南**：`docs/gemini-command-guide.md` - 双格式命令开发说明
- **Gemini 用户文档**：`templates/GEMINI.md` - Gemini CLI 使用指南
- **Gemini 配置文件**：`templates/gemini-settings.json` - CLI 设置模板

### 🔧 技术改进
- 重构插件管理器支持多 AI 平台
- CLI 初始化命令智能检测并生成对应格式
- 增强命令注入机制，支持自动格式转换
- 优化目录结构管理

### 📝 兼容性
- 完全向后兼容现有 Claude、Cursor、Windsurf 用户
- 支持 `--ai gemini` 参数专门生成 Gemini 格式
- 插件可选择性提供 TOML 格式支持

## [0.7.0] - 2025-01-24

### 🎉 新功能
- **外部AI建议整合功能**：支持整合来自Gemini、ChatGPT等AI工具的分析建议
  - 扩展 `/style` 命令，新增 `refine` 模式
  - 支持JSON和Markdown两种建议格式
  - 自动分类处理建议（风格/角色/情节/世界观/对话）
  - 建议历史追踪和版本管理
  - 智能合并多源建议

### 📚 新增文档
- **PRD文档**：`docs/PRD-external-suggestion-integration.md` - 功能设计规范
- **AI提示词模板**：`docs/ai-suggestion-prompt-template.md` - 标准化建议格式
- **Gemini专用模板**：`docs/ai-suggestion-prompt-for-gemini.md` - 优化的提示词
- **快速指南**：`docs/quick-guide-external-ai-integration.md` - 三步完成整合
- **实例集**：`docs/suggestion-integration-examples.md` - 详细使用示例

### 🔧 技术改进
- 新增 `style-manager.sh` 脚本处理建议整合
- 优化格式识别逻辑，支持管道输入
- 改进Markdown解析处理
- 增强错误处理机制

### 📝 文件更新
- 更新 `/style` 命令模板支持新功能
- 新增 `improvement-log.md` 追踪建议历史
- 扩展 `character-voices.md` 添加词汇替换表

## [0.6.2] - 2025-09-24

### 改进
- **ESM 模块支持**：项目全面迁移到 ESM（ECMAScript Modules）
  - 添加 `"type": "module"` 配置
  - 更新所有导入语句为 ESM 格式
  - 使用 `import.meta.url` 替代 `__dirname`
  - 完全支持 Node.js 18+ 所有版本（包括 21、22、23）
  - 真正实现向上兼容，拥抱现代化 JavaScript 标准

## [0.6.1] - 2025-09-24

### 修复
- **依赖问题**：修复 `js-yaml` 模块缺失导致的运行错误
  - 将 `js-yaml` 添加到 dependencies 中
  - 解决了 `novel -h` 命令报错的问题

## [0.6.0] - 2025-09-24

### 新增
- **角色一致性验证系统**：解决AI生成内容中的角色名称错误问题
  - 新增 `validation-rules.json` 验证规则文件
  - `/write` 命令增强：写作前提醒、写作后验证
  - `/track --check` 深度验证模式：批量检查角色一致性
  - `/track --fix` 自动修复模式：自动修复简单错误
- **程序驱动验证**：内部使用任务机制执行验证，提高效率
- **验证脚本**：新增 `track-progress.sh` 支持验证功能

### 改进
- **写作流程优化**：在写作时主动预防角色名称错误
- **批量验证**：支持一次性验证多个章节，节省Token
- **自动修复**：能够自动修复角色名称和称呼错误

## [0.5.6] - 2025-09-23

### 新增
- **写作风格插件**：新增三个写作风格插件
  - `luyao-style` - 路遥风格写作插件
  - `shizhangyu-style` - 施章渝风格写作插件
  - `wangyu-style` - 王毓风格写作插件

## [0.4.3] - 2025-09-21

### 改进
- **默认版本号更新**：将 version.ts 中的默认版本号从 0.4.1 更新为 0.4.2
- **版本一致性**：确保所有版本引用保持同步

## [0.4.2] - 2025-09-21

### 改进
- **统一版本管理**：实现自动从 package.json 读取版本号的模块
- **知识库模板系统**：将硬编码的知识库文件改为模板文件系统
- **代码优化**：简化 cli.ts 代码结构，提高可维护性

### 修复
- **版本号统一**：通过 version.ts 模块确保版本号一致性

## [0.4.0] - 2025-09-21

### 新增
- **情节追踪系统** (`/plot-check`)：追踪情节节点、伏笔和冲突发展
- **时间线管理** (`/timeline`)：维护故事时间轴，确保时间逻辑一致
- **关系矩阵** (`/relations`)：管理角色关系和派系动态
- **世界观检查** (`/world-check`)：验证设定一致性，避免矛盾
- **综合追踪** (`/track`)：全方位查看创作状态
- **spec目录结构**：新增 `spec/tracking` 和 `spec/knowledge` 目录
- **知识库模板**：
  - `world-setting.md` - 世界观设定模板
  - `character-profiles.md` - 角色档案模板
  - `character-voices.md` - 角色语言档案模板
  - `locations.md` - 场景地点模板

### 改进
- **追踪文件模板**：提供完整的 JSON 追踪文件模板
- **一致性检查脚本**：实现综合的一致性验证系统
- **工作流程增强**：添加质量保障流程

## [0.3.7] - 2025-09-20

### 新增

- **时间获取指导**：在命令模板中添加提示，指导 AI 使用 `date` 命令获取系统日期
- **自动日期生成**：脚本会预先生成正确的系统日期供 AI 参考

### 改进

- **灵活的卷册管理**：章节现在会自动从 outline.md 解析卷册结构，不再硬编码4卷
- **动态章节数量**：支持从 outline.md 读取总章节数，不再限制为240章
- **进度文件时间戳**：progress.json 现在包含创建和更新时间戳

### 修复

- **日期生成错误**：修复了 AI 生成错误日期的问题（如2025-01-20而非2025-09-20）

## [0.3.6] - 2025-01-20

### 修复

- **目录命名问题**：修复了故事目录生成时名称为 `001-` 的问题
  - 采用 spec-kit 的方式处理目录名，只提取英文单词
  - 纯中文描述时使用默认名称 `story`
- **章节组织结构**：修复了章节按卷册结构生成的功能
  - 章节现在会根据编号自动放入对应的卷册目录（volume-1 至 volume-4）
  - 第1-60章在 volume-1，第61-120章在 volume-2，以此类推

## [0.3.5] - 2025-01-20

### 修复

- 修复了 `novel init` 命令生成的 `.claude/commands/` 配置文件格式问题
- 保留了命令文件中完整的 frontmatter 和 scripts 部分，确保 Claude 能正确识别和执行命令
- 简化了 `generateMarkdownCommand` 函数，直接返回完整模板内容

## [0.3.4] - 之前版本

### 新增

- 初始版本发布
- 支持 Claude、Cursor、Gemini、Windsurf、Roo Code 多种 AI 助手
- 提供了完整的小说创作工作流命令
