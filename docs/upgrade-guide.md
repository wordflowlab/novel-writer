# Novel Writer 升级指南

> 如何将现有项目升级到最新版本

## 适用场景

- ✅ 已有项目使用旧版本 novel-writer-cn 创建
- ✅ 想使用新版本的功能（Claude Code 增强、多线索管理等）
- ✅ 不想丢失已写的内容和自定义配置

## 版本兼容性

| 旧版本 | 新版本 | 兼容性 | 建议操作 |
|-------|--------|--------|----------|
| 0.11.x | 0.12.x | ✅ 兼容 | 升级命令文件即可 |
| 0.10.x | 0.12.x | ⚠️ 部分兼容 | 需要迁移数据结构 |
| < 0.10.0 | 0.12.x | ❌ 不兼容 | 建议重新创建项目 |

## 升级方法

### 方法 1：自动升级（推荐，最简单）

**适用情况**：
- 想要自动处理升级过程
- 自动备份，安全可靠
- 保留所有用户数据和自定义配置

**步骤**：

```bash
# 1. 升级全局安装的 novel-writer-cn
npm install -g novel-writer-cn@latest

# 2. 进入项目目录并运行升级命令
cd my-novel
novel upgrade

# 或指定特定 AI 平台
novel upgrade --ai claude
```

**说明**：
- ✅ 自动备份：升级前自动创建备份（backup/ 目录）
- ✅ 保留内容：所有创作内容（stories/, spec/, memory/）完全保留
- ✅ 更新命令：从构建产物更新命令文件（带命名空间）
- ✅ 更新脚本：同步最新的支持脚本
- ⚠️ 可回滚：如有问题可从 backup/ 目录恢复

**命名空间说明**（v0.15.0+）：
- Claude 命令文件使用 `novel.*` 前缀（如 `novel.specify.md`），避免与其他工具冲突
- Gemini 命令文件使用 `novel/` 子目录
- 使用时仍然是 `/specify`、`/write` 等，命名空间对用户透明

#### v0.16.5 新增升级选项

**交互式选择**：
```bash
# 通过交互式界面选择要更新的内容
novel upgrade -i
```
将显示 checkbox 选择界面，默认选中"命令文件"和"脚本文件"。

**选择性更新**：
```bash
# 仅更新命令文件（不更新脚本）
novel upgrade --commands

# 仅更新脚本文件
novel upgrade --scripts

# 更新模板文件（框架更新时使用）
novel upgrade --templates

# 更新记忆文件（个人语料等）
novel upgrade --memory

# 组合使用：更新命令和脚本
novel upgrade --commands --scripts
```

**平台指定**：
```bash
# 只升级 Claude 平台
novel upgrade --ai claude

# 升级 Gemini 平台的命令文件
novel upgrade --ai gemini --commands

# 升级所有已安装平台（默认行为）
novel upgrade
# 或明确指定
novel upgrade --all
```

**快速选项**：
```bash
# 跳过确认提示（自动执行）
novel upgrade -y

# 跳过备份（快速升级，谨慎使用）
novel upgrade --no-backup

# 预览升级内容（不实际修改）
novel upgrade --dry-run

# 组合使用：快速无备份升级
novel upgrade -y --no-backup
```

**实用场景示例**：

1. **首次升级到 v0.16.5**（推荐）：
   ```bash
   novel upgrade -i
   ```
   交互式选择要更新的内容，安全可控。

2. **日常命令更新**：
   ```bash
   novel upgrade --commands
   ```
   只更新命令文件，保持脚本稳定。

3. **完整升级测试**：
   ```bash
   novel upgrade --dry-run
   ```
   先预览升级内容，确认后再执行。

4. **紧急快速修复**：
   ```bash
   novel upgrade --ai claude --commands -y
   ```
   快速更新 Claude 命令，跳过确认。

5. **多平台项目维护**：
   ```bash
   # 更新所有平台的命令和脚本
   novel upgrade --commands --scripts
   ```

