# Dreams服务端集成计划

## 文档信息

- **版本**: v1.0.0
- **创建时间**: 2025-10-14
- **作者**: Novel Writer Team
- **状态**: 规划阶段

## 目录

1. [背景](#1-背景)
2. [集成目标](#2-集成目标)
3. [Dreams系统现状](#3-dreams系统现状)
4. [集成架构设计](#4-集成架构设计)
5. [Web UI设计](#5-web-ui设计)
6. [API设计](#6-api设计)
7. [Session同步机制](#7-session同步机制)
8. [分阶段实施计划](#8-分阶段实施计划)
9. [技术挑战与解决方案](#9-技术挑战与解决方案)
10. [成功指标](#10-成功指标)

---

## 1. 背景

### 1.1 当前情况

**novel-writer-cn CLI**:
- ✅ 完整的规范驱动系统（specification.md, constitution.md）
- ✅ 角色、场景、剧情追踪系统
- ✅ Slash Command写作流程（/write）
- 🚧 章节配置系统（本期新增）
- ❌ Web可视化界面

**Dreams服务端**:
- ✅ Next.js 14 全栈平台
- ✅ YAML表单系统
- ✅ Session管理机制
- ✅ tRPC类型安全API
- ✅ 作品管理、格式转换、工具市场
- ❌ 章节配置管理

### 1.2 集成价值

| 功能 | 纯CLI方案 | Dreams集成方案 | 提升价值 |
|------|-----------|----------------|----------|
| 配置创建 | 命令行交互/手写YAML | Web表单可视化填写 | ⭐⭐⭐⭐⭐ |
| 预设浏览 | `novel preset list` | 可视化卡片+预览 | ⭐⭐⭐⭐ |
| 配置管理 | 本地文件系统 | 云端存储+版本控制 | ⭐⭐⭐⭐ |
| 团队协作 | Git共享 | 云端实时同步 | ⭐⭐⭐ |
| 移动端访问 | 不支持 | 响应式Web UI | ⭐⭐⭐ |

---

## 2. 集成目标

### 2.1 短期目标（v1.0）

1. **Web配置表单**: 提供可视化的章节配置创建界面
2. **预设市场**: 展示和搜索预设模板
3. **Session同步**: 配置从Web创建后同步到CLI本地
4. **基础CRUD**: 创建、读取、更新、删除章节配置

### 2.2 长期目标（v2.0+）

1. **云端存储**: 配置文件云端备份，多设备同步
2. **版本控制**: 配置文件的版本历史和回滚
3. **团队协作**: 多人共享配置，评论和审批流程
4. **智能推荐**: 根据作品类型推荐合适的预设和配置
5. **配置模板市场**: 用户分享和售卖自定义配置模板

---

## 3. Dreams系统现状

### 3.1 YAML表单系统

Dreams已有完整的YAML表单基础设施：

```yaml
# forms/intro.yaml 示例
fields:
  - id: genre
    type: select
    label: 作品类型
    options:
      - {value: xuanhuan, label: 玄幻}
      - {value: dushi, label: 都市}
    required: true

  - id: protagonist_name
    type: text
    label: 主角姓名
    required: true

  - id: special_requirements
    type: textarea
    label: 特殊要求
    rows: 5
```

**现有能力**:
- ✅ 多种字段类型（text, textarea, select, radio, checkbox）
- ✅ 表单验证
- ✅ Session存储
- ✅ CLI集成接口

### 3.2 CLI集成机制

Dreams与CLI的集成流程：

```
Web表单填写 → Session存储 → CLI拉取 → 本地prompt → AI执行
     ↓
  (session-id)
```

现有CLI命令：
```bash
novel intro --session {session-id}   # 从Dreams拉取数据
novel write --session {session-id}    # 使用Dreams配置写作
```

### 3.3 数据库架构

Dreams使用Prisma + MySQL：

```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  books     Book[]
  sessions  Session[]
}

model Book {
  id          String    @id @default(cuid())
  title       String
  userId      String
  user        User      @relation(...)
  chapters    Chapter[]
}

model Session {
  id          String   @id @default(cuid())
  userId      String
  data        Json
  createdAt   DateTime
}
```

---

## 4. 集成架构设计

### 4.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     Dreams Web UI                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ 章节配置表单  │  │  预设市场    │  │  配置管理    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ tRPC API (类型安全)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  Dreams Backend (Next.js API)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ ChapterConfig │  │ PresetManager│  │  Session     │      │
│  │   Service     │  │   Service    │  │  Service     │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                    ┌──────────────┐                          │
│                    │   Database   │ (MySQL + Prisma)         │
│                    └──────────────┘                          │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ Session ID / API Key
                              ▼
┌─────────────────────────────────────────────────────────────┐
│               novel-writer-cn CLI                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ chapter-config│  │ write.md     │  │  本地YAML    │      │
│  │   commands    │  │  (slash cmd) │  │   存储       │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 数据流

#### 4.2.1 Web创建配置流程

```
1. 用户在Dreams Web填写章节配置表单
   ↓
2. 前端提交到 tRPC API: chapterConfig.create()
   ↓
3. 后端验证数据，存储到数据库
   ↓
4. 创建Session，返回session-id给前端
   ↓
5. 前端显示CLI命令提示：
   novel chapter-config pull --session {session-id}
   ↓
6. 用户在CLI执行命令，拉取配置到本地
   ↓
7. 本地保存为 .novel/chapters/chapter-X-config.yaml
   ↓
8. 用户执行 /write，自动加载本地配置文件
```

#### 4.2.2 CLI推送配置流程（双向同步）

```
1. 用户在CLI创建配置：
   novel chapter-config create 5 --interactive
   ↓
2. 本地保存 chapter-5-config.yaml
   ↓
3. 用户执行推送命令：
   novel chapter-config push 5
   ↓
4. CLI读取本地YAML，调用Dreams API
   ↓
5. Dreams存储到数据库，关联到用户作品
   ↓
6. 返回config-id，CLI更新本地元数据
```

### 4.3 存储策略

| 存储位置 | 数据类型 | 用途 | 同步方式 |
|----------|----------|------|----------|
| CLI本地文件 | chapter-X-config.yaml | 写作时直接读取 | 主存储 |
| Dreams数据库 | ChapterConfig记录 | 云端备份、跨设备同步 | pull/push |
| Dreams Session | 临时配置数据 | Web→CLI传递 | session-id |
| CLI元数据 | .novel/meta/sync.json | 记录同步状态 | 本地维护 |

**同步元数据示例**：
```json
{
  "chapters": {
    "5": {
      "local_path": ".novel/chapters/chapter-5-config.yaml",
      "remote_id": "cuid_abc123",
      "last_synced": "2025-10-14T10:30:00Z",
      "hash": "sha256_hash_value"
    }
  },
  "last_pull": "2025-10-14T08:00:00Z"
}
```

---

## 5. Web UI设计

### 5.1 页面结构

#### 5.1.1 章节配置创建页面

**路由**: `/app/(dashboard)/books/[bookId]/chapters/[chapterId]/config`

**布局**:
```
┌────────────────────────────────────────────────────────────┐
│ 【返回】 第5章配置 - 初露锋芒                    【保存】  │
├────────────────────────────────────────────────────────────┤
│                                                              │
│ ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│ │  基本信息    │  │  角色场景    │  │  剧情风格    │      │
│ └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                              │
│ ╔════════════════ 基本信息 ════════════════╗               │
│ ║ 章节号: [  5  ]  章节标题: [初露锋芒  ]  ║               │
│ ║                                           ║               │
│ ║ 使用预设: [选择预设 ▼]  或  [从零开始]   ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│ ╔════════════════ 出场角色 ════════════════╗               │
│ ║ [+ 添加角色]                              ║               │
│ ║                                           ║               │
│ ║ ┌─ 角色1: 林晨（主角）─────────────┐    ║               │
│ ║ │ 戏份: ● 高  ○ 中  ○ 低          │    ║               │
│ ║ │ 状态变化:                         │    ║               │
│ ║ │ • 受伤（轻伤）                    │    ║               │
│ ║ │ • 实力提升                        │    ║               │
│ ║ └───────────────────────────────────┘    ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│ ╔════════════════ 场景设置 ════════════════╗               │
│ ║ 地点: [废弃工厂 ▼]  时间: [深夜2点]     ║               │
│ ║ 天气: [大雨 ▼]                            ║               │
│ ║ 氛围: [紧张 ▼]                            ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│ ╔════════════════ 剧情类型 ════════════════╗               │
│ ║ 类型: [冲突对抗 ▼]                        ║               │
│ ║                                           ║               │
│ ║ 剧情摘要:                                  ║               │
│ ║ ┌───────────────────────────────────┐    ║               │
│ ║ │ 主角与反派首次正面交锋...         │    ║               │
│ ║ └───────────────────────────────────┘    ║               │
│ ║                                           ║               │
│ ║ 关键情节点:                                ║               │
│ ║ • 反派突然袭击                            ║               │
│ ║ • 激烈打斗                                ║               │
│ ║ [+ 添加情节点]                            ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│ ╔════════════════ 写作风格 ════════════════╗               │
│ ║ 节奏: ● 快  ○ 中  ○ 慢                  ║               │
│ ║ 句长: ● 短句  ○ 中等  ○ 长句            ║               │
│ ║ 重点: ☑ 动作  ☐ 对话  ☐ 心理  ☐ 环境   ║               │
│ ║ 基调: [严肃 ▼]                            ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│ ╔════════════════ 字数要求 ════════════════╗               │
│ ║ 目标字数: [ 3500 ]                        ║               │
│ ║ 最小字数: [ 3000 ]  最大字数: [ 4000 ]  ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│ ╔════════════════ 特殊要求 ════════════════╗               │
│ ║ ┌───────────────────────────────────┐    ║               │
│ ║ │ 动作场景写作要求：                 │    ║               │
│ ║ │ - 短句为主，单句15-25字           │    ║               │
│ ║ │ ...                                │    ║               │
│ ║ └───────────────────────────────────┘    ║               │
│ ╚═══════════════════════════════════════════╝               │
│                                                              │
│          ┌────────┐  ┌────────┐  ┌────────┐               │
│          │ 保存草稿│  │ 预览  │  │ 生成CLI│               │
│          └────────┘  └────────┘  └────────┘               │
└────────────────────────────────────────────────────────────┘
```

#### 5.1.2 预设市场页面

**路由**: `/app/(dashboard)/presets`

**布局**:
```
┌────────────────────────────────────────────────────────────┐
│ 预设模板市场                          [搜索框]  [筛选▼]    │
├────────────────────────────────────────────────────────────┤
│                                                              │
│ 分类: [全部] [动作] [对话] [情感] [悬疑] [...]             │
│                                                              │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│ │ 激烈动作场景 │  │ 对话密集场景 │  │ 情感告白场景 │         │
│ │             │  │             │  │             │         │
│ │ 适合打斗、追 │  │ 适合谈判、辩 │  │ 适合告白、和 │         │
│ │ 逐等高强度动 │  │ 论等对话为主 │  │ 解等情感重点 │         │
│ │ 作描写       │  │ 的场景       │  │ 场景         │         │
│ │             │  │             │  │             │         │
│ │ ⭐4.8 · 1.2k │  │ ⭐4.7 · 890 │  │ ⭐4.9 · 2.1k │         │
│ │ [使用预设]   │  │ [使用预设]   │  │ [使用预设]   │         │
│ └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                              │
│ ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│ │ 悬疑铺垫场景 │  │ 关系发展场景 │  │ 能力展现场景 │         │
│ │ ...          │  │ ...          │  │ ...          │         │
│ └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

点击预设卡片后，显示详情弹窗：
```
┌────────────────────────────────────────────────────────────┐
│ 激烈动作场景                                      【关闭×】 │
├────────────────────────────────────────────────────────────┤
│ 版本: v1.0.0                                                │
│ 作者: Novel Writer Official                                │
│ 分类: 场景预设                                              │
│                                                              │
│ 📝 描述:                                                     │
│ 适合打斗、追逐等高强度动作描写，快节奏、短句、密集动作      │
│                                                              │
│ ⚙️ 默认配置:                                                │
│ • 节奏: 快                                                  │
│ • 句长: 短句                                                │
│ • 重点: 动作                                                │
│ • 目标字数: 3000字                                          │
│                                                              │
│ 📚 推荐场景:                                                │
│ • 冲突对抗                                                  │
│ • 高潮对决                                                  │
│ • 追逐场景                                                  │
│                                                              │
│ 🎭 兼容类型:                                                │
│ 玄幻 · 武侠 · 都市异能 · 科幻机甲                          │
│                                                              │
│ 💡 使用提示:                                                │
│ • 适合章节的高潮部分，不宜过多使用                          │
│ • 建议配合短章节（2000-3500字）                             │
│ • 前后需要铺垫和收尾章节                                    │
│                                                              │
│          ┌────────────┐  ┌────────────┐                    │
│          │ 使用此预设  │  │ 查看示例   │                    │
│          └────────────┘  └────────────┘                    │
└────────────────────────────────────────────────────────────┘
```

#### 5.1.3 配置管理页面

**路由**: `/app/(dashboard)/books/[bookId]/configs`

**布局**:
```
┌────────────────────────────────────────────────────────────┐
│ 章节配置管理 - 《重生之都市修仙》            [新建配置+]    │
├────────────────────────────────────────────────────────────┤
│ 筛选: [全部] [已完成] [草稿] [未同步]        排序: [章节号▼]│
│                                                              │
│ ┌──────────────────────────────────────────────────────┐   │
│ │ 第5章: 初露锋芒                          [编辑] [删除] │   │
│ │ 类型: 能力展现  |  字数: 3000  |  状态: ✓ 已同步     │   │
│ │ 创建: 2025-10-14  |  最后修改: 2025-10-14 10:30       │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                              │
│ ┌──────────────────────────────────────────────────────┐   │
│ │ 第8章: 首次交锋                          [编辑] [删除] │   │
│ │ 类型: 冲突对抗  |  字数: 3500  |  状态: ⚠ 未同步     │   │
│ │ 创建: 2025-10-14  |  最后修改: 2025-10-14 15:30       │   │
│ │ [同步到CLI]                                           │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                              │
│ ┌──────────────────────────────────────────────────────┐   │
│ │ 第15章: 心意相通                         [编辑] [删除] │   │
│ │ 类型: 关系发展  |  字数: 2500  |  状态: 📝 草稿      │   │
│ │ 创建: 2025-10-14  |  最后修改: 2025-10-14 16:00       │   │
│ └──────────────────────────────────────────────────────┘   │
│                                                              │
└────────────────────────────────────────────────────────────┘
```

### 5.2 YAML表单映射

Dreams的YAML表单系统可以直接映射章节配置：

```yaml
# forms/chapter-config.yaml
form_id: chapter-config
title: 章节配置
version: 1.0.0

fields:
  # 基本信息
  - id: chapter
    type: number
    label: 章节号
    required: true
    min: 1

  - id: title
    type: text
    label: 章节标题
    required: true

  - id: preset_id
    type: select
    label: 使用预设（可选）
    options_source: api  # 从API动态加载预设列表
    endpoint: /api/presets/list

  # 角色部分
  - id: characters
    type: array
    label: 出场角色
    min_items: 1
    item_schema:
      - id: character_id
        type: select
        label: 选择角色
        options_source: api
        endpoint: /api/characters/list?bookId={bookId}

      - id: focus
        type: radio
        label: 戏份
        options:
          - {value: high, label: 高}
          - {value: medium, label: 中}
          - {value: low, label: 低}
        default: medium

      - id: state_changes
        type: array
        label: 状态变化
        item_type: text

  # 场景部分
  - id: scene.location_id
    type: select
    label: 地点
    options_source: api
    endpoint: /api/locations/list?bookId={bookId}

  - id: scene.time
    type: text
    label: 时间
    placeholder: 如：上午10点、深夜、黎明

  - id: scene.weather
    type: text
    label: 天气
    placeholder: 如：晴朗、大雨、阴天

  - id: scene.atmosphere
    type: select
    label: 氛围
    options:
      - {value: tense, label: 紧张}
      - {value: relaxed, label: 轻松}
      - {value: sad, label: 悲伤}
      - {value: exciting, label: 激动}
      - {value: mysterious, label: 神秘}

  # 剧情部分
  - id: plot.type
    type: select
    label: 剧情类型
    required: true
    options:
      - {value: ability_showcase, label: 能力展现}
      - {value: relationship_dev, label: 关系发展}
      - {value: conflict_combat, label: 冲突对抗}
      - {value: mystery_suspense, label: 悬念铺垫}
      - {value: plot_twist, label: 剧情反转}
      - {value: climax, label: 高潮对决}

  - id: plot.summary
    type: textarea
    label: 剧情摘要
    required: true
    rows: 3
    placeholder: 用一两句话概括本章主要剧情

  - id: plot.key_points
    type: array
    label: 关键情节点
    item_type: text
    min_items: 1

  # 写作风格
  - id: style.pace
    type: radio
    label: 节奏
    options:
      - {value: fast, label: 快}
      - {value: medium, label: 中}
      - {value: slow, label: 慢}
    default: medium

  - id: style.sentence_length
    type: radio
    label: 句长
    options:
      - {value: short, label: 短句}
      - {value: medium, label: 中等}
      - {value: long, label: 长句}
    default: medium

  - id: style.focus
    type: checkbox
    label: 描写重点（多选）
    options:
      - {value: action, label: 动作}
      - {value: dialogue, label: 对话}
      - {value: psychology, label: 心理}
      - {value: environment, label: 环境}
    min_selections: 1

  - id: style.tone
    type: select
    label: 基调
    options:
      - {value: light, label: 轻快}
      - {value: serious, label: 严肃}
      - {value: dark, label: 阴暗}
      - {value: humorous, label: 幽默}

  # 字数要求
  - id: wordcount.target
    type: number
    label: 目标字数
    required: true
    min: 1000
    max: 10000
    default: 3000

  - id: wordcount.min
    type: number
    label: 最小字数
    required: true
    min: 500

  - id: wordcount.max
    type: number
    label: 最大字数
    required: true
    max: 15000

  # 特殊要求
  - id: special_requirements
    type: textarea
    label: 特殊写作要求
    rows: 8
    placeholder: 详细的写作指导和注意事项

validation:
  # 自定义验证规则
  - rule: wordcount.min < wordcount.target < wordcount.max
    message: 目标字数必须在最小和最大字数之间
```

### 5.3 UI组件复用

Dreams已有的shadcn/ui组件可以直接使用：

- `<Form>` / `<FormField>` - 表单基础组件
- `<Input>` / `<Textarea>` - 输入框
- `<Select>` - 下拉选择器
- `<RadioGroup>` - 单选按钮组
- `<Checkbox>` - 复选框
- `<Button>` - 按钮
- `<Card>` - 卡片容器
- `<Dialog>` - 弹窗对话框
- `<Tabs>` - 标签页

**新增组件**:
- `<ArrayFieldEditor>` - 数组字段编辑器（用于角色列表、情节点列表）
- `<PresetSelector>` - 预设选择器（带预览功能）
- `<ConfigPreview>` - 配置预览组件（YAML格式展示）

---

## 6. API设计

### 6.1 tRPC Router: chapterConfigRouter

```typescript
// server/api/routers/chapterConfig.ts

import { z } from 'zod';
import { router, protectedProcedure } from '../trpc';

// Zod Schema（与JSON Schema对应）
const ChapterConfigSchema = z.object({
  chapter: z.number().int().min(1),
  title: z.string().min(1),
  characters: z.array(z.object({
    id: z.string(),
    name: z.string(),
    focus: z.enum(['high', 'medium', 'low']),
    state_changes: z.array(z.string()).optional(),
  })).optional(),
  scene: z.object({
    location_id: z.string().optional(),
    location_name: z.string().optional(),
    time: z.string().optional(),
    weather: z.string().optional(),
    atmosphere: z.enum([
      'tense', 'relaxed', 'sad', 'exciting',
      'mysterious', 'romantic'
    ]).optional(),
  }).optional(),
  plot: z.object({
    type: z.enum([
      'ability_showcase', 'relationship_dev', 'conflict_combat',
      'mystery_suspense', 'plot_twist', 'climax', 'transition'
    ]),
    summary: z.string(),
    key_points: z.array(z.string()),
    plotlines: z.array(z.string()).optional(),
    foreshadowing: z.array(z.object({
      id: z.string(),
      content: z.string(),
    })).optional(),
  }),
  style: z.object({
    pace: z.enum(['fast', 'medium', 'slow']),
    sentence_length: z.enum(['short', 'medium', 'long']),
    focus: z.array(z.enum([
      'action', 'dialogue', 'psychology', 'environment'
    ])),
    tone: z.enum(['light', 'serious', 'dark', 'humorous']),
  }).optional(),
  wordcount: z.object({
    target: z.number().int().min(1000).max(10000),
    min: z.number().int().min(500),
    max: z.number().int().max(15000),
  }),
  special_requirements: z.string().optional(),
  preset_used: z.string().optional(),
});

export const chapterConfigRouter = router({
  // 创建配置
  create: protectedProcedure
    .input(z.object({
      bookId: z.string(),
      config: ChapterConfigSchema,
    }))
    .mutation(async ({ ctx, input }) => {
      const { bookId, config } = input;
      const userId = ctx.session.user.id;

      // 1. 验证书籍所属
      const book = await ctx.db.book.findUnique({
        where: { id: bookId },
      });

      if (!book || book.userId !== userId) {
        throw new Error('Book not found or unauthorized');
      }

      // 2. 检查章节号冲突
      const existing = await ctx.db.chapterConfig.findUnique({
        where: {
          bookId_chapter: {
            bookId,
            chapter: config.chapter,
          },
        },
      });

      if (existing) {
        throw new Error(`Config for chapter ${config.chapter} already exists`);
      }

      // 3. 创建配置记录
      const chapterConfig = await ctx.db.chapterConfig.create({
        data: {
          bookId,
          chapter: config.chapter,
          title: config.title,
          configData: config, // JSON字段存储完整配置
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      });

      // 4. 创建Session（用于CLI拉取）
      const session = await ctx.db.session.create({
        data: {
          userId,
          type: 'chapter-config',
          data: {
            configId: chapterConfig.id,
            bookId,
            chapter: config.chapter,
            config,
          },
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24小时
        },
      });

      return {
        configId: chapterConfig.id,
        sessionId: session.id,
        cliCommand: `novel chapter-config pull --session ${session.id}`,
      };
    }),

  // 获取配置列表
  list: protectedProcedure
    .input(z.object({
      bookId: z.string(),
    }))
    .query(async ({ ctx, input }) => {
      const { bookId } = input;
      const userId = ctx.session.user.id;

      // 验证权限
      const book = await ctx.db.book.findUnique({
        where: { id: bookId },
      });

      if (!book || book.userId !== userId) {
        throw new Error('Unauthorized');
      }

      // 获取配置列表
      const configs = await ctx.db.chapterConfig.findMany({
        where: { bookId },
        orderBy: { chapter: 'asc' },
        select: {
          id: true,
          chapter: true,
          title: true,
          configData: true,
          createdAt: true,
          updatedAt: true,
          syncStatus: true,
        },
      });

      return configs.map(config => ({
        id: config.id,
        chapter: config.chapter,
        title: config.title,
        plotType: (config.configData as any).plot?.type,
        wordcount: (config.configData as any).wordcount?.target,
        syncStatus: config.syncStatus,
        createdAt: config.createdAt,
        updatedAt: config.updatedAt,
      }));
    }),

  // 获取单个配置
  get: protectedProcedure
    .input(z.object({
      configId: z.string(),
    }))
    .query(async ({ ctx, input }) => {
      const { configId } = input;
      const userId = ctx.session.user.id;

      const config = await ctx.db.chapterConfig.findUnique({
        where: { id: configId },
        include: { book: true },
      });

      if (!config || config.book.userId !== userId) {
        throw new Error('Config not found or unauthorized');
      }

      return {
        id: config.id,
        bookId: config.bookId,
        chapter: config.chapter,
        title: config.title,
        config: config.configData,
        createdAt: config.createdAt,
        updatedAt: config.updatedAt,
      };
    }),

  // 更新配置
  update: protectedProcedure
    .input(z.object({
      configId: z.string(),
      config: ChapterConfigSchema.partial(),
    }))
    .mutation(async ({ ctx, input }) => {
      const { configId, config } = input;
      const userId = ctx.session.user.id;

      // 验证权限
      const existing = await ctx.db.chapterConfig.findUnique({
        where: { id: configId },
        include: { book: true },
      });

      if (!existing || existing.book.userId !== userId) {
        throw new Error('Unauthorized');
      }

      // 合并配置
      const mergedConfig = {
        ...(existing.configData as any),
        ...config,
      };

      // 更新记录
      const updated = await ctx.db.chapterConfig.update({
        where: { id: configId },
        data: {
          configData: mergedConfig,
          updatedAt: new Date(),
          syncStatus: 'pending', // 标记为待同步
        },
      });

      return {
        configId: updated.id,
        config: updated.configData,
      };
    }),

  // 删除配置
  delete: protectedProcedure
    .input(z.object({
      configId: z.string(),
    }))
    .mutation(async ({ ctx, input }) => {
      const { configId } = input;
      const userId = ctx.session.user.id;

      // 验证权限
      const existing = await ctx.db.chapterConfig.findUnique({
        where: { id: configId },
        include: { book: true },
      });

      if (!existing || existing.book.userId !== userId) {
        throw new Error('Unauthorized');
      }

      // 删除记录
      await ctx.db.chapterConfig.delete({
        where: { id: configId },
      });

      return { success: true };
    }),

  // 从Session拉取配置（CLI调用）
  pullFromSession: protectedProcedure
    .input(z.object({
      sessionId: z.string(),
    }))
    .query(async ({ ctx, input }) => {
      const { sessionId } = input;
      const userId = ctx.session.user.id;

      // 获取Session
      const session = await ctx.db.session.findUnique({
        where: { id: sessionId },
      });

      if (!session || session.userId !== userId) {
        throw new Error('Session not found or unauthorized');
      }

      if (session.expiresAt < new Date()) {
        throw new Error('Session expired');
      }

      // 返回配置数据
      const sessionData = session.data as any;
      return {
        bookId: sessionData.bookId,
        chapter: sessionData.chapter,
        config: sessionData.config,
      };
    }),

  // 推送配置到云端（CLI调用）
  push: protectedProcedure
    .input(z.object({
      bookId: z.string(),
      chapter: z.number(),
      config: ChapterConfigSchema,
      localHash: z.string(), // 本地文件的哈希值
    }))
    .mutation(async ({ ctx, input }) => {
      const { bookId, chapter, config, localHash } = input;
      const userId = ctx.session.user.id;

      // 验证权限
      const book = await ctx.db.book.findUnique({
        where: { id: bookId },
      });

      if (!book || book.userId !== userId) {
        throw new Error('Unauthorized');
      }

      // Upsert配置
      const chapterConfig = await ctx.db.chapterConfig.upsert({
        where: {
          bookId_chapter: { bookId, chapter },
        },
        create: {
          bookId,
          chapter,
          title: config.title,
          configData: config,
          localHash,
          syncStatus: 'synced',
          createdAt: new Date(),
          updatedAt: new Date(),
        },
        update: {
          configData: config,
          localHash,
          syncStatus: 'synced',
          updatedAt: new Date(),
        },
      });

      return {
        configId: chapterConfig.id,
        remoteHash: localHash,
        syncStatus: 'synced',
      };
    }),

  // 检查同步状态（CLI调用）
  checkSyncStatus: protectedProcedure
    .input(z.object({
      bookId: z.string(),
      chapters: z.array(z.object({
        chapter: z.number(),
        localHash: z.string(),
      })),
    }))
    .query(async ({ ctx, input }) => {
      const { bookId, chapters } = input;
      const userId = ctx.session.user.id;

      // 验证权限
      const book = await ctx.db.book.findUnique({
        where: { id: bookId },
      });

      if (!book || book.userId !== userId) {
        throw new Error('Unauthorized');
      }

      // 批量查询远程配置
      const remoteConfigs = await ctx.db.chapterConfig.findMany({
        where: {
          bookId,
          chapter: { in: chapters.map(c => c.chapter) },
        },
        select: {
          chapter: true,
          localHash: true,
          updatedAt: true,
        },
      });

      // 对比哈希值
      const syncStatuses = chapters.map(local => {
        const remote = remoteConfigs.find(r => r.chapter === local.chapter);

        if (!remote) {
          return {
            chapter: local.chapter,
            status: 'not_synced',
            needsPush: true,
          };
        }

        if (remote.localHash !== local.localHash) {
          return {
            chapter: local.chapter,
            status: 'conflict',
            needsResolve: true,
            remoteUpdatedAt: remote.updatedAt,
          };
        }

        return {
          chapter: local.chapter,
          status: 'synced',
        };
      });

      return { syncStatuses };
    }),
});
```

### 6.2 Preset Router

```typescript
// server/api/routers/preset.ts

export const presetRouter = router({
  // 获取预设列表
  list: protectedProcedure
    .input(z.object({
      category: z.enum(['scene', 'style', 'genre']).optional(),
      search: z.string().optional(),
    }))
    .query(async ({ ctx, input }) => {
      const { category, search } = input;

      const presets = await ctx.db.preset.findMany({
        where: {
          ...(category && { category }),
          ...(search && {
            OR: [
              { name: { contains: search } },
              { description: { contains: search } },
            ],
          }),
        },
        orderBy: [
          { featured: 'desc' },
          { rating: 'desc' },
          { usageCount: 'desc' },
        ],
      });

      return presets;
    }),

  // 获取预设详情
  get: protectedProcedure
    .input(z.object({
      presetId: z.string(),
    }))
    .query(async ({ ctx, input }) => {
      const preset = await ctx.db.preset.findUnique({
        where: { id: input.presetId },
        include: {
          author: {
            select: {
              name: true,
              avatar: true,
            },
          },
        },
      });

      if (!preset) {
        throw new Error('Preset not found');
      }

      return preset;
    }),

  // 应用预设到配置
  applyToConfig: protectedProcedure
    .input(z.object({
      presetId: z.string(),
      baseConfig: ChapterConfigSchema.partial(),
    }))
    .mutation(async ({ ctx, input }) => {
      const { presetId, baseConfig } = input;

      // 获取预设
      const preset = await ctx.db.preset.findUnique({
        where: { id: presetId },
      });

      if (!preset) {
        throw new Error('Preset not found');
      }

      // 合并预设默认值
      const presetData = preset.configData as any;
      const mergedConfig = {
        ...baseConfig,
        style: {
          ...presetData.defaults?.style,
          ...baseConfig.style,
        },
        wordcount: {
          ...presetData.defaults?.wordcount,
          ...baseConfig.wordcount,
        },
        special_requirements: presetData.defaults?.special_requirements || '',
        preset_used: presetId,
      };

      // 增加使用次数
      await ctx.db.preset.update({
        where: { id: presetId },
        data: {
          usageCount: { increment: 1 },
        },
      });

      return { config: mergedConfig };
    }),
});
```

### 6.3 数据库Schema更新

```prisma
// prisma/schema.prisma

model ChapterConfig {
  id          String   @id @default(cuid())
  bookId      String
  chapter     Int
  title       String
  configData  Json     // 完整的章节配置JSON
  localHash   String?  // 本地文件的哈希值
  syncStatus  String   @default("not_synced") // synced, pending, conflict

  book        Book     @relation(fields: [bookId], references: [id], onDelete: Cascade)

  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  @@unique([bookId, chapter])
  @@index([bookId])
  @@map("chapter_configs")
}

model Preset {
  id              String   @id @default(cuid())
  presetId        String   @unique // 如 "action-intense"
  name            String
  description     String
  category        String   // scene, style, genre
  configData      Json     // 预设的配置数据

  authorId        String
  author          User     @relation(fields: [authorId], references: [id])

  featured        Boolean  @default(false)
  rating          Float    @default(0)
  ratingCount     Int      @default(0)
  usageCount      Int      @default(0)

  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  @@index([category])
  @@index([featured, rating])
  @@map("presets")
}

model Session {
  id          String   @id @default(cuid())
  userId      String
  type        String   // intro, chapter-config, etc.
  data        Json
  expiresAt   DateTime

  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  createdAt   DateTime @default(now())

  @@index([userId])
  @@index([expiresAt])
  @@map("sessions")
}

// 扩展已有的Book模型
model Book {
  // ... 已有字段
  chapterConfigs  ChapterConfig[]
}
```

---

## 7. Session同步机制

### 7.1 同步流程

#### 方案A: Session-based单向同步（v1.0 MVP）

**适用场景**: Web创建 → CLI使用

```
┌──────────────┐
│  Dreams Web  │
│  创建配置    │
└───────┬──────┘
        │
        │ 1. POST /api/chapterConfig/create
        ▼
┌──────────────┐
│   Backend    │
│ 存储+创建    │
│  Session     │
└───────┬──────┘
        │
        │ 2. 返回session-id
        ▼
┌──────────────┐
│  用户复制    │
│  CLI命令     │
└───────┬──────┘
        │
        │ 3. novel chapter-config pull --session {id}
        ▼
┌──────────────┐
│   CLI        │
│ GET /api/    │
│ pullFromSession
└───────┬──────┘
        │
        │ 4. 下载配置数据
        ▼
┌──────────────┐
│  本地保存    │
│  YAML文件    │
└──────────────┘
```

**优点**:
- 简单可靠
- 无需复杂的同步逻辑
- Session有过期时间，自动清理

**缺点**:
- 单向同步，不支持CLI → Web
- 需要手动复制命令

#### 方案B: Hash-based双向同步（v2.0+）

**适用场景**: CLI ↔ Web 双向同步

```
┌──────────────┐              ┌──────────────┐
│   本地CLI    │              │  Dreams Web  │
│              │              │              │
│ chapter-5-   │◀────┐        │              │
│ config.yaml  │     │        │              │
│              │     │        │              │
│ hash: abc123 │     │        │              │
└──────┬───────┘     │        └──────┬───────┘
       │             │               │
       │ 1. novel    │               │ 5. Web查看
       │ chapter-    │               │ /configs
       │ config      │               │
       │ sync        │               │
       │             │               ▼
       │             │        ┌──────────────┐
       │             │        │   Backend    │
       │             │        │              │
       │             │        │ Remote DB:   │
       │             └────────│ hash: xyz789 │
       │                      │              │
       │ 2. checkSyncStatus   │              │
       ├─────────────────────▶│              │
       │                      │              │
       │ 3. 返回状态          │              │
       │    conflict!         │              │
       │◀─────────────────────┤              │
       │                      │              │
       │ 4. 用户选择：        │              │
       │    - push（覆盖远程）│              │
       │    - pull（拉取远程）│              │
       │    - merge（合并）   │              │
       │                      │              │
       │ novel chapter-config │              │
       │ push 5 --force       │              │
       ├─────────────────────▶│              │
       │                      │ 更新hash     │
       │                      │ hash: abc123 │
       │◀─────────────────────┤              │
       │  同步成功            │              │
       │                      └──────────────┘
```

**Hash计算**:
```typescript
import crypto from 'crypto';

function calculateConfigHash(config: ChapterConfig): string {
  // 排除元数据字段（created_at, updated_at等）
  const stableConfig = {
    chapter: config.chapter,
    title: config.title,
    characters: config.characters,
    scene: config.scene,
    plot: config.plot,
    style: config.style,
    wordcount: config.wordcount,
    special_requirements: config.special_requirements,
  };

  // 排序键名，确保一致性
  const canonical = JSON.stringify(stableConfig, Object.keys(stableConfig).sort());

  // 计算SHA-256哈希
  return crypto.createHash('sha256').update(canonical).digest('hex');
}
```

**冲突解决策略**:

1. **自动解决**: 时间戳优先
   ```bash
   novel chapter-config sync --auto
   # 自动选择最新的版本
   ```

2. **手动解决**: 三向对比
   ```bash
   novel chapter-config sync 5
   # 显示冲突详情：
   # Local:  modified 2025-10-14 15:30
   # Remote: modified 2025-10-14 16:00
   #
   # 选择操作:
   #   1. 使用本地版本（覆盖远程）
   #   2. 使用远程版本（覆盖本地）
   #   3. 手动合并（打开编辑器）
   ```

3. **合并策略**: 字段级别合并
   ```typescript
   // 非冲突字段自动合并
   // 冲突字段提示用户选择
   function mergeConfigs(
     local: ChapterConfig,
     remote: ChapterConfig,
     base: ChapterConfig
   ): ChapterConfig {
     const merged = { ...base };

     for (const key of Object.keys(local)) {
       if (JSON.stringify(local[key]) === JSON.stringify(base[key])) {
         // 本地未改，使用远程
         merged[key] = remote[key];
       } else if (JSON.stringify(remote[key]) === JSON.stringify(base[key])) {
         // 远程未改，使用本地
         merged[key] = local[key];
       } else {
         // 双方都改了，记录冲突
         conflicts.push(key);
       }
     }

     return merged;
   }
   ```

### 7.2 同步命令设计

```bash
# 拉取（Web → CLI）
novel chapter-config pull --session {session-id}
novel chapter-config pull 5 --remote  # 从云端拉取第5章配置

# 推送（CLI → Web）
novel chapter-config push 5
novel chapter-config push 5 --force   # 强制覆盖远程

# 同步（双向智能同步）
novel chapter-config sync              # 同步所有配置
novel chapter-config sync 5            # 同步第5章
novel chapter-config sync --auto       # 自动解决冲突

# 检查同步状态
novel chapter-config status
# 输出示例:
# Chapter 5: ✓ Synced (last synced: 2025-10-14 10:30)
# Chapter 8: ⚠ Conflict (local: 15:30, remote: 16:00)
# Chapter 15: ↑ Not synced (local changes, need push)
```

### 7.3 CLI实现

```typescript
// src/commands/chapter-config.ts

import { Command } from 'commander';
import { ChapterConfigManager } from '../lib/chapter-config';
import { DreamsClient } from '../lib/dreams-client';

export function registerChapterConfigCommands(program: Command) {
  const chapterConfig = program
    .command('chapter-config')
    .description('管理章节配置');

  // pull命令
  chapterConfig
    .command('pull')
    .description('从Dreams拉取配置')
    .option('--session <id>', 'Session ID')
    .option('--remote', '从云端拉取')
    .argument('[chapter]', '章节号')
    .action(async (chapter, options) => {
      const manager = new ChapterConfigManager();
      const client = new DreamsClient();

      if (options.session) {
        // Session模式
        const data = await client.pullFromSession(options.session);
        const config = data.config;

        await manager.saveConfig(config);
        console.log(`✓ 配置已保存到 .novel/chapters/chapter-${config.chapter}-config.yaml`);
      } else if (options.remote && chapter) {
        // 远程拉取模式
        const bookId = await manager.getCurrentBookId();
        const config = await client.getConfig(bookId, parseInt(chapter));

        await manager.saveConfig(config);
        console.log(`✓ 第${chapter}章配置已从云端拉取`);
      } else {
        console.error('错误: 必须提供 --session 或 --remote 选项');
        process.exit(1);
      }
    });

  // push命令
  chapterConfig
    .command('push <chapter>')
    .description('推送配置到Dreams')
    .option('--force', '强制覆盖远程配置')
    .action(async (chapter, options) => {
      const manager = new ChapterConfigManager();
      const client = new DreamsClient();

      const chapterNum = parseInt(chapter);
      const config = await manager.loadConfig(chapterNum);

      if (!config) {
        console.error(`错误: 第${chapter}章配置不存在`);
        process.exit(1);
      }

      const bookId = await manager.getCurrentBookId();
      const localHash = manager.calculateHash(config);

      try {
        const result = await client.pushConfig(bookId, chapterNum, config, localHash, options.force);

        // 更新本地元数据
        await manager.updateSyncMetadata(chapterNum, {
          remote_id: result.configId,
          remote_hash: result.remoteHash,
          last_synced: new Date().toISOString(),
        });

        console.log(`✓ 第${chapter}章配置已推送到云端`);
      } catch (error) {
        if (error.message.includes('conflict')) {
          console.error('⚠ 检测到冲突，远程配置已被修改');
          console.error('使用 --force 强制覆盖，或先执行 pull 拉取远程配置');
        } else {
          throw error;
        }
      }
    });

  // sync命令
  chapterConfig
    .command('sync [chapter]')
    .description('双向同步配置')
    .option('--auto', '自动解决冲突')
    .action(async (chapter, options) => {
      const manager = new ChapterConfigManager();
      const client = new DreamsClient();

      const bookId = await manager.getCurrentBookId();

      // 获取本地配置列表
      const localConfigs = await manager.listConfigs();

      // 检查同步状态
      const statusResult = await client.checkSyncStatus(
        bookId,
        localConfigs.map(c => ({
          chapter: c.chapter,
          localHash: manager.calculateHash(c.config),
        }))
      );

      for (const status of statusResult.syncStatuses) {
        if (chapter && status.chapter !== parseInt(chapter)) {
          continue;
        }

        if (status.status === 'synced') {
          console.log(`第${status.chapter}章: ✓ 已同步`);
        } else if (status.status === 'not_synced') {
          // 需要推送
          console.log(`第${status.chapter}章: ↑ 推送到云端...`);
          await client.pushConfig(bookId, status.chapter, ...);
        } else if (status.status === 'conflict') {
          // 冲突处理
          if (options.auto) {
            // 自动选择最新的
            if (status.remoteUpdatedAt > localUpdatedAt) {
              console.log(`第${status.chapter}章: ↓ 拉取远程配置（远程更新）...`);
              await client.getConfig(bookId, status.chapter);
            } else {
              console.log(`第${status.chapter}章: ↑ 推送本地配置（本地更新）...`);
              await client.pushConfig(bookId, status.chapter, ..., true);
            }
          } else {
            console.log(`第${status.chapter}章: ⚠ 检测到冲突`);
            console.log(`  本地修改时间: ${localUpdatedAt}`);
            console.log(`  远程修改时间: ${status.remoteUpdatedAt}`);

            const answer = await inquirer.prompt([{
              type: 'list',
              name: 'action',
              message: '选择操作:',
              choices: [
                { name: '1. 使用本地版本（覆盖远程）', value: 'push' },
                { name: '2. 使用远程版本（覆盖本地）', value: 'pull' },
                { name: '3. 跳过此章节', value: 'skip' },
              ],
            }]);

            if (answer.action === 'push') {
              await client.pushConfig(bookId, status.chapter, ..., true);
            } else if (answer.action === 'pull') {
              await client.getConfig(bookId, status.chapter);
            }
          }
        }
      }

      console.log('\n✓ 同步完成');
    });

  // status命令
  chapterConfig
    .command('status')
    .description('查看同步状态')
    .action(async () => {
      const manager = new ChapterConfigManager();
      const client = new DreamsClient();

      const bookId = await manager.getCurrentBookId();
      const localConfigs = await manager.listConfigs();

      const statusResult = await client.checkSyncStatus(bookId, localConfigs.map(...));

      console.log('\n章节配置同步状态:\n');

      for (const status of statusResult.syncStatuses) {
        const icon = status.status === 'synced' ? '✓' :
                     status.status === 'not_synced' ? '↑' :
                     '⚠';

        const statusText = status.status === 'synced' ? '已同步' :
                          status.status === 'not_synced' ? '待推送' :
                          '冲突';

        console.log(`  第${status.chapter}章: ${icon} ${statusText}`);

        if (status.status === 'conflict') {
          console.log(`    远程修改时间: ${status.remoteUpdatedAt}`);
        }
      }

      console.log('');
    });
}
```

---

## 8. 分阶段实施计划

### Phase 1: 基础设施（2周）

**目标**: 完成Dreams后端基础和单向同步

**任务**:
1. 数据库Schema设计和迁移
   - 创建`ChapterConfig`表
   - 创建`Preset`表
   - 扩展`Session`表

2. tRPC API开发
   - `chapterConfigRouter`: create, list, get, update, delete, pullFromSession
   - `presetRouter`: list, get

3. CLI命令开发
   - `novel chapter-config pull --session`
   - 本地YAML文件保存

4. 测试
   - API单元测试
   - CLI集成测试

**交付物**:
- ✅ 数据库迁移文件
- ✅ tRPC Router实现
- ✅ CLI pull命令
- ✅ 测试用例

---

### Phase 2: Web UI开发（3周）

**目标**: 完成Dreams前端配置创建界面

**任务**:
1. YAML表单系统扩展
   - 创建`forms/chapter-config.yaml`
   - 支持数组字段（角色列表、情节点列表）
   - 支持动态选项（从API加载角色、地点）

2. 页面开发
   - 章节配置创建页面 (`/books/[id]/chapters/[chapter]/config`)
   - 配置列表页面 (`/books/[id]/configs`)
   - Session结果页面（显示CLI命令）

3. 组件开发
   - `<ArrayFieldEditor>` - 数组字段编辑器
   - `<ConfigPreview>` - YAML预览组件
   - `<CharacterSelector>` - 角色选择器（带搜索）

4. 测试
   - 前端单元测试
   - E2E测试

**交付物**:
- ✅ YAML表单配置
- ✅ 配置创建页面
- ✅ 配置列表页面
- ✅ UI组件库
- ✅ E2E测试

---

### Phase 3: 预设系统（2周）

**目标**: 完成预设市场和预设应用功能

**任务**:
1. 预设数据准备
   - 创建官方预设（10个）
   - 预设元数据（分类、标签、示例）
   - 数据库Seed脚本

2. 预设市场页面
   - 预设列表页面 (`/presets`)
   - 预设详情弹窗
   - 搜索和筛选功能

3. 预设应用逻辑
   - 预设应用API: `applyToConfig`
   - 前端预设选择器集成
   - 预设使用统计

4. CLI预设支持
   - `novel preset list`
   - `novel preset get <id>`
   - `novel chapter-config create --preset <id>`

**交付物**:
- ✅ 10个官方预设
- ✅ 预设市场页面
- ✅ 预设应用API
- ✅ CLI预设命令

---

### Phase 4: 双向同步（3周）

**目标**: 完成CLI → Web推送和冲突解决

**任务**:
1. Hash计算和元数据管理
   - 实现`calculateConfigHash()`
   - 本地元数据文件 `.novel/meta/sync.json`
   - 同步状态追踪

2. 推送API开发
   - `chapterConfig.push`
   - `chapterConfig.checkSyncStatus`
   - 冲突检测逻辑

3. CLI同步命令
   - `novel chapter-config push`
   - `novel chapter-config sync`
   - `novel chapter-config status`

4. 冲突解决UI
   - CLI交互式冲突解决
   - Web端冲突对比页面（可选）

5. 测试
   - 同步场景测试
   - 冲突处理测试

**交付物**:
- ✅ Hash计算模块
- ✅ 推送API
- ✅ CLI同步命令
- ✅ 冲突解决机制
- ✅ 测试用例

---

### Phase 5: 优化和增强（2周）

**目标**: 性能优化、用户体验提升

**任务**:
1. 性能优化
   - API响应时间优化
   - 前端加载优化（代码分割）
   - 数据库查询优化（索引）

2. 用户体验
   - 表单自动保存（草稿）
   - 表单验证提示优化
   - 加载状态和错误处理
   - 操作成功反馈

3. 文档和教程
   - Dreams集成文档
   - 视频教程（配置创建流程）
   - CLI命令文档

4. 监控和日志
   - API调用监控
   - 错误追踪（Sentry）
   - 同步失败告警

**交付物**:
- ✅ 性能优化报告
- ✅ UX改进清单
- ✅ 用户文档
- ✅ 监控仪表盘

---

## 9. 技术挑战与解决方案

### 9.1 挑战1: 大型表单的性能问题

**问题**: 章节配置表单字段多（20+），数组字段可能有多个元素，渲染和交互可能卡顿。

**解决方案**:
1. **表单分段加载**: 使用Tab或Accordion分段展示，只渲染可见部分
2. **虚拟滚动**: 对于数组字段（角色列表），使用虚拟滚动优化长列表
3. **防抖输入**: 文本输入使用debounce，减少重复渲染
4. **React.memo优化**: 对子组件使用memo，避免不必要的重新渲染

```typescript
// 使用React.memo优化数组项组件
const CharacterItem = React.memo(({ character, onChange }) => {
  return (
    <div>
      <Select value={character.id} onChange={...} />
      <RadioGroup value={character.focus} onChange={...} />
      {/* ... */}
    </div>
  );
});
```

### 9.2 挑战2: YAML与JSON之间的格式转换

**问题**: Dreams后端使用JSON存储，CLI使用YAML格式，需要无损转换。

**解决方案**:
1. **规范化转换**: 使用`js-yaml`库，确保双向转换一致
2. **保留注释**: YAML支持注释，JSON不支持，需要特殊处理

```typescript
import yaml from 'js-yaml';
import { preserveComments } from '../utils/yaml-comments';

export function yamlToJson(yamlString: string): ChapterConfig {
  return yaml.load(yamlString) as ChapterConfig;
}

export function jsonToYaml(config: ChapterConfig, includeComments = true): string {
  let yamlString = yaml.dump(config, {
    indent: 2,
    lineWidth: 80,
    noRefs: true,
  });

  if (includeComments) {
    yamlString = preserveComments(yamlString);
  }

  return yamlString;
}

// 保留注释功能
function preserveComments(yamlString: string): string {
  // 在关键字段后添加注释
  return yamlString
    .replace(/^chapter:/m, 'chapter: # 章节号')
    .replace(/^title:/m, 'title: # 章节标题')
    .replace(/^characters:/m, 'characters: # 出场角色')
    // ...
}
```

### 9.3 挑战3: 跨设备同步的冲突处理

**问题**: 用户在多台设备同时编辑，可能产生冲突。

**解决方案**:
1. **乐观锁**: 使用`updatedAt`时间戳和版本号
2. **三向合并**: 记录Base版本，进行三向对比
3. **字段级别冲突标记**: 只标记真正冲突的字段，非冲突字段自动合并

```typescript
interface SyncMetadata {
  chapter: number;
  local_hash: string;
  remote_hash: string;
  base_hash: string;  // 上次同步时的哈希（用于三向合并）
  last_synced: string;
}

async function sync(chapter: number) {
  const local = await manager.loadConfig(chapter);
  const remote = await client.getConfig(bookId, chapter);
  const meta = await manager.getSyncMetadata(chapter);

  const localHash = calculateHash(local);
  const remoteHash = calculateHash(remote);

  if (localHash === remoteHash) {
    return { status: 'synced' };
  }

  if (localHash === meta.base_hash) {
    // 本地未改，远程有改 → 拉取远程
    await manager.saveConfig(remote);
    return { status: 'pulled' };
  }

  if (remoteHash === meta.base_hash) {
    // 远程未改，本地有改 → 推送本地
    await client.pushConfig(bookId, chapter, local, localHash);
    return { status: 'pushed' };
  }

  // 双方都改了 → 冲突
  return { status: 'conflict', local, remote };
}
```

### 9.4 挑战4: 动态表单选项的数据加载

**问题**: 角色、地点等选项需要从作品的知识库动态加载，可能有延迟。

**解决方案**:
1. **预加载**: 页面加载时并行获取所有选项数据
2. **缓存**: 使用React Query缓存选项数据
3. **骨架屏**: 数据加载时显示骨架屏，优化感知性能

```typescript
// 使用React Query预加载所有选项
function ChapterConfigForm({ bookId }) {
  const { data: characters } = useQuery({
    queryKey: ['characters', bookId],
    queryFn: () => api.characters.list({ bookId }),
    staleTime: 5 * 60 * 1000, // 5分钟缓存
  });

  const { data: locations } = useQuery({
    queryKey: ['locations', bookId],
    queryFn: () => api.locations.list({ bookId }),
    staleTime: 5 * 60 * 1000,
  });

  if (!characters || !locations) {
    return <FormSkeleton />;
  }

  return <Form characters={characters} locations={locations} />;
}
```

### 9.5 挑战5: 预设系统的扩展性

**问题**: 预设可能越来越多，如何管理和扩展？

**解决方案**:
1. **预设分类**: 按场景、风格、类型分类
2. **标签系统**: 支持多标签，便于搜索
3. **版本管理**: 预设支持版本，用户可以选择版本
4. **用户自定义预设**: 允许用户创建和分享预设

```prisma
model Preset {
  // ...
  category    String     // scene, style, genre
  tags        String[]   // 标签数组
  version     String     @default("1.0.0")
  isOfficial  Boolean    @default(false)
  isPublic    Boolean    @default(false)

  // 支持fork和继承
  parentId    String?
  parent      Preset?    @relation("PresetFork", fields: [parentId], references: [id])
  forks       Preset[]   @relation("PresetFork")
}
```

---

## 10. 成功指标

### 10.1 功能完整性指标

- [ ] Web表单成功提交率 > 95%
- [ ] Session同步成功率 > 98%
- [ ] 配置文件YAML格式正确率 100%
- [ ] 预设应用成功率 > 99%

### 10.2 性能指标

- [ ] 配置创建页面加载时间 < 2s
- [ ] 表单提交响应时间 < 500ms
- [ ] CLI pull命令执行时间 < 3s
- [ ] CLI sync命令执行时间 < 5s（单章节）

### 10.3 用户体验指标

- [ ] 配置创建完成时间 < 5分钟（首次使用）
- [ ] 配置创建完成时间 < 2分钟（使用预设）
- [ ] 用户满意度评分 > 4.5/5
- [ ] 功能使用率 > 40%（创建配置的用户占比）

### 10.4 稳定性指标

- [ ] API错误率 < 0.5%
- [ ] CLI命令失败率 < 1%
- [ ] 同步冲突率 < 5%
- [ ] 数据丢失事件 = 0

---

## 附录A: 参考资料

### A.1 相关文档

- [章节配置系统PRD](./chapter-config-system.md)
- [技术规范](./tech-spec.md)
- [Dreams YAML表单系统](../../../other/dreams/docs/form-system-architecture.md)
- [novel-writer-cn CLI架构](../../../README.md)

### A.2 技术栈文档

- [Next.js 14 Documentation](https://nextjs.org/docs)
- [tRPC Documentation](https://trpc.io/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [shadcn/ui Components](https://ui.shadcn.com/)
- [React Hook Form](https://react-hook-form.com/)
- [js-yaml Library](https://github.com/nodeca/js-yaml)

---

## 更新日志

- **v1.0.0** (2025-10-14): 初始版本，完整的Dreams集成计划