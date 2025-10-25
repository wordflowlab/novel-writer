# AI 平台命令使用指南

本文档详细说明 Novel Writer 在不同 AI 平台下的斜杠命令使用方法。

## 📋 快速对照表

| AI 平台 | 命令格式 | 示例 | 命名空间 |
|---------|---------|------|----------|
| **Gemini CLI** | `/novel:命令名` | `/novel:write` | `novel:` |
| **Claude Code** | `/novel.命令名` | `/novel.write` | `novel.` |
| **Cursor** | `/命令名` | `/write` | 无 |
| **Windsurf** | `/命令名` | `/write` | 无 |
| **Roo Code** | `/命令名` | `/write` | 无 |
| **GitHub Copilot** | `/命令名` | `/write` | 无 |
| **Qwen Code** | `/命令名` | `/write` | 无 |
| **OpenCode** | `/命令名` | `/write` | 无 |
| **Codex CLI** | `/novel-命令名` | `/novel-write` | `novel-` |
| **Kilo Code** | `/命令名` | `/write` | 无 |
| **Auggie CLI** | `/命令名` | `/write` | 无 |
| **CodeBuddy** | `/命令名` | `/write` | 无 |
| **Amazon Q** | `/命令名` | `/write` | 无 |

## 🎯 为什么使用命名空间？

Novel Writer 在部分 AI 平台使用命名空间（namespace）前缀，主要原因：

1. **避免命令冲突**：防止与其他工具（如 spec-kit、OpenSpec 等）的命令重名
2. **清晰的命令归属**：让用户明确知道这是 Novel Writer 提供的命令
3. **平台限制**：某些平台不支持子目录组织，必须使用前缀区分

### 命名空间规则

- **Gemini CLI**：使用子目录命名空间 `novel/`，命令格式为 `/novel:命令名`
  - 原因：Gemini 的子目录会自动转换为冒号命名空间
  - 路径：`.gemini/commands/novel/write.toml` → `/novel:write`

- **Claude Code**：使用文件名前缀 `novel.`，命令格式为 `/novel.命令名`
  - 原因：Claude 不支持子目录命名空间
  - 路径：`.claude/commands/novel.write.md` → `/novel.write`

- **Codex CLI**：使用文件名前缀 `novel-`，命令格式为 `/novel-命令名`
  - 原因：Codex prompts 不支持子目录，使用连字符前缀便于识别
  - 路径：`.codex/prompts/novel-write.md` → `/novel-write`

- **其他平台**：无命名空间，直接使用命令名
  - 原因：这些平台通常是独立项目环境，冲突风险较低

---

## 🚀 Gemini CLI 命令参考

### 命令格式
```bash
/novel:命令名 [参数]
```

### 七步方法论命令

#### 1. 创作宪法
```bash
/novel:constitution
```
定义核心创作原则，建立创作的最高准则。

#### 2. 故事规格
```bash
/novel:specify [故事描述]
```
明确要创造什么，像产品需求文档一样定义故事。

示例：
```bash
/novel:specify 一个关于修仙的玄幻小说
```

#### 3. 澄清决策
```bash
/novel:clarify
```
交互式澄清关键决策点，明确模糊之处。

#### 4. 创作计划
```bash
/novel:plan
```
制定技术方案，决定如何实现故事规格。

#### 5. 任务分解
```bash
/novel:tasks
```
生成可执行的任务清单，系统化推进创作。

#### 6. 章节写作
```bash
/novel:write [章节描述]
```
基于任务清单执行章节写作，自动加载上下文。

示例：
```bash
/novel:write 第一章
/novel:write 主角初入修仙界
```

#### 7. 综合验证
```bash
/novel:analyze
```
全方位质量检查，确保创作质量一致。

### 追踪管理命令

#### 初始化追踪系统
```bash
/novel:track-init
```
初始化角色、情节、时间线等追踪系统。

#### 综合追踪
```bash
/novel:track
```
综合进度追踪与智能分析，查看创作状态。

#### 情节检查
```bash
/novel:plot-check
```
检查情节逻辑一致性，发现潜在问题。

#### 时间线管理
```bash
/novel:timeline
```
管理和验证故事时间线。

#### 人物关系管理
```bash
/novel:relations
```
追踪和更新角色关系网络。

#### 世界观检查
```bash
/novel:world-check
```
验证世界观设定的一致性。

### 专家模式命令

#### 激活专家
```bash
/novel:expert [专家类型]
```
获取特定领域的深度指导。

示例：
```bash
/novel:expert plot      # 剧情结构专家
/novel:expert character # 人物塑造专家
/novel:expert style     # 风格润色专家
```

### 其他辅助命令

#### 检查清单
```bash
/novel:checklist
```
生成写作前的检查清单。

---

## 🔧 Claude Code 命令参考

### 命令格式
```bash
/novel.命令名 [参数]
```

### 核心命令列表

所有命令功能与 Gemini CLI 相同，只需将 `/novel:` 替换为 `/novel.`：

```bash
# 七步方法论
/novel.constitution
/novel.specify [故事描述]
/novel.clarify
/novel.plan
/novel.tasks
/novel.write [章节描述]
/novel.analyze

# 追踪管理
/novel.track-init
/novel.track
/novel.plot-check
/novel.timeline
/novel.relations
/novel.world-check

# 专家模式
/novel.expert [专家类型]

# 其他
/novel.checklist
```

---

## 📟 Codex CLI 命令参考

### 命令格式

```bash
/novel-命令名 [参数]
```

### 核心命令列表

