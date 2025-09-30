# Novel Writer 产品需求文档 (PRD)

## 1. 产品概述

### 1.1 产品名称
**Novel Writer** - AI 驱动的中文小说创作工具

### 1.2 产品定位
参考 Spec-Kit 方法论的 AI 智能小说创作平台，采用规格驱动创作(Spec-Driven Writing)的理念，通过结构化的工作流程（风格设定→故事大纲→章节规划→任务分解→内容创作）来组织小说项目的创建和管理。专注于为中文内容创作者提供智能化的小说写作辅助能力，支持多种文体风格、角色管理、世界观构建等功能。

### 1.3 目标用户
- **网文作者**：起点、晋江等平台的签约作者和新人作者
- **传统作家**：寻求数字化创作工具的传统文学创作者
- **业余写手**：有创作热情但缺乏专业技巧的爱好者
- **内容团队**：网文工作室、IP孵化公司
- **学生群体**：文学专业学生、创意写作学习者

### 1.4 核心价值
- **降低创作门槛**：通过 AI 辅助简化创作流程，帮助新手快速上手
- **提升写作效率**：结构化管理，避免写作瓶颈和剧情混乱
- **保证内容质量**：AI 智能建议，保持风格一致性和逻辑连贯性
- **激发创作灵感**：提供创意建议，突破思维定式
- **版本管理便捷**：Git 集成，轻松管理创作版本

### 1.5 开发方法论

Novel Writer 借鉴了 Spec-Kit 的结构化开发理念，建立了适合小说创作领域的工作流程：

- **规格优先**：先定义创作风格和故事框架，再进行具体写作
- **分阶段执行**：遵循 style → story → outline → chapters → write 的渐进式流程
- **模板驱动**：使用标准化模板确保创作的一致性
- **AI 增强**：每个阶段都有 AI 智能辅助，提升创作质量

### 1.6 Novel Writer vs Spec-Kit

| 方面 | Spec-Kit | Novel Writer |
|------|----------|--------------|
| 定位 | 通用软件开发方法论 | 小说创作专用工具 |
| 核心理念 | Spec-Driven Development | 借鉴 SDD，应用于创作领域 |
| 工作流 | specify→plan→tasks→implement | style→story→outline→chapters→write |
| 输出物 | 软件代码 | 小说章节 |
| 目标用户 | 软件开发者 | 小说创作者 |
| 项目组织 | specs/目录 | stories/目录 |

## 2. 功能需求

### 2.0 工作流命令（参考 Spec-Kit 方法论）

Novel Writer 提供两类命令：工作流命令和 CLI 工具命令。

#### 工作流命令
这些命令参考 Spec-Kit 的方法论，用于组织和管理小说项目：

### 2.1 创作风格设定（/constitution）

#### 功能描述
设定小说的整体创作风格和准则，建立创作的基本原则，贯穿整个作品。

#### 核心能力
- **叙事视角设定**：第一人称、第三人称、全知视角等
- **文字风格定义**：简洁明快、华丽优美、幽默诙谐等
- **创作原则制定**：角色塑造原则、情节推进节奏、描写侧重点
- **质量标准设置**：字数要求、更新频率、读者定位

#### 技术实现
```yaml
输入参数:
  - style_type: 文体风格（网文/文学/轻小说）
  - narrative: 叙事视角
  - tone: 文字基调
  - principles: 创作原则列表

输出格式:
  - 生成 .specify/memory/writing-constitution.md
  - 包含完整的风格规范文档
```

### 2.2 故事大纲创建（/specify）

#### 功能描述
创建完整的故事设定，包括主题、角色、世界观等核心要素。

#### 核心能力
- **故事内核**：一句话概括、核心冲突、主题思想
- **角色设定**：主角和配角的详细设定、成长弧线、关系网络
- **世界观构建**：时代背景、地理环境、社会结构、特殊规则
- **情节结构**：三幕结构或起承转合的大纲规划