**升级报告示例**：
```
📦 Novel Writer 项目升级

当前版本: 0.16.4
目标版本: 0.16.5

✓ 检测到 AI 配置: Claude Code, Cursor, Gemini CLI

升级目标: Claude Code, Cursor, Gemini CLI

更新内容: 命令文件, 脚本文件

📦 创建备份...
  ✓ 备份 .claude/
  ✓ 备份 .cursor/
  ✓ 备份 .gemini/
  ✓ 备份 .specify/scripts/
✓ 备份完成: backup/2025-10-12T15-30-45

📝 更新命令文件...
  ✓ Claude Code: 14 个文件
  ✓ Cursor: 14 个文件
  ✓ Gemini CLI: 14 个文件

🔧 更新脚本文件...
  ✓ 更新 8 个 bash 脚本
  ✓ 更新 8 个 powershell 脚本

📊 升级报告

✅ 升级完成！

升级统计:
  • 版本: 0.16.4 → 0.16.5
  • AI 平台: Claude Code, Cursor, Gemini CLI
  • 命令文件: 42 个
  • 脚本文件: 16 个

📦 备份位置: backup/2025-10-12T15-30-45
   如需回滚，删除当前文件并从备份恢复

✨ 新功能提示:
  • AI 温度控制: write.md 命令新增创作强化指令
  • 多平台支持: 所有 13 个 AI 平台的命令已更新
  • 智能分析: /analyze 命令增强的质量验证

📚 查看详细升级指南: docs/upgrade-guide.md
   或访问: https://github.com/wordflowlab/novel-writer/blob/main/docs/upgrade-guide.md
```

---

### 方法 2：使用 init 命令重新初始化

**适用情况**：
- 需要完全重置配置
- 没有自定义命令文件
- 可以接受命令文件被完全覆盖

**步骤**：

```bash
# 1. 升级全局安装的 novel-writer-cn
npm install -g novel-writer-cn@latest

# 2. 进入项目目录
cd my-novel

# 3. 备份（可选但强烈建议）
cp -r .claude .claude.backup
cp -r .specify .specify.backup

# 4. 重新初始化（只更新命令文件和脚本）
novel init --here --ai claude

# 5. 验证升级
ls .claude/commands/  # 应该看到所有命令文件已更新
```

**注意事项**：
- ✅ 保留：stories/、spec/、memory/ 等所有用户数据
- ✅ 更新：.claude/commands/、.specify/scripts/ 等系统文件
- ⚠️ 覆盖：如果你修改过命令文件，需要手动合并更改

---

### 方法 3：手动复制命令文件（高级用户）

**适用情况**：
- 修改过命令文件，需要精细控制
- 想完全控制升级过程
- 需要保留自定义配置

**步骤**：

#### 3.1 找到 novel-writer-cn 安装位置

```bash
# macOS/Linux
npm list -g novel-writer-cn
# 输出示例：/usr/local/lib/node_modules/novel-writer-cn

# Windows
npm list -g novel-writer-cn
# 输出示例：C:\Users\YourName\AppData\Roaming\npm\node_modules\novel-writer-cn
```

#### 3.2 复制构建产物

```bash
# macOS/Linux
cd my-novel
cp -r /usr/local/lib/node_modules/novel-writer-cn/dist/claude/.claude/commands/* .claude/commands/

# Windows (PowerShell)
cd my-novel
Copy-Item -Recurse "C:\Users\YourName\AppData\Roaming\npm\node_modules\novel-writer-cn\dist\claude\.claude\commands\*" .claude\commands\
```

#### 3.3 更新脚本文件

```bash
# macOS/Linux
cp -r /usr/local/lib/node_modules/novel-writer-cn/scripts/* .specify/scripts/

# Windows (PowerShell)
Copy-Item -Recurse "C:\Users\YourName\AppData\Roaming\npm\node_modules\novel-writer-cn\scripts\*" .specify\scripts\
```

#### 3.4 验证升级

```bash
# 检查命令文件数量（应该是 14 个）
ls .claude/commands/ | wc -l

# 检查命名空间前缀（Claude 使用 novel.* 前缀）
ls .claude/commands/novel.*

# 检查增强版本特征（应该看到 argument-hint, allowed-tools 等字段）
head -20 .claude/commands/novel.analyze.md
```

---

