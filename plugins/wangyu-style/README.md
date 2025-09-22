# 忘语风格创作插件

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)]()
[![Style](https://img.shields.io/badge/style-wangyu-green.svg)]()
[![Type](https://img.shields.io/badge/type-plugin-orange.svg)]()

> 深度模拟《凡人修仙传》作者忘语的写作风格，为您的仙侠小说注入纯正的网文大神基因。

## 📖 插件简介

忘语风格创作插件是 Novel Writer 的风格扩展插件，专门用于创作具有忘语特色的仙侠玄幻小说。本插件深度还原了忘语的核心创作理念：冷静客观的叙述、严谨的修仙世界观、谨慎务实的人物塑造，以及环环相扣的悬念设计。

### 核心特色

- 🌍 **严谨世界观**：八大修炼境界，四类资源体系，多元势力格局
- ✍️ **冷静叙事**：客观疏离的第三人称，精准详实的描写
- 👤 **复杂人物**：谨慎务实的主角，立体丰满的配角
- 💎 **资源意识**：强调修仙资源的稀缺性和残酷竞争
- 🎭 **悬念大师**：层层递进的伏笔，环环相扣的悬念

## 🚀 安装方法

### 通过 Novel CLI 安装

```bash
# 在现有项目中安装
novel plugins add wangyu-style

# 或在初始化新项目时包含
novel init my-xianxia-novel --plugins wangyu-style
```

### 手动安装

1. 将 `wangyu-style` 文件夹复制到项目的 `plugins` 目录
2. 重启 AI 助手以加载插件

## 📝 使用指南

### 快速开始

1. **激活风格模式**
   ```
   /wangyu-style
   ```
   激活后，所有创作命令都会应用忘语风格。

2. **开始创作**
   ```
   /wangyu-write chapter 第一章：凡人之路
   ```

3. **分析风格**
   ```
   /wangyu-analyze [你的文本]
   ```

### 命令详解

#### `/wangyu-style` - 激活风格模式

设定并激活忘语风格创作模式。

**选项**：
- `--intensity <1-10>` - 风格强度（默认8）
- `--focus <aspect>` - 重点强化某方面

**示例**：
```
/wangyu-style --intensity 10 --focus battle
```

#### `/wangyu-write` - 风格创作

使用纯正的忘语风格创作内容。

**内容类型**：
- `chapter` - 完整章节
- `opening` - 章节开头
- `battle` - 战斗场面
- `dialogue` - 人物对话
- `cultivation` - 修炼描写
- `exploration` - 探索秘境
- `scheming` - 阴谋算计
- `breakthrough` - 境界突破

**示例**：
```
/wangyu-write battle 金丹期修士生死对决
```

#### `/wangyu-analyze` - 风格分析

分析文本的忘语风格符合度。

**评分维度**：
- 世界观严谨度（1-10）
- 叙事风格（1-10）
- 人物塑造（1-10）
- 资源意识（1-10）
- 悬念设置（1-10）

**示例**：
```
/wangyu-analyze "你的文本内容"
```

#### `/wangyu-enhance` - 风格强化

将普通文本转换为忘语风格。

**强化模式**：
- `--light` - 轻度强化
- `--medium` - 中度强化（默认）
- `--heavy` - 深度强化

**示例**：
```
/wangyu-enhance "原始文本" --heavy
```

### 专家模式

激活忘语风格大师获取深度指导：

```
/expert wangyu-master
```

专家可以提供：
- 风格写作指导
- 世界观构建建议
- 人物塑造技巧
- 悬念设置方法

## 🎯 最佳实践

### 创作流程建议

1. **项目初始化**
   ```
   novel init my-novel --plugins wangyu-style
   /wangyu-style --intensity 8
   ```

2. **设定世界观**
   ```
   /story 一个凡人少年的修仙之路
   /expert wangyu-master
   [获取世界观构建指导]
   ```

3. **章节创作**
   ```
   /wangyu-write opening 主角初入修仙界
   /wangyu-write cultivation 第一次引气入体
   /wangyu-write battle 与同门切磋
   ```

4. **风格检查**
   ```
   /wangyu-analyze [章节内容]
   /wangyu-enhance [需要强化的段落] --medium
   ```

### 配合其他功能

- **伏笔管理**：配合 `/track` 命令追踪长线伏笔
- **时间线**：使用 `/timeline` 管理修炼时间跨度
- **世界观**：用 `/world-check` 确保设定一致性
- **写作方法**：可与英雄之旅等方法结合使用

## 📊 风格参数说明

插件使用以下参数控制风格输出：

| 参数 | 范围 | 说明 |
|-----|------|------|
| 叙事距离 | 1-5 | 控制叙述的客观程度 |
| 情感强度 | 1-5 | 控制情感表达的克制度 |
| 描写密度 | 1-5 | 控制细节描写的详实度 |
| 悬念等级 | 1-5 | 控制悬念和伏笔的密度 |
| 现实感 | 1-5 | 控制世界规则的严谨度 |
| 复杂度 | 1-5 | 控制情节和人物的复杂度 |

## 🌟 创作示例

### 冷静客观的叙述
```
韩立站在洞府门口，神识扫过周围百丈范围。
三息之后，他确认没有其他修士存在，这才取出阵盘。
```

### 资源稀缺的体现
```
这枚筑基丹，是他用三年时间、七次生死危机才换来的。
整个黄枫谷外门，每年也只有三枚的份额。
```

### 谨慎务实的人物
```
面对这突如其来的机缘，韩立的第一反应不是欣喜，而是警惕。
天下没有免费的午餐，越是容易得到的东西，往往隐藏着越大的危险。
```

## 🔧 配置文件

插件的核心配置存储在：
- `config.yaml` - 插件元信息
- `templates/prompts.json` - 核心提示词模板
- `experts/wangyu-master.md` - 专家指导文档

## 📚 参考资源

- 《凡人修仙传》 - 忘语代表作
- 《玄界之门》 - 忘语另一力作
- [Novel Writer 文档](https://github.com/wordflowlab/novel-writer)

## 🤝 贡献指南

欢迎提交改进建议和问题反馈：

1. 在 [GitHub Issues](https://github.com/wordflowlab/novel-writer/issues) 提交问题
2. 使用标签 `plugin:wangyu-style`
3. 详细描述问题或建议

## 📄 版本历史

### v1.0.0 (2025-09-23)
- 初始版本发布
- 实现四个核心命令
- 包含完整的忘语风格系统
- 支持专家模式

## 📜 许可证

MIT License - 自由使用和修改

---

**忘语风格创作插件** - 让您的仙侠小说具有大神风采！ 🗡️✨