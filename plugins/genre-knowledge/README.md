# 类型知识库插件 - Genre Knowledge Plugin

## 插件介绍

Genre Knowledge Plugin 是一个高级插件，为novel-writer提供**类型化写作知识**支持。它包含了商业网文创作中经过验证的方法论、套路和技巧，帮助你写出更符合类型特征的爆款小说。

### 核心价值

- 📚 **类型知识库** - 爽文/玄幻/都市等类型的专业写作知识
- 🎯 **方法论支持** - 五大法则、场景结构、黄金开篇等成功模式
- 🤖 **AI动态搜索** - 让Claude用Glob/Grep自己找需要的知识
- 🔧 **可选安装** - 不影响核心功能，高级用户按需安装

### 适用人群

**推荐使用**：
- ✅ 想写商业爽文、玄幻、都市等类型小说
- ✅ 希望掌握成熟的类型写作套路
- ✅ 想要AI提供更专业的类型化建议

**不需要使用**：
- ❌ 只写严肃文学或个人风格作品
- ❌ 刚入门，还在探索基础写作
- ❌ 不想增加额外的知识库复杂度

---

## 安装方法

### 前提条件

确保已安装 novel-writer-cn:

```bash
npm install -g novel-writer-cn
```

### 安装插件

在你的 novel-writer 项目根目录执行:

```bash
# 安装类型知识库插件
novel plugins:add genre-knowledge
```

安装完成后,插件文件会自动复制到项目的 `plugins/genre-knowledge/` 目录。

### 验证安装

```bash
# 查看已安装的插件
novel plugins:list

# 应该看到:
# novel-genre-knowledge (v1.0.0)
# 类型知识库插件 - 商业网文创作的类型化写作知识支持
```

### 步骤2：增强核心命令

接下来，你需要在3个核心命令文件中**手动插入**增强提示词。

---

#### 2.1 增强 `/clarify` 命令

**文件位置**：`templates/commands/clarify.md`

**找到标记**：`<!-- PLUGIN_HOOK: genre-knowledge-clarify -->`

**在该标记下方插入以下内容**：

