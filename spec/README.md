# Spec 目录说明

> Novel Writer 的规范与数据组织中心

## 📁 目录结构

```
spec/
├── config.json                 # 主配置文件
├── README.md                   # 本文件
├── presets/                    # 写作方法预设
│   ├── anti-ai-detection.md    # 反AI检测规范
│   ├── golden-opening.md       # 黄金开篇法则
│   ├── three-act/              # 三幕结构
│   ├── hero-journey/           # 英雄之旅
│   └── ...                     # 其他写作方法
├── checklists/                 # 质量检查清单
│   ├── specification-quality.md
│   ├── plot-logic.md
│   └── ...
├── knowledge/                  # 知识库（积累的内容）
│   ├── world/                  # 世界观知识
│   ├── rules/                  # 规则知识
│   ├── characters/             # 角色档案
│   └── research/               # 研究资料
└── tracking/                   # 追踪数据（运行时数据）
    ├── plot-tracker.json       # 情节追踪
    ├── character-state.json    # 角色状态
    ├── relationships.json      # 关系网络
    └── timeline.json           # 时间线
```

---

## 🎯 目录职责

### 规范层（不变的内容）

**`presets/`** - 写作方法预设
- 职责：存放不同写作方法的模板和规范
- 特点：这些文件是"只读参考"，不应被修改
- 示例：`anti-ai-detection.md`（反AI检测规范）、`golden-opening.md`（黄金开篇法则）
- 升级策略：可以被 `novel upgrade` 安全覆盖

**`checklists/`** - 质量检查清单
- 职责：存放各种质量检查标准
- 特点：标准化的检查项，AI 使用 `/checklist` 命令时会读取
- 示例：`specification-quality.md`（规格完整性检查）、`plot-logic.md`（情节逻辑检查）
- 升级策略：可以被 `novel upgrade` 安全覆盖

**`config.json`** - 主配置文件
- 职责：定义项目级别的配置
- 特点：用户可以修改，但有默认值
- 示例：`{"method": "three-act", "version": "0.5.2"}`
- 升级策略：合并升级（保留用户自定义配置）

### 知识层（积累的内容）

**`knowledge/`** - 知识库
- 职责：存放创作过程中积累的知识和资料
- 特点：完全由用户创建和管理，系统不会覆盖
- 子目录说明：
  - `world/` - 世界观设定（地理、历史、文化）
  - `rules/` - 规则知识（力量体系、法则）
  - `characters/` - 角色档案（深度人物设定）
  - `research/` - 研究资料（参考文献、灵感来源）
- 升级策略：**永不覆盖**，完全保留用户内容

### 追踪层（运行时数据）

**`tracking/`** - 追踪数据
- 职责：存放创作过程中的动态追踪数据
- 特点：随创作进度不断更新
- 示例：
  - `plot-tracker.json` - 记录情节进展
  - `character-state.json` - 记录角色当前状态
  - `relationships.json` - 记录角色关系网络
  - `timeline.json` - 记录事件时间线
- 升级策略：**永不覆盖**，完全保留用户数据

---

## 🔍 查询协议（推荐）

AI 在执行不同命令时，应按照以下顺序查询相关文件，确保上下文完整且优先级正确。

### 创作准备阶段

**适用命令**：`/constitution`, `/specify`, `/clarify`

**查询顺序**：
1. **先查**：`memory/novel-constitution.md`（创作宪法 - 最高原则）
2. **再查**：`memory/style-reference.md`（风格参考 - 如果存在）
3. **最后查**：`spec/presets/`（写作方法预设）

**目的**：确保在定义故事规格时，遵循创作原则和风格指引。

---

### 计划制定阶段

**适用命令**：`/plan`, `/tasks`

**查询顺序**：
1. **先查**：`memory/novel-constitution.md`（创作原则）
2. **再查**：`stories/*/specification.md`（故事规格）
3. **再查**：`spec/presets/golden-opening.md`（如果是前期规划）
4. **最后查**：`spec/knowledge/`（知识库）

**目的**：制定符合规格和原则的创作计划。

---

### 具体写作阶段

**适用命令**：`/write`

