# 更新日志

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