## v0.16.5 多平台升级支持

### 支持的 AI 平台（13 个）

Novel Writer v0.16.5 支持以下 13 个 AI 编程助手平台的完整升级：

| 平台 | 标识符 | 命令目录 | 特殊说明 |
|-----|-------|---------|---------|
| **Claude Code** | `claude` | `.claude/commands` | 默认平台，Markdown 格式 |
| **Cursor** | `cursor` | `.cursor/commands` | Markdown 格式 |
| **Gemini CLI** | `gemini` | `.gemini/commands` | TOML 格式，需要 settings.json |
| **Windsurf** | `windsurf` | `.windsurf/workflows` | 使用 workflows 目录（非 commands） |
| **Roo Code** | `roocode` | `.roo/commands` | Markdown 格式 |
| **GitHub Copilot** | `copilot` | `.github/prompts` | 额外包含 .vscode 目录配置 |
| **Qwen Code** | `qwen` | `.qwen/commands` | Markdown 格式 |
| **OpenCode** | `opencode` | `.opencode/command` | 使用 command (单数形式) |
| **Codex CLI** | `codex` | `.codex/prompts` | Markdown 格式 |
| **Kilo Code** | `kilocode` | `.kilocode/workflows` | 使用 workflows 目录 |
| **Auggie CLI** | `auggie` | `.augment/commands` | Markdown 格式 |
| **CodeBuddy** | `codebuddy` | `.codebuddy/commands` | Markdown 格式 |
| **Amazon Q** | `q` | `.amazonq/prompts` | Markdown 格式 |

### 多平台升级示例

#### 单平台升级

```bash
# 升级 Claude Code
novel upgrade --ai claude

# 升级 Gemini CLI
novel upgrade --ai gemini

# 升级 Windsurf
novel upgrade --ai windsurf

# 升级 GitHub Copilot（包括 .vscode 配置）
novel upgrade --ai copilot
```

#### 多平台批量升级

```bash
# 升级所有已安装平台（自动检测）
novel upgrade

# 或明确指定升级所有平台
novel upgrade --all

# 查看将要升级的平台（预览模式）
novel upgrade --dry-run
```

#### 平台特定功能升级

```bash
# 只更新 Claude 的命令文件
novel upgrade --ai claude --commands

# 只更新 Gemini 的脚本
novel upgrade --ai gemini --scripts

# 更新 Windsurf 的命令和模板
novel upgrade --ai windsurf --commands --templates

# 快速更新 Cursor（跳过确认）
novel upgrade --ai cursor -y
```

### 平台检测机制

`novel upgrade` 会自动检测项目中已安装的 AI 平台：

```bash
$ novel upgrade

📦 Novel Writer 项目升级

当前版本: 0.16.4
目标版本: 0.16.5

✓ 检测到 AI 配置: Claude Code, Cursor, Gemini CLI

升级目标: Claude Code, Cursor, Gemini CLI
```

如果项目中安装了多个平台，默认会升级所有已安装的平台。

### 平台特殊处理

#### Windsurf 和 Kilo Code
这两个平台使用 `workflows` 目录而非 `commands` 目录，升级命令会自动处理：

```bash
novel upgrade --ai windsurf
# 实际更新: .windsurf/workflows/
```

#### GitHub Copilot
GitHub Copilot 需要额外的 VSCode 配置文件，升级时会同时更新：

```bash
novel upgrade --ai copilot
# 实际更新:
#   - .github/prompts/
#   - .vscode/settings.json
```

#### OpenCode
OpenCode 使用单数形式的 `command` 目录：

```bash
novel upgrade --ai opencode
# 实际更新: .opencode/command/
```

#### Gemini CLI
Gemini 使用 TOML 格式，升级时会自动转换命令格式：

```bash
novel upgrade --ai gemini
# 命令文件格式: TOML
# 额外文件: .gemini/settings.json, GEMINI.md
```

### 混合平台项目

如果你的项目中安装了多个 AI 平台（如同时使用 Claude 和 Cursor），可以：

1. **全部升级**（推荐）：
   ```bash
   novel upgrade
   ```