#### 技术实现
```yaml
输入参数:
  - description: 故事描述
  - genre: 类型（科幻/奇幻/现实/历史等）
  - length: 预计字数

输出格式:
  - 创建 stories/[编号-名称]/specify.md
  - 使用 story-template.md 模板
  - 自动生成带编号的目录结构
```

### 2.3 章节规划（/plan）

#### 功能描述
将故事大纲细化为具体的章节结构，制定详细的创作计划。

#### 核心能力
- **卷册划分**：根据剧情发展划分卷册
- **章节安排**：每章的主要事件和功能
- **节奏控制**：高潮分布、张弛有度
- **伏笔管理**：伏笔设置和回收计划

#### 技术实现
```yaml
输入参数:
  - total_chapters: 总章节数
  - volume_structure: 卷册结构
  - pacing_plan: 节奏规划

输出格式:
  - 生成 stories/[编号]/plan.md
  - 包含详细的章节大纲
  - 动态卷册管理（不限制固定卷数）
```

### 2.4 任务分解（/tasks）

#### 功能描述
将章节规划分解为可执行的具体任务，便于管理和追踪。

#### 核心能力
- **写作任务**：具体章节的创作任务
- **设定任务**：角色深化、世界观补充
- **修订任务**：内容修改、逻辑检查
- **优先级管理**：P0-P3 的任务优先级

#### 技术实现
```yaml
输入参数:
  - outline_file: 章节大纲文件
  - priority_rules: 优先级规则

输出格式:
  - 生成 stories/[编号]/tasks.md
  - 创建 progress.json 进度文件
  - 支持任务状态追踪
```

### 2.5 章节写作（/write）

#### 功能描述
AI 辅助创作具体的章节内容，保持风格一致性。

#### 核心能力
- **内容生成**：根据大纲生成章节内容
- **风格保持**：遵循既定的创作风格
- **角色一致**：保持角色性格和语言特点
- **情节连贯**：确保与前后章节的逻辑连接

#### 技术实现
```yaml
输入参数:
  - chapter_num: 章节编号
  - chapter_title: 章节标题
  - outline_point: 大纲要点
  - previous_context: 前文内容

输出格式:
  - 生成 chapters/volume-X/chapter-XXX.md
  - 3000-4000字的章节内容
  - 包含章节元信息
```

### 2.6 CLI 工具命令

#### novel init
初始化小说项目，创建项目结构：

```bash
novel init [name] [options]
  --here            # 在当前目录初始化
  --ai <type>       # 选择 AI 助手类型
  --all             # 为所有 AI 生成配置
  --no-git          # 跳过 Git 初始化
```

功能特性：
- 创建标准项目结构
- 生成 AI 助手配置文件
- 复制命令模板和脚本
- 初始化 Git 仓库

#### novel check
检查系统环境和配置：

```bash
novel check
```

检查项目：
- Node.js 环境
- Git 工具
- AI 助手安装状态
- 项目配置完整性

## 3. 系统架构

### 3.1 工作流架构

Novel Writer 采用五阶段工作流（扩展自 Spec-Kit 的四阶段模型）：

#### Phase 1: Style（风格设定）
- **命令**：`/constitution`
- **输入**：创作风格描述
- **输出**：.specify/memory/writing-constitution.md
- **内容**：叙事视角、文字风格、创作原则

#### Phase 2: Story（故事创建）
- **命令**：`/specify`
- **输入**：故事概念描述
- **输出**：stories/[编号]/specify.md
- **内容**：故事大纲、角色设定、世界观

#### Phase 3: Outline（章节规划）
- **命令**：`/plan`
- **输入**：故事大纲
- **输出**：stories/[编号]/plan.md
- **内容**：卷册结构、章节安排、节奏控制

#### Phase 4: Tasks（任务分解）
- **命令**：`/tasks`
- **输入**：章节大纲
- **输出**：stories/[编号]/tasks.md
- **内容**：具体任务、优先级、依赖关系