```markdown
### 🆕 可选：类型知识增强（genre-knowledge插件）

**如果故事大纲中已明确小说类型**（如"爽文"、"玄幻"、"都市"等），你可以基于类型特点提供更精准的澄清问题。

**操作方式**：
1. 检查故事大纲中是否包含明确的类型标签（如"玄幻爽文"、"都市重生"等）
2. 如有类型标签，可以使用Glob搜索相关知识：
   ```
   使用Glob搜索: plugins/genre-knowledge/knowledge/genres/*{类型关键词}*.md
   ```
3. 快速浏览搜索到的文件，提炼出该类型的关键特征（如爽文需要明确的"极限困境"和"金手指"）
4. 在澄清问题中融入这些类型特征，帮助作者更好地定位创作方向

**示例**：
- 如果识别到"爽文"类型，可以在澄清时询问：
  - "主角的极限困境"（压抑越深，后续爽感越强）
  - "核心金手指"（信息差是期待感的来源）
  - "打脸/装逼节奏"（爽点分布密度）
```

---

#### 2.2 增强 `/plan` 命令

**文件位置**：`templates/commands/plan.md`

**找到标记**：`<!-- PLUGIN_HOOK: genre-knowledge-plan -->`

**在该标记下方插入以下内容**：

```markdown
### 🆕 可选：动态加载类型知识（genre-knowledge插件）

**如果`plugins/genre-knowledge/`目录存在**，你可以动态搜索并应用类型化写作知识。

#### 知识搜索策略

**步骤1：识别故事类型**
- 从`story.md`中提取类型标签（如"玄幻"、"爽文"、"都市重生"等）
- 如无明确标签，根据故事内容（金手指、世界观、冲突类型）推断

**步骤2：搜索相关知识**

使用Glob搜索知识文件（按优先级）：

1. **通用方法论**（所有类型适用）：
   ```
   plugins/genre-knowledge/knowledge/fundamentals/*.md
   ```
   推荐优先阅读：
   - `emotion-value-core-laws.md` - 五大商业创作法则
   - `scene-mru-structure.md` - MRU场景结构（目标-冲突-决定）

2. **类型专属知识**（根据识别的类型）：
   ```
   plugins/genre-knowledge/knowledge/genres/*{类型关键词}*.md
   ```
   示例：
   - 爽文类型：搜索 `*shuangwen*.md`
   - 玄幻类型：搜索 `*xuanhuan*.md`
   - 都市类型：搜索 `*urban*.md`

**步骤3：知识应用原则**

- 🎯 **优先级**：`类型专属知识 > 通用方法论 > 通用规范`
- 📖 **选择性应用**：快速浏览文件，提取与当前章节规划相关的知识点
- ⚠️ **不要全盘照搬**：知识文件是参考，需结合具体故事情况灵活应用
- 🔍 **按需搜索**：不要一次性加载所有知识，只在需要时搜索相关内容

#### 应用示例

**场景**：规划一部"都市重生爽文"的开篇3章

**搜索知识**：
```
Glob: plugins/genre-knowledge/knowledge/fundamentals/emotion-value-core-laws.md
Glob: plugins/genre-knowledge/knowledge/genres/shuangwen-golden-opening.md
```

**提取要点**：
- 从五大法则中应用"极限铺垫原则"（开篇构建困境）
- 从黄金开篇中应用"动态场景切入"和"核心冲突前置"

**规划应用**：
- 第1章：动态场景切入重生瞬间，立刻展现主角困境
- 第2章：简要揭示重生金手指（核心信息差）
- 第3章：完成第一个小逆袭（打脸爽点）

#### 注意事项

- ⚠️ 知识文件基于商业网文创作经验，不适合所有类型
- ⚠️ 不要让知识约束创意，保持故事的独特性
- ⚠️ 如果故事不属于商业类型文，可以跳过此部分
```

---

#### 2.3 增强 `/write` 命令（可选）

**文件位置**：`templates/commands/write.md`

**找到标记**：`<!-- PLUGIN_HOOK: genre-knowledge-write -->`

**在该标记下方插入以下内容**（如果你想在写作时也应用类型知识）：

```markdown
### 🆕 可选：类型风格应用（genre-knowledge插件）

**在写作具体章节时**，可以参考类型知识中的风格指导。

**快速搜索**：
```
Glob: plugins/genre-knowledge/knowledge/genres/*{类型}*pattern*.md
Glob: plugins/genre-knowledge/knowledge/fundamentals/*structure*.md
```

**应用场景**：
- 写打脸场景时，参考`shuangwen-faceslap-pattern.md`的五步递进法
- 写关键转折时，参考`scene-mru-structure.md`的MRU结构

**注意**：不要让模式束缚文笔，保持语言的自然流畅。
```

---

### 步骤3：验证安装

完成上述步骤后，验证插件是否生效：

**方法1：查看文件**
```bash
cat templates/commands/plan.md | grep "genre-knowledge"
```
如果输出包含"动态加载类型知识"相关内容，说明安装成功。

**方法2：测试命令**
在novel项目中运行：
```bash
novel clarify
```
观察AI是否在识别到类型后提供更精准的澄清问题。

---

## 卸载方法

### 移除插件

```bash
# 卸载插件
novel plugins:remove genre-knowledge
```

### 移除核心命令中的增强提示词

如果之前手动添加了增强提示词,需要手动删除:

打开以下文件,删除之前插入的增强内容:
- `templates/commands/clarify.md`
- `templates/commands/plan.md`
- `templates/commands/write.md`

**提示**: 搜索关键词 `genre-knowledge` 快速定位要删除的内容。

### 验证卸载

```bash
# 检查插件列表
novel plugins:list

# 检查命令文件
grep "genre-knowledge" templates/commands/plan.md
```

如果插件列表中没有 genre-knowledge,且 grep 无输出,说明卸载成功。

---

## 知识库内容

### 通用方法论（fundamentals/）

| 文件名 | 内容 | 适用场景 |
|--------|------|----------|
| `emotion-value-core-laws.md` | 商业网文创作五大法则 | 所有商业类型小说 |
| `scene-mru-structure.md` | MRU场景结构 | 章节场景规划 |

### 类型专属知识（genres/）

#### 核心类型指导文件（已迁移自spec/knowledge/genres/）

| 文件名 | 内容 | 行数 | 适用场景 |
|--------|------|------|----------|
| `shuangwen.md` | 爽文类型综合指导 | 236行 | 爽文创作全流程 |
| `fantasy.md` | 奇幻/玄幻类型指导 | 669行 | 玄幻小说创作 |
| `scifi.md` | 科幻类型指导 | 530行 | 科幻小说创作 |
| `romance.md` | 言情类型指导 | 378行 | 言情小说创作 |
| `mystery.md` | 悬疑推理类型指导 | 353行 | 悬疑小说创作 |

#### 专项深度知识文件

| 文件名 | 内容 | 行数 | 适用场景 |
|--------|------|------|----------|
| `shuangwen-golden-opening.md` | 爽文黄金开篇五法则 | 428行 | 爽文开篇设计 |
| `shuangwen-faceslap-pattern.md` | 装逼打脸五步递进法 | 573行 | 打脸爽点设计 |

#### 文件关系说明

**shuangwen相关文件**：
- `shuangwen.md` - 基础全面指导（必读）
- `shuangwen-golden-opening.md` - 开篇专项深度（进阶）
- `shuangwen-faceslap-pattern.md` - 打脸专项深度（进阶）

这三个文件是**补充关系**：基础文件提供全局视角，专项文件提供深度技巧。

### 扩展知识（持续更新）

你可以根据需要添加更多知识文件：
- 将新知识文件放入对应目录（`fundamentals/` 或 `genres/`）
- 使用自然语言命名（如`xuanhuan-power-system.md`、`urban-business-war.md`）
- AI会通过Glob自动发现新知识

---

## 使用技巧

### 最佳实践

1. **渐进式安装** - 先只增强`/plan`命令，熟悉后再增强其他命令
2. **选择性应用** - 不是每个故事都需要所有知识，按需搜索
3. **保持创意** - 知识是工具，不是束缚，保持故事的独特性

### 常见问题

**Q: 安装后AI没有应用知识？**
A: 检查插入的提示词是否完整，确保`plugins/genre-knowledge/`目录存在。

**Q: 知识文件太多会影响性能吗？**
A: 不会。AI是按需搜索，不会一次性加载所有文件。

**Q: 可以自定义知识文件吗？**
A: 可以！参照现有文件格式，创建自己的知识文件即可。

**Q: 适合写严肃文学吗？**
A: 不适合。本插件主要面向商业类型小说。

---

## 进阶功能

### 自定义知识提取

如果你有其他优秀作品的创作资料，可以使用`/extract-knowledge`命令提取知识：

```bash
# 运行提取命令（需手动实现）
novel run plugins/genre-knowledge/commands/extract-knowledge.md
```

按照提示，从文档中提取结构化知识并保存到知识库。

---

## 技术原理

### LLM动态搜索

本插件采用"提示即代码"理念，不预定义硬编码路由，而是：
1. 在提示词中告诉AI知识库的组织方式
2. AI根据当前任务用Glob/Grep动态搜索
3. 选择性读取相关知识文件
4. 将知识应用到具体创作任务中

### 扁平化知识库

知识文件采用扁平化目录+自然语言命名：
- ✅ 易于搜索：`*shuangwen*.md`
- ✅ 易于扩展：直接添加新文件
- ✅ 易于理解：文件名即内容说明
- ❌ 不使用复杂层次和JSON元数据

---

## 更新日志

### v1.0.0 (初版)

- ✅ 基础知识库（4个核心文件）
- ✅ 手动安装方式
- ✅ 3个核心命令的增强提示词
- ✅ LLM动态搜索支持

---

## 贡献指南

欢迎贡献新的类型知识！

### 贡献流程

1. 在`knowledge/genres/`目录创建新文件
2. 使用自然语言命名（如`xuanhuan-cultivation-system.md`）
3. 参照现有文件格式编写内容
4. 提交PR到主仓库

### 知识文件格式建议

```markdown
# {知识主题}

> 适用类型：{小说类型}
> 适用场景：{创作阶段}

## 核心要点

{3-5个核心知识点}

## 应用示例

{具体例子}

## 注意事项

{使用限制和建议}
```

---

## 支持

如遇问题或有建议，请提交 Issue：
https://github.com/wordflowlab/novel-writer/issues

---

## 许可证

MIT License