2. **选择性升级**：
   ```bash
   # 只升级 Claude
   novel upgrade --ai claude

   # 交互式选择平台和内容
   novel upgrade -i
   ```

3. **分步升级**：
   ```bash
   # 先升级主要平台
   novel upgrade --ai claude

   # 测试通过后升级其他平台
   novel upgrade --ai cursor
   novel upgrade --ai gemini
   ```

---

## v0.12.2+ 新功能升级指南

### 构建系统与命名空间架构（v0.15.0）

**新增内容**：
- 基于 spec-kit 的构建系统
- 命名空间隔离（Claude: `novel.*` 前缀，Gemini: `novel/` 子目录）
- 单一源文件管理（templates/commands/）
- 构建时生成多平台命令（dist/ 目录）

**如何启用**：

1. **自动升级**（推荐）：
   ```bash
   novel upgrade
   ```
   自动更新为带命名空间的新版本

2. **重新初始化**：
   ```bash
   novel init --here --ai claude
   ```
   所有命令自动使用命名空间版本

3. **验证命名空间**：
   ```bash
   # Claude 命令应该有 novel.* 前缀
   ls .claude/commands/novel.*

   # Gemini 命令应该在 novel/ 子目录
   ls .gemini/commands/novel/
   ```

### Claude Code 增强层（v0.12.2）

**新增内容**：
- 所有 14 个命令都有 Claude Code 增强版本
- 智能参数提示（argument-hint）
- 细粒度权限控制（allowed-tools）
- 动态上下文加载（内联 bash 执行）

**如何启用**：

使用 `novel upgrade` 或 `novel init` 自动获取增强版本

**验证增强功能**：
```bash
# 检查是否包含增强字段（注意命名空间前缀）
grep "argument-hint" .claude/commands/novel.analyze.md
grep "allowed-tools" .claude/commands/novel.track.md
grep "model:" .claude/commands/novel.write.md
```

### 多线索管理系统（v0.12.0）

**新增内容**：
- specification.md 第五章"线索管理规格"
- plot-tracker.json 支持多线索追踪
- creative-plan.md 章节段标注活跃线索

**升级步骤**：

1. **如果还未创建 specification.md**：
   - 在 Claude/Cursor 中运行 `/specify` 命令
   - 新版本会自动包含第五章

2. **如果已有 specification.md**（需要手动添加）：
   - 打开 `stories/your-story/specification.md`
   - 在第五章和第六章之间插入以下内容：

```markdown
## 五、线索管理规格

> **多线索管理说明**：本章节定义故事的所有线索(主线、副线)及其管理策略。

### 5.1 线索定义表

| 线索ID | 线索名称 | 类型 | 优先级 | 起止章节 | 核心冲突 | 主要角色 |
|-------|---------|------|--------|---------|---------|---------|
| PL-01 | [线索名，如"主线"] | 主线 | P0 | 1-100 | [核心冲突] | [角色列表] |

### 5.2 线索节奏规划

| 线索ID | 第一卷 | 第二卷 | 第三卷 |
|-------|--------|--------|--------|
| PL-01 | ⭐⭐⭐ 活跃 | ⭐⭐ 中等 | ⭐⭐⭐ 活跃 |

### 5.3 线索交汇点规划

| 交汇点ID | 章节 | 涉及线索 | 交汇内容 | 预期效果 |
|---------|------|---------|---------|---------|
| X-001 | [章节号] | PL-01+PL-02 | [交汇描述] | [效果] |

### 5.4 伏笔管理表

| 伏笔ID | 埋设章节 | 涉及线索 | 伏笔内容 | 揭晓章节 | 揭晓方式 |
|-------|---------|---------|---------|---------|---------|
| F-001 | [章节] | PL-01 | [内容] | [章节] | [方式] |

### 5.5 线索修改决策矩阵

**修改检查清单**：
1. 检查 5.2节：该线索在哪些卷活跃？
2. 检查 5.3节：该线索涉及哪些交汇点？
3. 检查 5.4节：该线索涉及哪些伏笔？
4. 检查 creative-plan.md：哪些章节段需要同步修改？

### 5.6 线索一致性原则

- 每条线索必须有明确的起承转合
- 主线占用总篇幅的40-60%
- 支线不超过2-3条
```