#### Phase 5: Write（内容创作）
- **命令**：`/write`
- **输入**：任务列表
- **输出**：chapters/volume-X/chapter-XXX.md
- **内容**：章节内容、角色对话、场景描写

### 3.2 技术架构

```
┌─────────────────────────────────────────────┐
│            AI 助手界面                        │
│   (Claude/Cursor/Gemini/Windsurf)           │
├─────────────────────────────────────────────┤
│         命令解析层                            │
│     (Slash Commands Parser)                  │
├─────────────────────────────────────────────┤
│         业务逻辑层                            │
│   ┌──────────┬──────────┬──────────┐       │
│   │ 风格管理  │ 大纲生成  │ 章节创作  │       │
│   └──────────┴──────────┴──────────┘       │
├─────────────────────────────────────────────┤
│         模板引擎层                            │
│   ┌──────────┬──────────┬──────────┐       │
│   │ 故事模板  │ 章节模板  │ 角色模板  │       │
│   └──────────┴──────────┴──────────┘       │
├─────────────────────────────────────────────┤
│         文件系统层                            │
│   ┌──────────┬──────────┬──────────┐       │
│   │ 项目管理  │ 版本控制  │ 备份恢复  │       │
│   └──────────┴──────────┴──────────┘       │
└─────────────────────────────────────────────┘
```

### 3.3 数据流设计

```mermaid
graph LR
    A[用户输入] --> B[风格设定]
    B --> C[故事创建]
    C --> D[章节规划]
    D --> E[任务分解]
    E --> F[AI写作]
    F --> G[内容生成]
    G --> H[质量检查]
    H --> I[最终输出]
    I --> J[版本管理]
```

### 3.4 目录结构

```bash
novel-project/
├── .specify/                 # Novel Writer 配置
│   ├── config.json          # 项目配置
│   ├── spec.md              # 命令规范文档
│   ├── memory/              # 创作记忆
│   │   └── writing-constitution.md  # 风格准则
│   ├── templates/           # 模板文件
│   │   ├── story-template.md
│   │   └── outline-template.md
│   └── scripts/             # 执行脚本
│       ├── bash/            # Unix/Linux/Mac
│       └── powershell/      # Windows
├── .claude/                 # Claude 配置
│   └── commands/            # 命令文件
├── .cursor/                 # Cursor 配置
│   └── commands/            # 命令文件
├── .gemini/                 # Gemini 配置
│   └── commands/            # TOML 格式命令
├── .windsurf/               # Windsurf 配置
│   └── workflows/           # 工作流文件
├── stories/                 # 故事项目
│   └── [编号-项目名]/       # 通过 /specify 生成
│       ├── story.md         # 故事大纲
│       ├── outline.md       # 章节规划
│       ├── tasks.md         # 任务列表
│       ├── progress.json    # 进度追踪
│       ├── chapters/        # 章节内容
│       │   ├── volume-1/    # 第一卷
│       │   ├── volume-2/    # 第二卷
│       │   └── ...
│       ├── characters/      # 角色设定
│       └── worldbuilding/   # 世界观资料
└── .gitignore              # Git 忽略规则
```

## 4. 案例实现

### 4.1 案例概述："大明风华"历史小说

创建一部以明朝为背景的历史小说，通过完整的 Novel Writer 工作流程展示产品功能。

### 4.2 创作流程演示

#### Step 1: 项目初始化
```bash
novel init damingfenghua --ai claude
cd damingfenghua
```

#### Step 2: 风格设定
```
/constitution
文体风格：历史正剧，文学性较强
叙事视角：第三人称全知视角
语言风格：古白话结合现代汉语，典雅但不晦涩
创作原则：尊重历史，合理虚构，注重人物心理刻画
章节长度：每章 4000-5000 字
更新计划：每周三更
```

#### Step 3: 故事大纲
```
/specify 明朝永乐年间，一个现代考古学家穿越成为朱棣第五子朱橚，
利用现代知识改变历史，最终成就大明盛世的故事
```