**查询顺序（重要！）**：
1. **先查**：`memory/novel-constitution.md`（创作宪法）
2. **再查**：`memory/style-reference.md`（风格参考 - 如果通过 `/book-internalize` 生成）
3. **再查**：`stories/*/specification.md`（故事规格）
4. **再查**：`stories/*/creative-plan.md`（创作计划）
5. **再查**：`stories/*/tasks.md`（当前任务）
6. **再查**：`spec/tracking/` 相关文件：
   - `character-state.json`（角色状态）
   - `relationships.json`（关系网络）
   - `plot-tracker.json`（情节追踪）
7. **再查**：`spec/knowledge/` 相关文件（世界观、角色档案）
8. **再查**：`spec/presets/anti-ai-detection.md`（反AI检测规范）
9. **条件查询**：如果是前三章，额外查询 `spec/presets/golden-opening.md`

**目的**：确保写作时有完整的上下文，符合所有规范和已有设定。

---

### 质量验证阶段

**适用命令**：`/analyze`, `/checklist`, `/track`

**查询顺序**：
1. **先查**：`memory/novel-constitution.md`（对照宪法检查合规性）
2. **再查**：`stories/*/specification.md`（对照规格检查完成度）
3. **再查**：`stories/*/creative-plan.md`（对照计划检查执行情况）
4. **再查**：`spec/tracking/` 所有文件（检查一致性）
5. **再查**：`spec/checklists/`（使用标准化检查清单）
6. **条件查询**：如果是前三章，使用 `spec/presets/golden-opening.md` 的自检清单

**目的**：全面验证内容质量，发现问题并提供改进建议。

---

## ⚙️ 规则优先级

当不同文件的规则产生冲突时，按照以下优先级处理：

### 优先级顺序（从高到低）

1. **用户即时指令**（最高优先级）
   - 用户在命令中的具体要求
   - 示例："这一章不要用黄金开篇法则，我想慢慢铺垫"
   - 效果：覆盖所有预设规则

2. **创作宪法**（`memory/novel-constitution.md`）
   - 项目的最高创作原则
   - 示例："本作品禁止描写暴力场景"
   - 效果：覆盖所有预设规范

3. **风格参考**（`memory/style-reference.md`）
   - 对标作品的风格指引
   - 示例："使用短句，避免华丽比喻"
   - 效果：影响具体写作风格

4. **故事规格**（`stories/*/specification.md`）
   - 当前故事的具体要求
   - 示例："目标读者是15-25岁男性"
   - 效果：影响内容定位和风格

5. **写作方法预设**（`spec/presets/`）
   - 标准化的写作规范
   - 示例：`anti-ai-detection.md`, `golden-opening.md`
   - 效果：提供基础规范和最佳实践

6. **知识库和追踪数据**（`spec/knowledge/`, `spec/tracking/`）
   - 已有的设定和状态
   - 示例：角色已经死亡，不能再出现
   - 效果：确保一致性

### 冲突解决示例

**场景1**：黄金开篇 vs 创作宪法
- **冲突**：`golden-opening.md` 要求第一章直接冲突，但 `constitution.md` 要求"慢热型，重视氛围营造"
- **解决**：遵循 `constitution.md`，修改开篇策略
- **依据**：创作宪法优先级高于预设规范

**场景2**：风格参考 vs 反AI检测
- **冲突**：`style-reference.md` 说对标作品使用华丽比喻，但 `anti-ai-detection.md` 说要避免华丽比喻
- **解决**：优先 `style-reference.md`，但在华丽比喻上做适度克制
- **依据**：风格参考优先级略高，但需平衡

**场景3**：用户即时指令 vs 所有预设
- **冲突**：用户说"这一章用大量环境描写铺垫气氛"，但所有规范都说要克制描写
- **解决**：完全遵循用户指令
- **依据**：用户即时指令拥有最高优先级

---

## 🚀 最佳实践

### 1. 项目初始化时

建议的创建顺序：
1. 运行 `/constitution` 创建 `memory/novel-constitution.md`
2. （可选）运行 `/book-analyze` + `/book-internalize` 生成 `memory/style-reference.md`
3. 运行 `/specify` 创建 `stories/*/specification.md`
4. 运行 `/plan` 创建 `stories/*/creative-plan.md`
5. 开始创作前，手动创建 `spec/knowledge/` 相关文件（世界观、角色等）

