---
description: 创建故事大纲，包括主题、角色、世界观等核心设定
scripts:
  sh: .specify/scripts/bash/create-new-story.sh --json "{ARGS}"
  ps: .specify/scripts/powershell/create-new-story.ps1 -Json "{ARGS}"
---

**重要**：生成日期时，请先运行 `date '+%Y-%m-%d'` 获取当前系统日期，不要手动生成或猜测日期。

根据提供的故事描述创建完整的故事大纲：

## 智能方法应用

1. **读取项目配置**
   - 先读取 `.specify/config.json` 文件
   - 获取 `"method"` 字段的值（如：three-act、hero-journey、story-circle 等）
   - 如果没有设置，提示用户先使用 `/method` 命令选择写作方法

2. **选择对应的模板**
   - 根据配置中的方法，使用对应的模板：
     - `three-act` → 三幕结构模板
     - `hero-journey` → 英雄之旅12阶段模板
     - `story-circle` → 故事圈8步模板
     - `seven-point` → 七点结构模板
     - `pixar-formula` → 皮克斯6步公式
     - `snowflake` → 雪花十步法模板
   - 模板参考位置：`spec/presets/[method]/story.md`

## 创建故事大纲

1. 运行脚本 `{SCRIPT}` 并解析 JSON 输出，获取 STORY_NAME 和 STORY_FILE
   **重要**：脚本只运行一次，JSON 输出会显示在终端

2. **根据选定方法使用对应模板**
   - 三幕结构：使用经典三幕模板
   - 英雄之旅：使用12阶段模板
   - 故事圈：使用8步循环模板
   - 七点结构：使用7个关键节点模板
   - 皮克斯公式：使用6步公式模板
   - 雪花十步：使用递进式十步构建模板

3. 使用模板结构将故事大纲写入 STORY_FILE，包含：
   - **故事概述**：一句话描述、核心冲突、主题思想
   - **角色设定**：主角和重要配角的详细设定
   - **世界观**：时代背景、地理环境、特殊规则
   - **情节大纲**：按选定方法组织

4. 报告完成，包含：
   - 故事名称和文件路径
   - 使用的写作方法
   - 方法特点提醒
   - 准备进入章节规划

创作要点：
- 聚焦于"是什么"和"为什么"，而非"如何写"
- 角色要有明确的动机和成长弧线
- 世界观设定要自洽且有特色
- 情节要有冲突和张力