生成内容示例：
- **一句话故事**：现代考古学家穿越明朝，成为藩王改变历史
- **核心冲突**：现代思想与封建体制的碰撞
- **主要角色**：朱橚（主角）、朱棣（父亲）、解缙（导师）
- **历史背景**：永乐年间，靖难之役后的政治格局

#### Step 4: 章节规划
```
/plan
总计划：240章，分为4卷
第一卷：适应与谋划（1-60章）
第二卷：改革与阻力（61-120章）
第三卷：征战与扩张（121-180章）
第四卷：盛世与传承（181-240章）
```

#### Step 5: 任务分解
```
/tasks
优先级P0：前10章（建立人物和世界观）
优先级P1：各卷高潮章节
优先级P2：日常推进章节
优先级P3：支线剧情章节
```

#### Step 6: 章节创作
```
/write 第1章 穿越大明

【本章要点】
1. 考古发现永乐大典真本
2. 意外穿越到永乐二年
3. 发现自己成为朱橚
4. 初步了解所处环境

【创作要求】
- 开篇吸引眼球
- 快速建立代入感
- 展现时代特征
- 埋下后续伏笔
```

### 4.3 输出成果

最终生成的项目结构：
```
stories/001-damingfenghua/
├── story.md              # 完整故事大纲
├── outline.md            # 240章详细规划
├── tasks.md              # 任务分解清单
├── progress.json         # 写作进度追踪
├── chapters/
│   ├── volume-1/         # 第一卷：适应与谋划
│   │   ├── chapter-001.md  # 第1章：穿越大明
│   │   ├── chapter-002.md  # 第2章：初见朱棣
│   │   └── ...
│   ├── volume-2/         # 第二卷：改革与阻力
│   ├── volume-3/         # 第三卷：征战与扩张
│   └── volume-4/         # 第四卷：盛世与传承
├── characters/           # 人物设定
│   ├── 朱橚.md
│   ├── 朱棣.md
│   └── 解缙.md
└── worldbuilding/        # 世界观设定
    ├── 永乐朝廷.md
    ├── 明朝科技.md
    └── 改革方案.md
```

## 5. API 集成方案

### 5.1 AI 助手集成架构

#### 支持的 AI 平台
1. **Claude（Anthropic）**
   - 优势：理解力强，创作质量高
   - 集成方式：Markdown 格式命令文件
   - 配置目录：.claude/commands/

2. **Cursor**
   - 优势：IDE 集成，实时预览
   - 集成方式：Markdown 格式命令文件
   - 配置目录：.cursor/commands/

3. **Gemini（Google）**
   - 优势：知识面广，多模态能力
   - 集成方式：TOML 格式配置文件
   - 配置目录：.gemini/commands/

4. **Windsurf**
   - 优势：工作流自动化
   - 集成方式：Workflow 定义文件
   - 配置目录：.windsurf/workflows/

### 5.2 命令解析机制

```typescript
interface Command {
  name: string;           // 命令名称
  description: string;    // 命令描述
  scripts: {
    sh?: string;         // Bash 脚本路径
    ps?: string;         // PowerShell 脚本路径
  };
  prompt: string;        // AI 提示词模板
}

class CommandParser {
  parseCommand(input: string): Command {
    // 1. 提取命令名称
    const commandName = extractCommandName(input);

    // 2. 加载命令模板
    const template = loadTemplate(commandName);

    // 3. 解析参数
    const params = parseParameters(input);

    // 4. 执行脚本
    return executeScript(template, params);
  }
}
```

### 5.3 模板系统设计

#### 模板类型
1. **故事模板**（story-template.md）
   - 基本信息
   - 故事内核
   - 角色设定
   - 世界观
   - 情节大纲

2. **章节模板**（outline-template.md）
   - 卷册结构
   - 章节列表
   - 节奏规划
   - 伏笔设置

