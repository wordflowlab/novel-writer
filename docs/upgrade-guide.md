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

### 方法 1：使用 init 命令覆盖（推荐，最简单）

**适用情况**：
- 没有自定义命令文件
- 可以接受命令文件被完全覆盖
- 用户数据（stories/, spec/）会被保留

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

### 方法 2：手动复制命令文件（最安全，保留自定义）

**适用情况**：
- 修改过命令文件（.claude/commands/*.md）
- 想完全控制升级过程
- 需要保留自定义配置

**步骤**：

#### 2.1 找到 novel-writer-cn 安装位置

```bash
# macOS/Linux
npm list -g novel-writer-cn
# 输出示例：/usr/local/lib/node_modules/novel-writer-cn

# Windows
npm list -g novel-writer-cn
# 输出示例：C:\Users\YourName\AppData\Roaming\npm\node_modules\novel-writer-cn
```

#### 2.2 复制 Claude Code 增强命令（v0.12.2 新增）

```bash
# macOS/Linux
cd my-novel
cp -r /usr/local/lib/node_modules/novel-writer-cn/templates/commands-claude/* .claude/commands/

# Windows (PowerShell)
cd my-novel
Copy-Item -Recurse "C:\Users\YourName\AppData\Roaming\npm\node_modules\novel-writer-cn\templates\commands-claude\*" .claude\commands\
```

#### 2.3 更新脚本文件

```bash
# macOS/Linux
cp -r /usr/local/lib/node_modules/novel-writer-cn/scripts/* .specify/scripts/

# Windows (PowerShell)
Copy-Item -Recurse "C:\Users\YourName\AppData\Roaming\npm\node_modules\novel-writer-cn\scripts\*" .specify\scripts\
```

#### 2.4 验证升级

```bash
# 检查命令文件数量（应该是 14 个）
ls .claude/commands/ | wc -l

# 检查增强版本特征（应该看到 argument-hint, allowed-tools 等字段）
head -20 .claude/commands/analyze.md
```

---

### 方法 3：选择性升级（针对特定命令）

**适用情况**：
- 只想升级部分命令
- 大部分自定义命令要保留
- 只想体验新的 Claude Code 增强功能

**步骤**：

```bash
# 1. 找到安装位置（同方法 2.1）
NOVEL_PATH=$(npm list -g novel-writer-cn | grep novel-writer-cn | awk '{print $NF}' | sed 's/@.*//')

# 2. 只复制你想升级的命令，例如：
cp "$NOVEL_PATH/templates/commands-claude/analyze.md" .claude/commands/
cp "$NOVEL_PATH/templates/commands-claude/write.md" .claude/commands/
cp "$NOVEL_PATH/templates/commands-claude/track.md" .claude/commands/

# 3. 验证
head -20 .claude/commands/analyze.md  # 检查是否有增强字段
```

---

## v0.12.2 新功能升级指南

### Claude Code 增强层

**新增内容**：
- 所有 14 个命令都有 Claude Code 增强版本
- 智能参数提示（argument-hint）
- 细粒度权限控制（allowed-tools）
- 动态上下文加载（内联 bash 执行）

**如何启用**：

1. **全局升级**（方法 1）：
   ```bash
   novel init --here --ai claude
   ```
   所有命令自动使用增强版本

2. **手动升级**（方法 2）：
   复制 `templates/commands-claude/` 到 `.claude/commands/`

3. **验证增强功能**：
   ```bash
   # 检查是否包含增强字段
   grep "argument-hint" .claude/commands/analyze.md
   grep "allowed-tools" .claude/commands/track.md
   grep "model:" .claude/commands/write.md
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

**A**: 使用方法 1（`novel init --here`）会覆盖。建议：
1. 先备份：`cp -r .claude .claude.backup`
2. 升级后对比：`diff .claude.backup/commands/analyze.md .claude/commands/analyze.md`
3. 手动合并自定义部分

或者使用**方法 3（选择性升级）**，只升级未修改的命令。

### Q3: 升级后 Claude Code 增强功能不生效？

**A**: 检查步骤：
1. 确认使用 Claude Code（不是 Cursor/Windsurf）
2. 检查命令文件是否有增强字段：
   ```bash
   grep "argument-hint\|allowed-tools\|model:" .claude/commands/analyze.md
   ```
3. 如果没有，说明使用了基础版本，需要从 `templates/commands-claude/` 复制

### Q4: 如何知道哪些命令获得了 Claude Code 增强？

**A**: v0.12.2 所有 14 个命令都有增强版本：
- **P0**: analyze, write, clarify
- **P1**: track, specify, plan
- **P2**: tasks, plot-check, timeline, relations, world-check
- **其他**: constitution, expert, track-init

### Q5: 升级后可以回滚吗？

**A**: 可以，如果你做了备份：
```bash
# 删除升级后的文件
rm -rf .claude

# 恢复备份
mv .claude.backup .claude
```

### Q6: 需要升级 npm 包吗？

**A**: 是的，先升级全局包：
```bash
npm install -g novel-writer-cn@latest
```
然后再执行项目升级步骤。

### Q7: 多线索管理功能是必须的吗？

**A**: 不是必须的。v0.12.0 的多线索管理是**可选增强功能**：
- 如果你的故事结构简单，不需要添加第五章
- 如果你需要管理复杂的多线索故事，添加后可以获得更好的追踪和验证

### Q8: 升级后命令执行报错？

**A**: 检查脚本是否更新：
```bash
# 确认脚本存在
ls .specify/scripts/bash/

# 重新复制脚本
novel init --here --ai claude
```

---

## 升级检查清单

升级前：
- [ ] 备份项目：`cp -r my-novel my-novel-backup`
- [ ] 升级 npm 包：`npm install -g novel-writer-cn@latest`
- [ ] 记录当前版本：`novel -v`

升级中：
- [ ] 选择升级方法（方法 1/2/3）
- [ ] 执行升级步骤
- [ ] 验证命令文件已更新

升级后：
- [ ] 检查命令数量：`ls .claude/commands/ | wc -l` （应该是 14）
- [ ] 检查增强功能：`grep "argument-hint" .claude/commands/*.md`
- [ ] 测试关键命令：在 AI 助手中运行 `/analyze` 或 `/track`
- [ ] 验证用户数据完整：检查 `stories/` 和 `spec/` 目录

---

## 获取帮助

- **GitHub Issues**: https://github.com/wordflowlab/novel-writer/issues
- **文档**: https://github.com/wordflowlab/novel-writer#readme
- **CHANGELOG**: 查看 CHANGELOG.md 了解版本变化

---

## 版本历史

### v0.12.2 (2025-10-04)
- ✨ 新增 Claude Code 增强层（所有 14 个命令）
- 📚 本升级指南创建

### v0.12.0 (2025-09-30)
- ✨ 新增多线索管理系统
- 📝 specification.md 第五章

### v0.11.0 (2025-09-28)
- ✨ 新增 SDD 方法论实战指南
