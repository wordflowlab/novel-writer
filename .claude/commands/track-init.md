---
name: track-init
description: 初始化追踪系统，基于故事大纲设置追踪数据
scripts:
  sh: .specify/scripts/bash/init-tracking.sh
  ps: .specify/scripts/powershell/init-tracking.ps1
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

   创建或更新 `spec/tracking/plot-tracker.json`：
   - 从大纲提取主线和支线
   - 标记关键情节节点
   - 设置伏笔追踪点

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