3. **角色模板**（character-template.md）
   - 基础属性
   - 性格特征
   - 背景故事
   - 成长轨迹

#### 模板渲染引擎
```typescript
class TemplateEngine {
  render(templatePath: string, data: any): string {
    const template = fs.readFileSync(templatePath, 'utf-8');
    return template.replace(/\{\{(\w+)\}\}/g, (match, key) => {
      return data[key] || match;
    });
  }
}
```

## 6. 平台适配规范

### 6.1 跨平台脚本支持

#### Bash 脚本（Unix/Linux/Mac）
```bash
#!/usr/bin/env bash
# 脚本标准头部
set -e  # 错误时退出
source "$(dirname "$0")/common.sh"  # 加载公共函数
```

特性：
- 使用 POSIX 兼容语法
- 支持 macOS 和 Linux
- 自动设置执行权限

#### PowerShell 脚本（Windows）
```powershell
# 脚本标准头部
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
. "$PSScriptRoot\common.ps1"  # 加载公共函数
```

特性：
- PowerShell 5.1+ 兼容
- UTF-8 编码支持
- Windows 10/11 原生支持

### 6.2 AI 平台适配策略

#### 命令格式转换
```typescript
class PlatformAdapter {
  // Markdown 转 TOML（for Gemini）
  mdToToml(mdContent: string): string {
    const parsed = parseMarkdown(mdContent);
    return generateToml(parsed);
  }

  // 生成平台特定配置
  generateConfig(platform: string, commands: Command[]): void {
    switch(platform) {
      case 'claude':
      case 'cursor':
        this.generateMarkdownCommands(commands);
        break;
      case 'gemini':
        this.generateTomlCommands(commands);
        break;
      case 'windsurf':
        this.generateWorkflows(commands);
        break;
    }
  }
}
```

### 6.3 错误处理与兼容性

#### 错误处理机制
```typescript
class ErrorHandler {
  handle(error: Error, context: string): void {
    // 1. 记录错误日志
    this.logError(error, context);

    // 2. 用户友好提示
    this.showUserMessage(error);

    // 3. 提供解决方案
    this.suggestSolution(error);

    // 4. 回滚操作（如需要）
    this.rollback(context);
  }
}
```

#### 版本兼容性检查
```typescript
class CompatibilityChecker {
  check(): boolean {
    // Node.js 版本检查
    if (!this.checkNodeVersion('>=18.0.0')) {
      throw new Error('需要 Node.js 18.0.0 或更高版本');
    }

    // Git 检查（可选）
    if (!this.checkGit()) {
      console.warn('Git 未安装，版本控制功能将不可用');
    }

    return true;
  }
}
```

## 7. 测试计划

### 7.1 功能测试

#### 命令测试
- [ ] `/constitution` 命令生成正确的风格文档
- [ ] `/specify` 命令创建完整的故事大纲
- [ ] `/plan` 命令生成合理的章节规划
- [ ] `/tasks` 命令正确分解任务
- [ ] `/write` 命令生成高质量章节内容

#### CLI 测试
- [ ] `novel init` 正确创建项目结构
- [ ] `novel check` 准确检测环境状态
- [ ] 多平台配置文件正确生成
- [ ] Git 初始化和提交功能正常

### 7.2 兼容性测试

#### 平台测试
- [ ] Windows 10/11 PowerShell 脚本执行
- [ ] macOS Bash 脚本执行
- [ ] Linux 各发行版兼容性
- [ ] Node.js 18/20/21 版本兼容

#### AI 助手测试
- [ ] Claude 命令识别和执行
- [ ] Cursor 集成功能正常
- [ ] Gemini TOML 配置解析
- [ ] Windsurf 工作流运行

### 7.3 性能测试

- [ ] 大型项目（240章）的处理速度
- [ ] 文件系统操作效率
- [ ] 内存使用情况监控
- [ ] 并发写作任务处理

### 7.4 用户体验测试

