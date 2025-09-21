# Novel Writer API 文档

## 概述

Novel Writer 提供了一套完整的 API 用于 AI 驱动的小说创作。API 支持多种 AI 模型提供商，包括 OpenAI、Claude、Gemini 和国内的通义千问、文心一言等。

## 认证

### API Key 配置

```bash
# 环境变量设置
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export GEMINI_API_KEY="..."
export QWEN_API_KEY="..."
```

### 配置文件

```json
{
  "providers": {
    "openai": {
      "api_key": "sk-...",
      "base_url": "https://api.openai.com/v1"
    },
    "claude": {
      "api_key": "sk-ant-...",
      "base_url": "https://api.anthropic.com"
    }
  }
}
```

## CLI 命令

### 1. style - 风格定义

定义小说的整体风格和基调。

```bash
novel style <project-name> [options]
```

**参数：**
- `project-name`: 项目名称
- `--genre`: 小说类型（fantasy/scifi/romance/mystery/horror）
- `--tone`: 叙述基调（serious/humorous/dark/light/neutral）
- `--ai`: AI 提供商（openai/claude/gemini/qwen）
- `--model`: 具体模型（gpt-4/claude-3/gemini-pro）

**示例：**
```bash
novel style my-fantasy-novel --genre fantasy --tone serious --ai claude
```

**输出：**
```yaml
# specs/001-my-fantasy-novel/style.yaml
genre: fantasy
tone: serious
narrative_voice: third-person omniscient
themes:
  - hero's journey
  - good vs evil
  - redemption
atmosphere: epic and mystical
language_style: formal with archaic elements
```

### 2. story - 故事梗概

生成故事的核心梗概和主要情节点。

```bash
novel story <project-name> [options]
```

**参数：**
- `--plot`: 情节类型（adventure/mystery/romance/thriller）
- `--conflict`: 冲突类型（person-vs-person/person-vs-nature/person-vs-self）
- `--setting`: 故事背景
- `--era`: 时代背景

**示例：**
```bash
novel story my-fantasy-novel --plot adventure --conflict person-vs-evil --setting "magical kingdom" --era medieval
```

**输出：**
```markdown
# specs/001-my-fantasy-novel/story.md

## 一句话梗概
一个普通农家少年意外获得古老魔法，踏上拯救王国的冒险之旅。

## 核心冲突
主角必须在掌握强大力量和保持内心纯洁之间找到平衡。

## 故事主线
1. 起因：村庄遭受神秘袭击
2. 发展：发现自己的魔法天赋
3. 转折：导师的背叛
4. 高潮：最终对决
5. 结局：新的平衡
```

### 3. outline - 章节大纲

生成详细的章节大纲。

```bash
novel outline <project-name> [options]
```

**参数：**
- `--chapters`: 章节数量（默认 20）
- `--words-per-chapter`: 每章字数（默认 3000）
- `--structure`: 结构类型（linear/parallel/circular）
- `--pov`: 视角（first/third-limited/third-omniscient）

**示例：**
```bash
novel outline my-fantasy-novel --chapters 25 --words-per-chapter 4000 --pov third-limited
```

**输出：**
```markdown
# specs/001-my-fantasy-novel/outline.md

## 第一章：平静的清晨
- 场景：小村庄的日常
- 人物：介绍主角和家人
- 事件：神秘的预兆
- 字数：4000字

## 第二章：不速之客
- 场景：村庄广场
- 人物：引入神秘旅者
- 事件：第一次魔法觉醒
- 字数：4000字

[...]
```

### 4. characters - 人物设定

创建详细的人物设定。

```bash
novel characters <project-name> [options]
```

**参数：**
- `--main`: 主要角色数量
- `--supporting`: 配角数量
- `--depth`: 设定深度（basic/detailed/comprehensive）

**示例：**
```bash
novel characters my-fantasy-novel --main 3 --supporting 5 --depth detailed
```

