# 翻译插件 - Novel Translation Plugin

## 简介

Novel Translation Plugin 是一个专为中文小说出海设计的翻译插件。它能够将中文小说智能翻译成地道的英文，适合在 Medium、Reddit、Wattpad 等平台发布。

## 功能特色

- 🌍 **智能本地化翻译** - 不只是翻译，更是文化适配
- 📚 **保持叙事风格** - 忠实原文的同时让英文读者易懂
- 🎯 **平台优化** - 针对不同平台调整翻译风格
- 🔄 **批量处理** - 支持整部小说的批量翻译
- ✨ **专业术语处理** - 智能处理人名、地名、专有名词

## 安装方法

确保已安装 novel-writer-cn：

```bash
npm install -g novel-writer-cn
```

插件会自动随主程序安装。

## 使用方法

### 1. 基础翻译命令

```bash
# 翻译单个章节
/translate-chapter

# 批量翻译
/translate-batch

# 翻译并优化为Medium风格
/translate-medium

# 翻译并优化为Reddit风格
/translate-reddit
```

### 2. 准备工作

在使用翻译功能前，请准备：

1. **原文文件** - 支持 .txt 或 .md 格式的中文小说文件
2. **章节划分** - 建议每个章节独立成文件，便于管理
3. **人名地名表** - 可选，用于统一专有名词的翻译

### 3. 使用示例

#### 翻译单章

```bash
# 在小说项目目录下
novel translate-chapter

# 系统会提示：
# 1. 选择要翻译的章节文件
# 2. 选择目标平台（Medium/Reddit/通用）
# 3. 确认翻译设置
```

#### 批量翻译

```bash
# 翻译整部小说
novel translate-batch

# 系统会：
# 1. 扫描所有章节文件
# 2. 按顺序进行翻译
# 3. 保存到 translated/ 目录
```

### 4. 高级功能

#### 专家模式

需要深度优化时，可以启用翻译专家模式：

```bash
# 启用专家指导
/translate-expert

# 专家会提供：
# - 文化差异处理建议
# - 习语和俗语的本地化
# - 目标读者群体分析
# - SEO优化建议
```

#### 术语管理

创建 `translation-glossary.md` 文件管理专有名词：

```markdown
# 翻译术语表

## 人名
- 林天 -> Lin Tian
- 苏小小 -> Su Xiaoxiao

## 地名
- 青云山 -> Azure Cloud Mountain
- 万剑宗 -> Ten Thousand Swords Sect

## 功法/技能
- 九天雷诀 -> Nine Heavens Thunder Art
- 破天一剑 -> Sky-Breaking Sword Strike
```

### 5. 输出格式

翻译后的文件会保存在 `translated/` 目录：

```
project/
├── chapters/          # 原文章节
├── translated/        # 翻译结果
│   ├── chapter_01_en.md
│   ├── chapter_02_en.md
│   └── ...
└── translation-glossary.md  # 术语表
```

## 平台适配说明

### Medium 风格
- 简洁明快的语言
- 适合西方读者的叙事节奏
- 强调故事性和可读性

### Reddit 风格
- 更加口语化
- 保留网络小说的爽文特色
- 适当加入流行文化引用

### Wattpad 风格
- 青少年读者友好
- 情感描写细腻
- 章节末尾设置悬念

## 常见问题

### Q: 翻译速度慢怎么办？
A: 翻译质量优先，建议分批处理，每次5-10章。

### Q: 专有名词翻译不一致？
A: 使用术语表功能统一管理专有名词翻译。

### Q: 如何处理文化特有内容？
A: 启用专家模式获取本地化建议，或添加译注。

### Q: 支持其他语言吗？
A: 目前专注于中英翻译，其他语言在规划中。

## 最佳实践

1. **分章翻译** - 每次处理5-10章，便于质量控制
2. **术语先行** - 先建立术语表，确保一致性
3. **平台定制** - 根据发布平台选择合适的风格
4. **人工审核** - AI翻译后建议人工review重要章节
5. **读者反馈** - 根据海外读者反馈持续优化

## 技术说明

- 基于 Claude AI 的深度理解能力
- 上下文感知的翻译策略
- 保持原文韵味的同时适配目标语言文化

## 更新日志

### v1.0.0 (2025-09-22)
- 初版发布
- 支持中英翻译
- 四种翻译命令
- 专家模式
- 术语管理功能

## 支持

如遇到问题，请提交 Issue：
https://github.com/wordflowlab/novel-writer/issues

## 许可证

MIT License