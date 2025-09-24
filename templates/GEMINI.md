# Novel Writer - Gemini CLI 配置

本项目已配置为支持 Google Gemini CLI，提供完整的小说创作工具集。

## 可用命令

本项目提供以下斜杠命令：

### 核心命令
- `/method` - 智能写作方法助手
- `/story` - 创建故事大纲
- `/outline` - 规划章节结构
- `/write` - 撰写章节内容
- `/style` - 设置写作风格
- `/expert` - 激活专家模式

### 管理命令
- `/chapters` - 章节管理
- `/relations` - 人物关系管理
- `/timeline` - 时间线管理
- `/track` - 进度追踪
- `/track:init` - 初始化追踪系统

### 检查命令
- `/plot:check` - 情节逻辑检查
- `/world:check` - 世界观一致性检查

## 使用方式

在 Gemini CLI 中，直接输入命令即可：

```
> /method
> /story 一个关于冒险的奇幻故事
> /outline
> /write 第一章
```

## 工具权限

本项目已配置以下工具权限：
- 文件读写（read_file, write_file, edit_file）
- Shell 命令执行（限制范围）
- 文件搜索（glob_files）

## 项目结构

```
stories/          # 故事内容
├── [故事名]/
│   ├── story.md      # 故事大纲
│   ├── outline.md    # 章节规划
│   └── chapters/     # 章节内容

spec/             # 配置和知识库
├── tracking/     # 进度追踪
├── knowledge/    # 世界观设定
└── presets/      # 写作方法模板

.gemini/          # Gemini 配置
├── commands/     # 命令定义（TOML）
└── settings.json # Gemini 设置
```

## 写作方法

支持以下写作方法：
- 三幕结构（three-act）
- 英雄之旅（hero-journey）
- 故事圈（story-circle）
- 七点结构（seven-point）
- 皮克斯公式（pixar-formula）
- 雪花十步（snowflake）
- 混合方法（hybrid）

使用 `/method` 命令选择最适合的方法。

## 插件支持

如果安装了插件，会有额外的命令可用。查看 `plugins/` 目录了解已安装的插件。

## 注意事项

1. **首次使用**：先运行 `/method` 选择写作方法
2. **创建故事**：使用 `/story` 创建大纲
3. **规划章节**：使用 `/outline` 规划结构
4. **开始写作**：使用 `/write` 撰写内容

## 获取帮助

- 使用 `/expert` 激活专家模式获取深度指导
- 查看 `docs/` 目录获取详细文档
- 访问项目仓库：https://github.com/wordflowlab/novel-writer

---
*本项目由 Novel Writer 团队开发，专为 AI 驱动的中文小说创作设计。*