3. **重新初始化追踪系统**（如果已使用）：
   ```bash
   # 在 AI 助手中运行
   /track-init
   ```
   这会根据新的线索管理规格重新生成 plot-tracker.json

---

## 常见问题 FAQ

### Q1: 升级后我的章节内容会丢失吗？

**A**: 不会。升级只更新命令文件（.claude/commands/）和脚本（.specify/scripts/），不会触碰你的创作内容：
- ✅ 完全保留：`stories/` 目录（所有章节）
- ✅ 完全保留：`spec/` 目录（规格、计划、追踪数据）
- ✅ 完全保留：`memory/` 目录（宪法、个人语料）

### Q2: 我修改过命令文件，升级会覆盖吗？

**A**: 使用 `novel upgrade` 或 `novel init --here` 会覆盖命令文件。建议：

**v0.15.0+ 升级（带命名空间）**：
1. 先备份：`cp -r .claude .claude.backup`
2. 运行 `novel upgrade`
3. 对比差异：`diff .claude.backup/commands/analyze.md .claude/commands/novel.analyze.md`
   - 注意：新版本文件名有 `novel.` 前缀
4. 手动合并自定义部分到新文件

或者使用**方法 3（手动复制）**，只复制特定命令。

### Q3: 升级后 Claude Code 增强功能不生效？

**A**: 检查步骤：
1. 确认使用 Claude Code（不是 Cursor/Windsurf）
2. 检查命令文件是否有增强字段（注意命名空间前缀）：
   ```bash
   grep "argument-hint\|allowed-tools\|model:" .claude/commands/novel.analyze.md
   ```
3. 如果没有，运行 `novel upgrade` 重新升级

### Q4: 如何知道哪些命令获得了 Claude Code 增强？

**A**: v0.12.2 所有 14 个命令都有增强版本：
- **P0**: analyze, write, clarify
- **P1**: track, specify, plan
- **P2**: tasks, plot-check, timeline, relations, world-check
- **其他**: constitution, expert, track-init

### Q5: 升级后可以回滚吗？

**A**: 可以。`novel upgrade` 会自动创建 `backup/` 目录：
```bash
# 如果升级后有问题，从自动备份恢复
rm -rf .claude .specify
mv backup/.claude .claude
mv backup/.specify .specify
```

如果是手动备份：
```bash
# 删除升级后的文件
rm -rf .claude

# 恢复手动备份
mv .claude.backup .claude
```

### Q6: 需要升级 npm 包吗？

**A**: 是的，先升级全局包：
```bash
npm install -g novel-writer-cn@latest
```
然后再执行项目升级：
```bash
novel upgrade
```

### Q7: 命名空间会影响我使用命令吗？

**A**: 不会。命名空间对用户完全透明：
- ✅ 你仍然使用 `/specify`、`/write`、`/track` 等命令
- ✅ AI 工具会自动查找 `novel.specify.md`、`novel.write.md` 等文件
- ✅ 只有文件名有前缀，使用方式完全不变
- ✅ 好处：避免与 spec-kit 或其他工具的命令冲突

### Q8: 多线索管理功能是必须的吗？

**A**: 不是必须的。v0.12.0 的多线索管理是**可选增强功能**：
- 如果你的故事结构简单，不需要添加第五章
- 如果你需要管理复杂的多线索故事，添加后可以获得更好的追踪和验证

### Q9: 升级后命令执行报错？

**A**: 检查升级是否完整：
```bash
# 1. 确认命令文件已更新（应该有 novel.* 前缀）
ls .claude/commands/novel.*

# 2. 确认脚本存在
ls .specify/scripts/bash/

# 3. 如果不完整，重新升级
novel upgrade --ai claude
```

### Q10: 如何使用 v0.16.5 的交互式升级？

**A**: 交互式升级让你可以自由选择要更新的内容：

```bash
novel upgrade -i
```

会显示如下界面：
```
? 选择要更新的内容: (Press <space> to select, <a> to toggle all, <i> to invert)
❯◉ 命令文件 (Commands)
 ◉ 脚本文件 (Scripts)
 ◯ 模板文件 (Templates)
 ◯ 记忆文件 (Memory)
```

