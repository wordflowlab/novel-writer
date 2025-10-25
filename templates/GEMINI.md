# Novel Writer - Gemini CLI 配置

本项目已配置为支持 Google Gemini CLI，提供基于七步方法论的完整小说创作体系。

## 🎯 v0.10.0 七步方法论

Novel Writer 采用规格驱动开发（SDD）理念，通过系统化的七步流程创作小说。

## ⚠️ 重要：Gemini CLI 命令格式

**Gemini CLI 使用命名空间前缀** `novel:`，所有命令格式为：

```bash
/novel:命令名 [参数]
```

**原因说明**：
- Novel Writer 使用 `novel:` 命名空间避免与其他工具（如 spec-kit、OpenSpec）的命令冲突
- Gemini CLI 的子目录会自动转换为冒号命名空间（路径：`.gemini/commands/novel/write.toml` → 命令：`/novel:write`）

> 📖 **详细命令对照**：查看 [docs/ai-platform-commands.md](../docs/ai-platform-commands.md) 了解所有 AI 平台的命令格式差异

### 七步方法论命令

1. **`/novel:constitution`** - 创作宪法（定义核心原则）
2. **`/novel:specify`** - 故事规格（明确要创造什么）
3. **`/novel:clarify`** - 澄清决策（交互式明确模糊点）
4. **`/novel:plan`** - 创作计划（制定技术方案）
5. **`/novel:tasks`** - 任务分解（生成可执行清单）
6. **`/novel:write`** - 章节写作（执行内容创作）
7. **`/novel:analyze`** - 综合验证（全方位质量检查）

### 追踪管理命令

- `/novel:plot-check` - 情节逻辑检查
- `/novel:world-check` - 世界观一致性检查
- `/novel:timeline` - 时间线管理
- `/novel:relations` - 人物关系管理
- `/novel:track` - 综合进度追踪
- `/novel:track-init` - 初始化追踪系统

### 专家模式命令

- `/novel:expert` - 激活专家模式获取深度指导

## 使用方式

### 推荐工作流（七步方法论）

在 Gemini CLI 中按照以下顺序使用（**注意 `novel:` 前缀**）：

```bash
# 1. 建立创作原则
> /novel:constitution

# 2. 定义故事规格
> /novel:specify 一个关于冒险的奇幻故事

# 3. 澄清关键决策
> /novel:clarify

# 4. 制定创作计划
> /novel:plan

# 5. 生成任务清单
> /novel:tasks

# 6. 开始写作
> /novel:write 第一章

# 7. 验证质量
> /novel:analyze
```

## 工具权限

本项目已配置以下工具权限：
- 文件读写（read_file, write_file, edit_file）
- Shell 命令执行（限制范围）
- 文件搜索（glob_files）

## 项目结构

```
memory/           # 创作记忆（v0.10.0 新增）
└── novel-constitution.md  # 创作宪法

stories/          # 故事内容
├── [故事名]/
│   ├── specification.md   # 故事规格（替代 story.md）
│   ├── clarification.md   # 澄清记录（v0.10.0 新增）
│   ├── creative-plan.md   # 创作计划（替代 outline.md）
│   ├── tasks.md           # 任务清单（v0.10.0 新增）
│   ├── analysis-report.md # 分析报告（v0.10.0 新增）
│   └── content/           # 章节内容（替代 chapters/）

spec/             # 配置和知识库
├── tracking/     # 进度追踪
├── knowledge/    # 世界观设定
└── presets/      # 写作方法模板

.gemini/          # Gemini 配置
├── commands/     # 命令定义（TOML）
└── settings.json # Gemini 设置
```

## 方法论核心理念

**规格驱动创作**：不再依赖灵感和随机性，而是通过精确的规格定义来驱动内容生成。

- **宪法级约束**：创作原则是不可违背的最高准则
- **规格即需求**：像产品经理写 PRD 一样定义故事
- **计划即路径**：技术方案决定如何实现规格
- **任务即执行**：可追踪、可验证的执行单元
- **持续验证**：每个阶段都进行质量检查

## 插件支持

如果安装了插件，会有额外的命令可用。查看 `plugins/` 目录了解已安装的插件。

## 注意事项

1. **遵循七步流程**：按照方法论顺序执行，不要跳步
2. **先定义后执行**：先完成规格定义，再开始写作
3. **持续验证**：每 5 章运行一次 `/analyze` 检查质量
4. **迭代优化**：根据分析结果调整规格和计划

## 获取帮助

- 使用 `/expert` 激活专家模式获取深度指导
- 查看 `docs/` 目录获取详细文档
- 访问项目仓库：https://github.com/wordflowlab/novel-writer

## 已知问题与解决方案

### 中文乱码问题
Gemini CLI 可能偶尔输出个别中文乱码（显示为 � 或其他乱码），这是 Gemini 的已知编码问题。

#### 预防措施
1. **终端设置**
   - Windows：使用 Windows Terminal 或 PowerShell（避免使用 cmd）
   - Mac/Linux：确保终端支持 UTF-8

2. **环境变量设置**
   ```bash
   # Windows PowerShell
   [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

   # Mac/Linux
   export LANG=zh_CN.UTF-8
   export LC_ALL=zh_CN.UTF-8
   ```

#### 出现乱码时的解决方法
1. **重新生成**：重新运行相同的命令，通常第二次会正常
2. **手动修复**：直接编辑生成的文件，将乱码字符替换为正确的中文
3. **分段处理**：如果某一节出现乱码，只重新生成该节即可

#### 常见乱码模式
- `�` → 通常是"的"、"了"等常用字
- `\u4e2d\u6587` → Unicode 转义，需转换回中文
- 部分标点符号显示异常 → 手动替换为中文标点

#### 临时解决方案
如果乱码频繁出现，可以：
1. 生成较短的段落（减少单次输出）
2. 使用标准模式而非分节模式
3. 生成后立即检查并修复

注：Google 正在修复此问题，后续版本应会改善。

---
*本项目由 Novel Writer 团队开发，专为 AI 驱动的中文小说创作设计。*