所有命令功能与 Gemini CLI 相同，只需将 `/novel:` 替换为 `/novel-`：

```bash
# 七步方法论
/novel-constitution
/novel-specify [故事描述]
/novel-clarify
/novel-plan
/novel-tasks
/novel-write [章节描述]
/novel-analyze

# 追踪管理
/novel-track-init
/novel-track
/novel-plot-check
/novel-timeline
/novel-relations
/novel-world-check

# 专家模式
/novel-expert [专家类型]

# 其他
/novel-checklist
```

### 特别说明

**Codex CLI 支持** (v0.19.0+):
- ✅ 使用纯 Markdown 格式(无 YAML frontmatter)
- ✅ 命令文件位于 `.codex/prompts/` 目录
- ✅ 使用 `novel-` 前缀避免与其他工具冲突
- ✅ 完整支持所有 Novel Writer 命令功能

**安装方式**:
```bash
novel init my-novel --ai codex
```

**注意事项**:
- Codex CLI 的 custom prompts 功能要求命令文件必须是纯 Markdown 格式
- 使用连字符 `-` 而非点 `.` 或冒号 `:` 作为命名空间分隔符
- 所有脚本执行由 AI 自动处理,无需手动配置

---

## 💡 其他 AI 平台命令参考

### 命令格式
```bash
/命令名 [参数]
```

### 核心命令列表

Cursor、Windsurf、Roo Code、GitHub Copilot、Qwen Code、OpenCode、Codex CLI、Kilo Code、Auggie CLI、CodeBuddy、Amazon Q 等平台使用相同的命令格式，无需前缀：

```bash
# 七步方法论
/constitution
/specify [故事描述]
/clarify
/plan
/tasks
/write [章节描述]
/analyze

# 追踪管理
/track-init
/track
/plot-check
/timeline
/relations
/world-check

# 专家模式
/expert [专家类型]

# 其他
/checklist
```

---

## 📖 使用示例

### Gemini CLI 完整工作流

```bash
# 1. 建立创作原则
> /novel:constitution

# 2. 定义故事规格
> /novel:specify 一个关于时间旅行的科幻悬疑故事

# 3. 澄清关键决策
> /novel:clarify

# 4. 制定创作计划
> /novel:plan

# 5. 生成任务清单
> /novel:tasks

# 6. 开始写作
> /novel:write 第一章：时间回溯

# 7. 定期验证质量
> /novel:analyze

# 追踪管理
> /novel:track
> /novel:timeline
```

### Claude Code 完整工作流

```bash
# 使用相同流程，只需替换命令前缀
> /novel.constitution
> /novel.specify 一个关于时间旅行的科幻悬疑故事
> /novel.clarify
> /novel.plan
> /novel.tasks
> /novel.write 第一章：时间回溯
> /novel.analyze
```

### Codex CLI 完整工作流

```bash
# 使用连字符前缀
> /novel-constitution
> /novel-specify 一个关于时间旅行的科幻悬疑故事
> /novel-clarify
> /novel-plan
> /novel-tasks
> /novel-write 第一章：时间回溯
> /novel-analyze
```

### Cursor 完整工作流

```bash
# 无需前缀，直接使用命令名
> /constitution
> /specify 一个关于时间旅行的科幻悬疑故事
> /clarify
> /plan
> /tasks
> /write 第一章：时间回溯
> /analyze
```

---

## 🔍 常见问题

### Q: 为什么我的命令不生效？

**A**: 请检查以下几点：

1. **确认命令格式**：
   - Gemini CLI 使用 `/novel:命令名`
   - Claude Code 使用 `/novel.命令名`
   - 其他平台使用 `/命令名`

2. **检查命令文件是否存在**：
   ```bash
   # Gemini
   ls .gemini/commands/novel/

   # Claude
   ls .claude/commands/ | grep novel.

   # Cursor
   ls .cursor/commands/
   ```

3. **确认项目已初始化**：
   ```bash
   ls .specify/config.json
   ```

### Q: 可以自定义命令前缀吗？

**A**: 目前命名空间是固定的，主要考虑：
- 保持跨平台一致性
- 避免与其他工具冲突
- 简化用户记忆负担

### Q: 为什么不同平台的命令格式不一样？

**A**: 这是由各 AI 平台的技术限制决定的：
- **Gemini**：子目录自动转换为冒号命名空间
- **Claude**：不支持子目录，必须用文件名前缀
- **其他平台**：大多支持独立命名空间或冲突风险较低

### Q: 如何查看所有可用命令？

**A**: 使用以下方法：

**Gemini CLI**：
```bash
# 列出所有 novel 命名空间下的命令
ls .gemini/commands/novel/
```

**Claude Code**：
```bash
# 列出所有 novel 前缀的命令
ls .claude/commands/ | grep ^novel\\.
```

**其他平台**：
```bash
# 列出所有命令
ls .cursor/commands/
ls .windsurf/workflows/
ls .roo/commands/
```

---

## 📚 相关文档

- [快速开始指南](../README.md)
- [七步方法论详解](./workflow.md)
- [Gemini CLI 开发指南](./gemini-command-guide.md)
- [升级指南](./upgrade-guide.md)

---

## 🆘 获取帮助

如果遇到问题：

1. 查看 [项目 Issues](https://github.com/wordflowlab/novel-writer/issues)
2. 参考 [完整文档](https://github.com/wordflowlab/novel-writer/tree/main/docs)
3. 提交新的 Issue 描述问题

---

*最后更新：2025-10-25*