使用方法：
- **空格键** - 选择/取消选择当前项
- **a 键** - 全选/取消全选
- **i 键** - 反选
- **回车键** - 确认选择

**推荐使用场景**：
1. 首次升级到 v0.16.5（可以选择性更新）
2. 不确定需要更新哪些内容时
3. 想要更细粒度控制升级过程

### Q11: 可以只更新命令文件不更新脚本吗？

**A**: 可以！v0.16.5 支持选择性更新：

```bash
# 只更新命令文件
novel upgrade --commands

# 只更新脚本文件
novel upgrade --scripts

# 只更新模板文件
novel upgrade --templates

# 只更新记忆文件
novel upgrade --memory

# 组合使用（命令 + 脚本）
novel upgrade --commands --scripts
```

**使用场景**：

1. **只更新命令** - 获取最新命令功能，但保持脚本稳定：
   ```bash
   novel upgrade --commands
   ```

2. **只更新脚本** - 修复脚本 bug，不影响命令：
   ```bash
   novel upgrade --scripts
   ```

3. **框架更新** - 更新模板和记忆文件：
   ```bash
   novel upgrade --templates --memory
   ```

**注意**：
- 默认行为（不指定选项）会更新**命令和脚本**
- 模板和记忆文件默认**不更新**（除非明确指定）
- 可以与 `--ai` 选项组合使用：
  ```bash
  novel upgrade --ai claude --commands
  ```

### Q12: v0.16.5 的"AI 温度控制解决方案"是什么？

**A**: 这是针对 AI 编程工具（Claude Code、Cursor）低温度参数导致的写作问题的解决方案。

**问题背景**：
- AI 编程工具使用低温度（0.0-0.2）确保代码准确性
- 低温度导致小说创作时出现**机械化、扁平化、缺乏情感**
- 用户无法直接调整温度参数

**解决方案**：
在 `write.md` 命令中添加了**创作强化指令**，通过显式的 prompt 引导补偿低温度限制：

```bash
# 升级后自动获取创作强化指令
novel upgrade --commands
```

**创作强化指令包含**：
1. **情感与表达多样性要求** - 避免模板化描写
2. **对话自然化标准** - 拒绝说明式对话，采用真实节奏
3. **场景描写生动化** - 使用感官细节，让场景"活"起来
4. **冲突与张力强化** - 制造戏剧张力，避免平铺直叙
5. **节奏变化要求** - 长短句交替，快慢节奏切换

**效果**：
- 实现 70-80% 的高温度创作效果补偿
- 角色情感更丰富、对话更自然
- 场景描写更生动、冲突更有张力

**查看详细文档**：
```bash
# 文档位置
docs/temperature-guide.md
```

**验证升级**：
```bash
# 检查 write.md 是否包含创作强化指令
grep "创作强化指令" .claude/commands/novel.write.md
```

### Q13: 为什么 v0.16.5 创作强化指令导致 95% AI 浓度？

**A**: v0.16.5 的"创作强化指令"在实际使用中发现了严重问题。

**问题发现**：
- 用户反馈：使用 v0.16.5 生成的内容，腾讯朱雀检测显示 **95% AI 浓度**
- 对比数据：同一平台，手写内容可以达到 **0% AI 浓度**
- 问题根源：v0.16.5 的"补偿低温度"指令方向错误

**错误指令分析**（v0.16.5）：
```markdown
❌ 错误示例 1："每一个场景都要有感官细节 - 至少3种感官体验"
   → 导致：强制堆砌，反而增加 AI 特征

❌ 错误示例 2："房间里弥漫着霉味，唯一的光源是窗帘缝隙透进的灰白月光..."
   → 问题：使用大量 AI 高频词（"弥漫着"、"唯一的"、"直到"）

❌ 错误示例 3："话音未落，她已转身离开。他冲上去抓住她的手腕，她猛地甩开..."
   → 问题：过度戏剧化，典型 AI 腔调
```