- [ ] 新手引导流程顺畅度
- [ ] 错误提示友好性
- [ ] 命令响应速度
- [ ] 文档完整性和准确性

## 8. 部署计划

### 8.1 版本发布策略

#### 版本号规范（语义化版本）
- **主版本号**：重大功能更新或不兼容变更
- **次版本号**：新功能添加，向后兼容
- **修订号**：Bug 修复和小改进

当前版本：0.3.7

### 8.2 发布渠道

#### NPM 发布
```bash
# 构建项目
npm run build

# 更新版本号
npm version patch/minor/major

# 发布到 NPM
npm publish
```

#### GitHub 发布
- Release 标签
- 更新日志（CHANGELOG.md）
- 二进制分发（可选）

### 8.3 更新通知机制

```typescript
class UpdateChecker {
  async checkForUpdates(): Promise<void> {
    const currentVersion = packageJson.version;
    const latestVersion = await fetchLatestVersion();

    if (semver.lt(currentVersion, latestVersion)) {
      console.log(chalk.yellow(
        `新版本可用: ${latestVersion}\n` +
        `运行 npm update -g novel-writer-cn 更新`
      ));
    }
  }
}
```

## 9. 风险与对策

### 9.1 技术风险

#### AI 理解偏差
- **风险**：AI 可能误解用户意图
- **对策**：提供详细的命令说明和示例

#### 跨平台兼容性
- **风险**：脚本在不同系统上执行异常
- **对策**：充分测试，提供双平台脚本

### 9.2 用户风险

#### 学习曲线
- **风险**：新用户上手困难
- **对策**：提供详细文档和视频教程

#### 数据安全
- **风险**：创作内容丢失
- **对策**：Git 版本控制，自动备份机制

### 9.3 运营风险

#### 维护成本
- **风险**：多平台支持增加维护负担
- **对策**：模块化设计，自动化测试

## 10. 成功指标

### 10.1 技术指标
- 命令执行成功率 > 99%
- 平均响应时间 < 2秒
- 崩溃率 < 0.1%

### 10.2 用户指标
- NPM 周下载量 > 1000
- GitHub Star 数 > 500
- 活跃用户留存率 > 60%

### 10.3 内容指标
- 完成作品数量
- 平均章节质量评分
- AI 辅助接受度

## 11. 路线图

### Phase 1：基础功能（已完成）
- ✅ 五大核心命令实现
- ✅ 多 AI 平台支持
- ✅ 项目初始化功能
- ✅ 基础模板系统

### Phase 2：功能增强（进行中）
- 🔄 角色关系图谱
- 🔄 伏笔追踪系统
- 🔄 多线剧情管理
- 🔄 自动摘要生成

### Phase 3：生态建设（计划中）
- 📋 Web 界面开发
- 📋 云端同步功能
- 📋 社区模板市场
- 📋 协作创作支持

### Phase 4：智能升级（未来）
- 🔮 深度学习模型定制
- 🔮 个性化写作风格学习
- 🔮 智能剧情推荐
- 🔮 多语言支持

## 12. 附录

### 12.1 术语表

| 术语 | 说明 |
|------|------|
| Novel Writer | 本产品名称 |
| Spec-Kit | 参考的开发方法论框架 |
| 工作流命令 | 在 AI 助手中使用的斜杠命令 |
| CLI | 命令行界面工具 |
| 卷册 | 小说的大章节划分单位 |

### 12.2 相关链接

- GitHub 仓库：https://github.com/wordflowlab/novel-writer
- NPM 包：https://www.npmjs.com/package/novel-writer-cn
- 文档站点：（待建设）
- 社区论坛：（待建设）

### 12.3 联系方式

- 问题反馈：GitHub Issues
- 功能建议：GitHub Discussions
- 商务合作：（待定）

---

**文档版本**: v1.0
**更新日期**: 2025-09-20
**作者**: Novel Writer Team
**基于**: Spec-Kit 架构理念