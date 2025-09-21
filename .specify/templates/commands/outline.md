---
description: 规划详细的章节结构和情节安排
scripts:
  sh: .specify/scripts/bash/setup-outline.sh
  ps: .specify/scripts/powershell/setup-outline.ps1
---

基于已创建的故事大纲，制定详细的章节规划：

1. 运行脚本 `{SCRIPT}` 初始化章节规划文件
2. 加载故事大纲 `stories/*/story.md` 理解故事内容
3. 加载 `.specify/templates/outline-template.md` 理解规划格式
4. 创建章节规划，包含：
   - **总体结构**：总章节数、每章字数、更新计划
   - **卷/部划分**：如有多卷，划分各卷主题
   - **详细章节**：每章的主要事件、角色发展、情节功能
   - **节奏控制**：高潮分布、悬念设置、情感曲线
5. 将规划写入 `stories/*/outline.md`
6. 创建章节文件夹结构 `stories/*/chapters/`

规划原则：
- 每章应有明确的目标和冲突
- 注意节奏的张弛有度
- 伏笔和回收要标记清楚
- 高潮要合理分布，不能都挤在最后