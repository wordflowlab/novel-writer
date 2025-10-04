---
name: track-init
description: 初始化追踪系统，基于故事大纲设置追踪数据
allowed-tools: Read(//stories/**/specification.md), Read(//stories/**/outline.md), Read(//stories/**/creative-plan.md), Write(//spec/tracking/**), Bash(find:*), Bash(grep:*), Bash(wc:*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/init-tracking.sh
  ps: .specify/scripts/powershell/init-tracking.ps1
---

## 动态上下文加载（Claude Code 增强）

**规格文件状态**：
!`find stories -name "specification.md" 2>/dev/null | head -1 | xargs -I {} echo "✅ 规格文件: {}" || echo "⚠️  无规格文件"`

**大纲文件状态**：
!`find stories -name "outline.md" 2>/dev/null | head -1 | xargs -I {} echo "✅ 大纲文件: {}" || echo "⚠️  无大纲文件"`

**创作计划状态**：
!`find stories -name "creative-plan.md" 2>/dev/null | head -1 | xargs -I {} echo "✅ 计划文件: {}" || echo "⚠️  无计划文件"`

**线索数量统计**：
!`find stories -name "specification.md" -exec grep -c "^| PL-" {} \; 2>/dev/null | head -1 | xargs echo "规格中定义线索:" || echo "线索: 0"`

**交汇点数量**：
!`find stories -name "specification.md" -exec grep -c "^| X-" {} \; 2>/dev/null | head -1 | xargs echo "交汇点:" || echo "交汇点: 0"`

**伏笔数量**：
!`find stories -name "specification.md" -exec grep -c "^| F-" {} \; 2>/dev/null | head -1 | xargs echo "伏笔:" || echo "伏笔: 0"`

**现有追踪文件**：
!`ls spec/tracking/*.json 2>/dev/null | wc -l | xargs echo "已存在追踪文件:" || echo "追踪文件: 0"`

**追踪目录状态**：
!`test -d spec/tracking && echo "✅ 追踪目录存在" || echo "⚠️  需创建追踪目录"`

---

# 初始化追踪系统

基于已创建的故事大纲和章节规划，初始化所有追踪数据文件。

## 使用时机

在完成 `/story` 和 `/outline` 之后，开始写作之前执行此命令。

## 初始化流程

1. **读取基础数据**
   - 读取 `stories/*/story.md` 获取故事设定
   - 读取 `stories/*/outline.md` 获取章节规划
   - 读取 `.specify/config.json` 获取写作方法

2. **初始化追踪文件**

   **重要**：优先从 `specification.md` 第五章读取线索管理规格，填充到追踪文件。

   创建或更新 `spec/tracking/plot-tracker.json`：
   - 从 `specification.md 5.1节` 读取所有线索定义
   - 从 `specification.md 5.3节` 读取所有交汇点
   - 从 `specification.md 5.4节` 读取所有伏笔
   - 从 `creative-plan.md` 读取章节段的线索分布
   - 设置当前状态（假设尚未开始写作）

   **plot-tracker.json 结构**：
   ```json
   {
     "novel": "[从specification.md读取故事名称]",
     "lastUpdated": "[YYYY-MM-DD]",
     "currentState": {
       "chapter": 0,
       "volume": 1,
       "mainPlotStage": "[初始阶段]"
     },
     "plotlines": {
       "main": {
         "name": "[主线名称]",
         "status": "active",
         "currentNode": "[起点]",
         "completedNodes": [],
         "upcomingNodes": "[从交汇点和章节规划读取]"
       },
       "subplots": [
         {
           "id": "[从5.1读取，如PL-01]",
           "name": "[线索名称]",
           "type": "[主线/支线/主线支撑]",
           "priority": "[P0/P1/P2]",
           "status": "[active/dormant]",
           "plannedStart": "[起始章节]",
           "plannedEnd": "[结束章节]",
           "currentNode": "[当前节点]",
           "completedNodes": [],
           "upcomingNodes": "[从交汇点表读取]",
           "intersectionsWith": "[从5.3交汇点表读取相关线索]",
           "activeChapters": "[从5.2节奏规划读取]"
         }
       ]
     },
     "foreshadowing": [
       {
         "id": "[从5.4读取，如F-001]",
         "content": "[伏笔内容]",
         "planted": {"chapter": null, "description": "[埋设说明]"},
         "hints": [],
         "plannedReveal": {"chapter": "[揭晓章节]", "description": "[揭晓方式]"},
         "status": "planned",
         "importance": "[high/medium/low]",
         "relatedPlotlines": "[涉及的线索ID列表]"
       }
     ],
     "intersections": [
       {
         "id": "[从5.3读取，如X-001]",
         "chapter": "[交汇章节]",
         "plotlines": "[涉及的线索ID列表]",
         "content": "[交汇内容]",
         "status": "upcoming",
         "impact": "[预期效果]"
       }
     ]
   }
   ```

   创建或更新 `spec/tracking/timeline.json`：
   - 根据章节规划设置时间节点
   - 标记重要时间事件

   创建或更新 `spec/tracking/relationships.json`：
   - 从角色设定提取初始关系
   - 设置派系分组

   创建或更新 `spec/tracking/character-state.json`：
   - 初始化角色状态
   - 设置起始位置

3. **生成追踪报告**
   显示初始化结果，确认追踪系统就绪

## 智能关联

- 根据写作方法自动设置检查点
- 英雄之旅：12个阶段的追踪点
- 三幕结构：三幕转折点
- 七点结构：7个关键节点

追踪系统初始化后，后续写作会自动更新这些数据。
