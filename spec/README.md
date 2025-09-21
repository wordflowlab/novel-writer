# Novel Writer 方法论系统

## 概述

Novel Writer 现已升级为**可插拔的方法论平台**，支持多种经典写作方法，让你可以根据作品需求灵活选择最合适的创作框架。

## 目录结构

```
spec/
├── config.json         # 主配置文件
├── presets/           # 写作方法预设
│   ├── three-act/     # 三幕结构
│   ├── hero-journey/  # 英雄之旅
│   ├── story-circle/  # 故事圈
│   ├── seven-point/   # 七点结构
│   └── pixar-formula/ # 皮克斯公式
├── tracking/          # 进度追踪
│   └── plot-tracker.json
└── knowledge/         # 知识库
    └── writing-methods-guide.md
```

## 快速开始

### 1. 选择方法论

初始化项目时选择：
```bash
novel init my-story --method hero-journey
```

或在现有项目中切换：
```bash
novel method switch hero-journey
```

### 2. 查看可用方法

```bash
novel method list
```

输出：
- `three-act` - 三幕结构（默认）
- `hero-journey` - 英雄之旅
- `story-circle` - 故事圈
- `seven-point` - 七点结构
- `pixar` - 皮克斯公式

### 3. 使用方法模板

在 AI 助手中使用 `/story` 命令时，系统会自动加载当前方法的模板。

## 方法对比

| 方法 | 适合类型 | 复杂度 | 特点 |
|------|----------|--------|------|
| 三幕结构 | 通用 | ★★☆ | 经典、灵活 |
| 英雄之旅 | 奇幻/冒险 | ★★★ | 深度成长 |
| 故事圈 | 角色驱动 | ★★☆ | 循环结构 |
| 七点结构 | 悬疑/惊悚 | ★★☆ | 节奏紧凑 |
| 皮克斯公式 | 简单故事 | ★☆☆ | 易于上手 |

## 详细文档

- 方法论完全指南：[knowledge/writing-methods-guide.md](knowledge/writing-methods-guide.md)
- 各方法配置文件：`presets/[方法名]/config.yaml`

## 自定义预设

如需创建自定义方法：
1. 在 `presets/` 下创建新目录
2. 添加 `config.yaml`、`story.md`、`outline.md`
3. 更新 `config.json` 引用新方法

## 版本信息

- 系统版本：0.4.0
- 支持方法：5种
- 可扩展：是

---

*Novel Writer - 让每个故事找到最适合的讲述方式*