### 🆕 可选:动态加载类型知识(genre-knowledge插件)

**如果`plugins/genre-knowledge/`目录存在**,你可以动态搜索并应用类型化写作知识。

#### 知识搜索策略

**步骤1:识别故事类型**
- 从`story.md`中提取类型标签(如"玄幻"、"爽文"、"都市重生"等)
- 如无明确标签,根据故事内容(金手指、世界观、冲突类型)推断

**步骤2:搜索相关知识**

使用Glob搜索知识文件(按优先级):

1. **通用方法论**(所有类型适用):
   ```
   plugins/genre-knowledge/knowledge/fundamentals/*.md
   ```
   推荐优先阅读:
   - `emotion-value-core-laws.md` - 五大商业创作法则
   - `scene-mru-structure.md` - MRU场景结构(目标-冲突-决定)

2. **类型专属知识**(根据识别的类型):
   ```
   plugins/genre-knowledge/knowledge/genres/*{类型关键词}*.md
   ```
   示例:
   - 爽文类型:搜索 `*shuangwen*.md`
   - 玄幻类型:搜索 `*xuanhuan*.md`
   - 都市类型:搜索 `*urban*.md`

**步骤3:知识应用原则**

- 🎯 **优先级**:`类型专属知识 > 通用方法论 > 通用规范`
- 📖 **选择性应用**:快速浏览文件,提取与当前章节规划相关的知识点
- ⚠️ **不要全盘照搬**:知识文件是参考,需结合具体故事情况灵活应用
- 🔍 **按需搜索**:不要一次性加载所有知识,只在需要时搜索相关内容

#### 应用示例

**场景**:规划一部"都市重生爽文"的开篇3章

**搜索知识**:
```
Glob: plugins/genre-knowledge/knowledge/fundamentals/emotion-value-core-laws.md
Glob: plugins/genre-knowledge/knowledge/genres/shuangwen-golden-opening.md
```

**提取要点**:
- 从五大法则中应用"极限铺垫原则"(开篇构建困境)
- 从黄金开篇中应用"动态场景切入"和"核心冲突前置"

**规划应用**:
- 第1章:动态场景切入重生瞬间,立刻展现主角困境
- 第2章:简要揭示重生金手指(核心信息差)
- 第3章:完成第一个小逆袭(打脸爽点)

#### 注意事项

- ⚠️ 知识文件基于商业网文创作经验,不适合所有类型
- ⚠️ 不要让知识约束创意,保持故事的独特性
- ⚠️ 如果故事不属于商业类型文,可以跳过此部分