### 2. 创作过程中

**每次写作前**：
- 确保 `spec/tracking/` 数据是最新的
- 检查是否有新的角色或设定需要记录到 `spec/knowledge/`

**每完成5章**：
- 运行 `/analyze` 进行质量检查
- 运行 `/track` 更新追踪数据
- 必要时运行 `/checklist` 进行专项检查

### 3. 版本升级时

**安全升级**：
```bash
novel upgrade
```

**升级策略**：
- `spec/presets/` - 会被更新（新增更好的规范）
- `spec/checklists/` - 会被更新（新增检查项）
- `spec/config.json` - 会合并更新（保留你的自定义配置）
- `spec/knowledge/` - **永不覆盖**
- `spec/tracking/` - **永不覆盖**

### 4. 多项目管理

如果你同时创作多部作品：
- 每部作品都有独立的 `spec/` 目录
- 但可以共享 `presets/` 中的规范（通过软链接或复制）
- `knowledge/` 和 `tracking/` 必须各自独立

---

## 📝 文件命名规范

### knowledge/ 目录

**推荐命名**：
- 世界观：`world/geography.md`, `world/history.md`
- 规则：`rules/power-system.md`, `rules/magic-rules.md`
- 角色：`characters/protagonist.md`, `characters/villain.md`
- 研究：`research/[作品名]-analysis.md`

### tracking/ 目录

**固定命名**（由系统生成，不要修改）：
- `plot-tracker.json`
- `character-state.json`
- `relationships.json`
- `timeline.json`
- `validation-rules.json`

### checklists/ 目录

**推荐命名**：
- 规格类：`specification-*.md`
- 内容类：`plot-*.md`, `character-*.md`, `world-*.md`
- 风格类：`style-*.md`, `dialogue-*.md`

---

## 🔧 进阶技巧

### 技巧1：使用符号链接共享预设

如果你有多个项目想共享相同的写作方法预设：

```bash
# 在项目A中
cd project-a/spec
ln -s /path/to/shared-presets presets

# 项目B也可以这样做
cd project-b/spec
ln -s /path/to/shared-presets presets
```

### 技巧2：建立个人规范库

创建一个 `~/.novel-writer/presets/` 目录，存放你个人总结的写作规范，然后在项目中引用。

### 技巧3：使用 Git 版本控制

强烈建议将 `spec/` 目录纳入 Git 版本控制：

```bash
# .gitignore
spec/tracking/*.json  # 追踪数据不纳入版本控制
spec/knowledge/      # 知识库可选择性纳入

# 但这些应该纳入：
spec/presets/
spec/checklists/
spec/config.json
```

---

## ❓ 常见问题

### Q1: `knowledge/` 和 `tracking/` 有什么区别？

**A**:
- `knowledge/` 是"静态知识"，比如角色的基础设定、世界观规则，不会频繁变化
- `tracking/` 是"动态状态"，比如角色当前的位置、关系、情绪，每章都可能变化

### Q2: 可以删除 `presets/` 里不用的方法吗？

**A**:
可以，但不推荐。保留它们不会占用多少空间，且未来可能会用到。如果确实想删除，记得备份。

### Q3: 升级后 `presets/` 被覆盖了怎么办？

**A**:
这是正常的。`presets/` 的设计就是可以被安全覆盖的。如果你对某个预设做了自定义修改，应该：
1. 复制到 `memory/` 或 `knowledge/` 目录
2. 或者重命名（如 `anti-ai-detection-custom.md`）

### Q4: 我可以自己创建预设吗？

**A**:
当然可以！在 `presets/` 或 `memory/` 中创建任何你需要的 `.md` 文件，AI 在读取目录时会发现它们。

---

## 📚 相关文档

- **创作流程指南**：`docs/workflow.md`
- **命令详解**：`docs/commands.md`
- **最佳实践**：`docs/best-practices.md`
- **升级指南**：`docs/upgrade-guide.md`

---

**版本**：v1.0.0
**更新日期**：2025-01-14
**维护者**：Novel Writer Team