**为什么会失败**：
1. **理念错误**：认为"补偿"需要"强化"和"丰富"
2. **方向相反**：实际上 AI 检测器正是通过这些"丰富"特征识别 AI
3. **效果反转**：越"生动"越像 AI，越"简洁"越像人类

**实测数据**：
| 版本 | 指令类型 | AI 浓度 | 朱雀检测 |
|------|---------|---------|---------|
| v0.16.5 | 创作强化（堆砌感官） | 95% | ❌ 未通过 |
| 手写对照 | 简洁克制（白描） | 0% | ✅ 通过 |

**总结**：
v0.16.5 的失败证明：**补偿低温度不应该追求"丰富"，而应该追求"自然"**。

### Q14: v0.17.0 如何解决 AI 检测问题？

**A**: v0.17.0 基于实测 0% AI 浓度案例，完全重构了反 AI 检测策略。

**核心改进**：

**1. 段落结构规范（最关键）⭐**
```markdown
✅ 30-50% 单句成段原则
✅ 每段控制在 50-100 字
✅ 重点信息独立成段

示例（0% AI 浓度）：
永嘉之乱后，中原被异族占领。

汉地士族百姓除了少数不愿离开家乡的，大都南下渡江。

王谯这些年招揽了百十流民为自己种地。
```

**2. AI 高频词黑名单**
```markdown
禁用词汇：
- 描写类：弥漫着、唯一的、摇摇欲坠、宛如
- 动作类：直到、猛地、话音未落、不禁
- 心理类：心中暗想、顿时、内心涌起
- 状态类：空气凝固、时间仿佛静止、皱起眉头

替换策略：
| ❌ AI 词汇        | ✅ 自然替换              |
| 弥漫着霉味       | 有股霉味 / 霉味很重       |
| 唯一的光源       | 只有一点光 / 就一点光     |
| 摇摇欲坠的木桌   | 一张旧木桌 / 破木桌       |
| 他心中暗想       | 他想 / **删除**           |
```

**3. 禁止事项清单**
- ❌ 禁止无意义堆砌（不要强行凑够"3种感官"）
- ❌ 禁止华丽比喻（"空气凝固"→"沉默"）
- ❌ 禁止过度戏剧化（简洁处理冲突）
- ❌ 禁止说明式对话（用真实对话节奏）
- ❌ 禁止直白心理描写（用行为暗示）

**4. 自然化写作原则**
- ✅ 历史白描法（古代背景）：陈述事实，不加修饰
- ✅ 口语化处理（对话）：停顿、语病、重复
- ✅ 短句节奏（叙事）：单句 15-25 字
- ✅ 克制描写（场景）：1-2 个细节即可

**升级方法**：
```bash
# 1. 升级全局包
npm install -g novel-writer-cn@latest

# 2. 升级项目命令（获取新的 write.md）
cd my-novel
novel upgrade --commands

# 3. 验证新规范
grep "反AI检测写作规范" .claude/commands/novel.write.md
```

**效果预期**：
| 指标 | v0.16.5 | v0.17.0 目标 |
|------|---------|-------------|
| AI 浓度 | 95% | < 5% |
| 朱雀检测 | ❌ 未通过 | ✅ 通过 |
| 基于实测 | 理论推测 | 0% 真实案例 |

**验证升级成功**：
```bash
# 检查是否有新的反 AI 检测规范
grep "30-50%单句成段" .claude/commands/novel.write.md

# 检查是否有 AI 高频词黑名单
grep "弥漫着" .claude/commands/novel.write.md

# 检查是否移除了错误的"至少3种感官"指令
! grep "至少3种感官体验" .claude/commands/novel.write.md && echo "✅ 已移除错误指令"
```

**查看完整规范**：
```bash
# 反 AI 检测详细文档
cat spec/presets/anti-ai-detection.md
```

**总结**：
v0.17.0 从"补偿丰富"转向"精准克制"，基于实测成功案例（0% AI 浓度），实现真正有效的反 AI 检测。

---

## 升级检查清单

### 升级前
- [ ] 升级 npm 包：`npm install -g novel-writer-cn@latest`
- [ ] 确认版本：`novel -v` （应该是 0.16.5+）
- [ ] 进入项目目录：`cd my-novel`
- [ ] （可选）手动备份：`cp -r .claude .claude.backup`

