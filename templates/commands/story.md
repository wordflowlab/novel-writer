---
description: 创建故事大纲，包括主题、角色、世界观等核心设定
scripts:
  sh: scripts/bash/create-new-story.sh --json "{ARGS}"
  ps: scripts/powershell/create-new-story.ps1 -Json "{ARGS}"
---

根据提供的故事描述创建完整的故事大纲：

1. 运行脚本 `{SCRIPT}` 并解析 JSON 输出，获取 STORY_NAME 和 STORY_FILE
   **重要**：脚本只运行一次，JSON 输出会显示在终端
2. 加载 `templates/story-template.md` 理解所需章节
3. 使用模板结构将故事大纲写入 STORY_FILE，包含：
   - **故事概述**：一句话描述、核心冲突、主题思想
   - **角色设定**：主角和重要配角的详细设定
   - **世界观**：时代背景、地理环境、特殊规则
   - **情节大纲**：三幕结构或起承转合
4. 报告完成，包含故事名称、文件路径，准备进入章节规划

创作要点：
- 聚焦于"是什么"和"为什么"，而非"如何写"
- 角色要有明确的动机和成长弧线
- 世界观设定要自洽且有特色
- 情节要有冲突和张力