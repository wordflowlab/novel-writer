# 更新日志

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