**输出：**
```yaml
# specs/001-my-fantasy-novel/characters.yaml
main_characters:
  - name: 艾登·黎明之子
    age: 17
    appearance:
      height: 中等身高
      hair: 棕色卷发
      eyes: 深蓝色，魔法觉醒时会发光
    personality:
      traits: [勇敢, 善良, 冲动]
      fears: [失去家人, 力量失控]
      motivations: [保护村庄, 寻找真相]
    background:
      family: 农民家庭，父母健在
      education: 村庄私塾
      skills: [剑术初级, 魔法天赋]
    arc: 从懵懂少年成长为责任担当者
```

### 5. write - 章节写作

生成具体的章节内容。

```bash
novel write <project-name> <chapter> [options]
```

**参数：**
- `chapter`: 章节标识（chapter-1, chapter-2...）
- `--style-check`: 检查风格一致性
- `--continue`: 从上次中断处继续
- `--words`: 目标字数

**示例：**
```bash
novel write my-fantasy-novel chapter-1 --words 4000 --style-check
```

**输出：**
```markdown
# 第一章：平静的清晨

晨雾笼罩着艾尔村，如同一层薄纱轻柔地覆盖在这个宁静的山谷中。艾登站在自家农舍的门口，深吸一口带着青草香味的空气。今天本该是个平常的日子，他要去田里帮父亲收割最后一批麦子。

然而，天边那抹不寻常的红光让他心中涌起一丝不安...

[继续 4000 字内容]
```

## Python API

### 基础用法

```python
from novel_writer import NovelWriter

# 初始化
writer = NovelWriter(
    ai_provider="claude",
    api_key="sk-ant-..."
)

# 创建项目
project = writer.create_project(
    name="my-novel",
    genre="fantasy",
    language="zh-CN"
)

# 生成风格
style = writer.define_style(
    project=project,
    tone="epic",
    themes=["heroism", "sacrifice"]
)

# 生成故事
story = writer.create_story(
    project=project,
    plot_type="hero_journey",
    setting="medieval_fantasy"
)

# 生成大纲
outline = writer.generate_outline(
    project=project,
    chapters=20,
    words_per_chapter=3000
)

# 写作章节
chapter = writer.write_chapter(
    project=project,
    chapter_number=1,
    outline=outline,
    style=style
)
```

### 高级功能

```python
# 批量生成
chapters = writer.batch_write(
    project=project,
    chapter_range=(1, 5),
    parallel=True
)

# 风格检查
consistency = writer.check_consistency(
    chapters=chapters,
    style=style
)

# 修订建议
revisions = writer.suggest_revisions(
    chapter=chapter,
    focus=["dialogue", "pacing"]
)

# 导出
writer.export(
    project=project,
    format="markdown",  # or "docx", "epub"
    output_path="./output"
)
```

## REST API

### 基础端点

```http
POST /api/v1/projects
Content-Type: application/json
Authorization: Bearer {api_key}

{
  "name": "my-novel",
  "genre": "fantasy",
  "language": "zh-CN"
}
```

### 生成风格

```http
POST /api/v1/projects/{project_id}/style
Content-Type: application/json

{
  "tone": "epic",
  "themes": ["heroism", "sacrifice"],
  "narrative_voice": "third_person"
}
```

### 写作章节

```http
POST /api/v1/projects/{project_id}/chapters
Content-Type: application/json

{
  "chapter_number": 1,
  "target_words": 3000,
  "continue_from": null
}
```

### WebSocket 实时生成

```javascript
const ws = new WebSocket('wss://api.novel-writer.com/v1/stream');

ws.send(JSON.stringify({
  action: 'write',
  project_id: 'my-novel',
  chapter: 1,
  streaming: true
}));

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Generated text:', data.text);
};
```

## 错误处理

### 错误代码