### 升级中

**方法选择**：
- [ ] **推荐**：运行 `novel upgrade` （自动备份，升级所有平台）
- [ ] **交互式**：运行 `novel upgrade -i` （手动选择更新内容）
- [ ] **选择性**：运行 `novel upgrade --commands --scripts` （指定更新内容）
- [ ] **平台指定**：运行 `novel upgrade --ai claude` （只升级特定平台）
- [ ] 或选择其他方法（方法 2/3）

**v0.16.5 新选项**：
- [ ] 使用 `-i` 进行交互式选择
- [ ] 使用 `--commands` 只更新命令文件
- [ ] 使用 `--scripts` 只更新脚本文件
- [ ] 使用 `--templates` 更新模板文件（可选）
- [ ] 使用 `--memory` 更新记忆文件（可选）
- [ ] 使用 `--dry-run` 预览升级内容
- [ ] 使用 `-y` 跳过确认提示

### 升级后

**基础验证**：
- [ ] 检查命令数量：`ls .claude/commands/ | wc -l` （应该是 14）
- [ ] 检查命名空间：`ls .claude/commands/novel.*` （应该有 novel.* 前缀）
- [ ] 检查增强功能：`grep "argument-hint" .claude/commands/novel.*.md`
- [ ] 验证用户数据完整：检查 `stories/` 和 `spec/` 目录

**v0.16.5 特性验证**：
- [ ] 查看升级报告（自动显示）
- [ ] 确认升级的平台：报告中显示的 AI 平台列表
- [ ] 确认更新的文件数量：命令、脚本、模板、记忆统计
- [ ] 检查备份位置：`ls backup/` （应该有时间戳目录）
- [ ] 验证创作强化指令：`grep "创作强化指令" .claude/commands/novel.write.md`

**功能测试**：
- [ ] 测试关键命令：在 AI 助手中运行 `/specify` 或 `/write`
- [ ] 测试 AI 温度控制：运行 `/write` 查看创作强化提示
- [ ] 测试多平台（如安装多个）：切换不同 AI 工具测试命令

**升级报告示例**：
```
✅ 升级完成！

升级统计:
  • 版本: 0.16.4 → 0.16.5
  • AI 平台: Claude Code, Cursor, Gemini CLI
  • 命令文件: 42 个
  • 脚本文件: 16 个

📦 备份位置: backup/2025-10-12T15-30-45
```

### 问题排查
- [ ] 如升级失败，检查错误信息
- [ ] 如命令不完整，重新运行 `novel upgrade`
- [ ] 如需回滚，从 `backup/` 目录恢复
- [ ] 查看 FAQ Q9-Q12 了解常见问题解决方法

---

## 获取帮助

- **GitHub Issues**: https://github.com/wordflowlab/novel-writer/issues
- **文档**: https://github.com/wordflowlab/novel-writer#readme
- **CHANGELOG**: 查看 CHANGELOG.md 了解版本变化

---

## 版本历史

### v0.16.5 (2025-10-12)
- 🎯 upgrade 命令增强（交互式选择、选择性更新）
- 🌍 支持所有 13 个 AI 平台的灵活升级
- 💾 选择性备份（只备份要更新的内容）
- 📊 详细的升级报告和统计信息
- 🎨 AI 温度控制解决方案（创作强化指令）

### v0.15.0 (2025-10-11)
- 🏗️ 新增构建系统（基于 spec-kit 架构）
- 🔖 命名空间支持（Claude: novel.* 前缀，Gemini: novel/ 子目录）
- 📦 单一源管理（templates/commands/）
- 🚀 CLI 简化（使用构建产物，减少 ~150 行代码）

### v0.12.2 (2025-10-04)
- ✨ 新增 Claude Code 增强层（所有 14 个命令）
- 📚 升级指南创建

### v0.12.0 (2025-09-30)
- ✨ 新增多线索管理系统
- 📝 specification.md 第五章

### v0.11.0 (2025-09-28)
- ✨ 新增 SDD 方法论实战指南
