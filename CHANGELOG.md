# 更新日志

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
- 支持 Claude、Cursor、Gemini、Windsurf 多种 AI 助手
- 提供了完整的小说创作工作流命令