| 代码 | 说明 | 处理建议 |
|------|------|----------|
| 400 | 参数错误 | 检查请求参数 |
| 401 | 认证失败 | 验证 API Key |
| 403 | 权限不足 | 检查账户权限 |
| 404 | 资源不存在 | 验证项目 ID |
| 429 | 速率限制 | 等待后重试 |
| 500 | 服务器错误 | 联系支持 |

### 错误响应格式

```json
{
  "error": {
    "code": "invalid_parameter",
    "message": "章节数量必须在 1-100 之间",
    "field": "chapters",
    "request_id": "req_123456"
  }
}
```

## 速率限制

| 计划 | 请求/分钟 | 并发数 | 字符/月 |
|------|-----------|--------|---------|
| 免费 | 10 | 1 | 100,000 |
| 基础 | 60 | 3 | 1,000,000 |
| 专业 | 300 | 10 | 10,000,000 |
| 企业 | 自定义 | 自定义 | 无限制 |

## Webhook

### 配置 Webhook

```json
{
  "url": "https://your-server.com/webhook",
  "events": ["chapter.completed", "project.finished"],
  "secret": "webhook_secret_key"
}
```

### 事件类型

- `project.created` - 项目创建
- `style.defined` - 风格定义完成
- `outline.generated` - 大纲生成完成
- `chapter.started` - 章节开始写作
- `chapter.completed` - 章节完成
- `project.finished` - 项目完成

### 事件负载

```json
{
  "event": "chapter.completed",
  "timestamp": "2024-01-01T10:00:00Z",
  "data": {
    "project_id": "my-novel",
    "chapter": 1,
    "word_count": 3000,
    "generation_time": 45.2
  }
}
```

## SDK

### JavaScript/TypeScript

```bash
npm install @novel-writer/sdk
```

```typescript
import { NovelWriter } from '@novel-writer/sdk';

const writer = new NovelWriter({
  apiKey: process.env.NOVEL_WRITER_API_KEY,
  provider: 'claude'
});

async function createNovel() {
  const project = await writer.createProject({
    name: 'my-novel',
    genre: 'fantasy'
  });

  const chapter = await writer.writeChapter(project.id, 1);
  console.log(chapter.content);
}
```

### Python

```bash
pip install novel-writer-sdk
```

```python
from novel_writer_sdk import NovelWriter

writer = NovelWriter(
    api_key=os.getenv('NOVEL_WRITER_API_KEY'),
    provider='claude'
)

project = writer.create_project(
    name='my-novel',
    genre='fantasy'
)

chapter = writer.write_chapter(project.id, 1)
print(chapter.content)
```

## 最佳实践

### 1. 分阶段生成

不要一次性生成整部小说，按以下顺序逐步生成：

1. 风格定义
2. 故事梗概
3. 人物设定
4. 章节大纲
5. 逐章写作

### 2. 使用缓存

利用项目 ID 和章节号进行缓存：

```python
cache_key = f"{project_id}:chapter:{chapter_num}"
if cached := cache.get(cache_key):
    return cached
```

### 3. 错误重试

实现指数退避重试：

```python
import time

def retry_with_backoff(func, max_retries=3):
    for i in range(max_retries):
        try:
            return func()
        except RateLimitError:
            time.sleep(2 ** i)
    raise Exception("Max retries exceeded")
```

### 4. 批处理

批量处理多个章节以提高效率：

```python
chapters = writer.batch_write(
    chapter_range=(1, 10),
    parallel=True,
    max_workers=3
)
```

## 相关资源

- [API Playground](https://playground.novel-writer.com)
- [SDK 文档](https://sdk-docs.novel-writer.com)
- [示例项目](https://github.com/novel-writer/examples)
- [社区论坛](https://community.novel-writer.com)
- [状态页面](https://status.novel-writer.com)

---

📚 **注意**：本 API 文档持续更新中。最新版本请访问 [在线文档](https://docs.novel-writer.com/api)。