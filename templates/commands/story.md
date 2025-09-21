---
description: 创建故事大纲，包括主题、角色、世界观等核心设定
scripts:
  sh: .specify/scripts/bash/create-new-story.sh --json "{ARGS}"
  ps: .specify/scripts/powershell/create-new-story.ps1 -Json "{ARGS}"
---

**重要**：生成日期时，请先运行 `date '+%Y-%m-%d'` 获取当前系统日期，不要手动生成或猜测日期。

根据提供的故事描述创建完整的故事大纲：

## 智能方法选择（新增）

1. **了解故事特征**
   - 通过对话了解故事类型、长度、读者等信息
   - 如果信息不足，友好地询问更多细节

2. **智能推荐方法**
   ```javascript
   import { aiInterface } from '../src/ai-interface';

   const context = {
     genre: '从描述中提取的类型',
     description: '用户的故事描述',
     estimatedLength: '预计长度',
     targetAudience: '目标读者'
   };

   const selection = await aiInterface.guideMethodSelection(context);
   ```

3. **选择合适的模板**
   - 根据推荐的方法，选择对应的模板
   - 可从 `spec/presets/[method]/story.md` 加载特定方法的模板
   - 如果用户已有偏好，尊重用户选择

## 创建故事大纲

1. 运行脚本 `{SCRIPT}` 并解析 JSON 输出，获取 STORY_NAME 和 STORY_FILE
   **重要**：脚本只运行一次，JSON 输出会显示在终端

2. **根据选定方法使用对应模板**
   - 三幕结构：使用经典三幕模板
   - 英雄之旅：使用12阶段模板
   - 故事圈：使用8步循环模板
   - 七点结构：使用7个关键节点模板
   - 皮克斯公式：使用6步公式模板

3. 使用模板结构将故事大纲写入 STORY_FILE，包含：
   - **故事概述**：一句话描述、核心冲突、主题思想
   - **角色设定**：主角和重要配角的详细设定
   - **世界观**：时代背景、地理环境、特殊规则
   - **情节大纲**：按选定方法组织

4. **更新项目配置**
   ```javascript
   await aiInterface.updateProjectMethod(selection.method);
   ```

5. 报告完成，包含：
   - 故事名称和文件路径
   - 使用的写作方法
   - 方法特点提醒
   - 准备进入章节规划

创作要点：
- 聚焦于"是什么"和"为什么"，而非"如何写"
- 角色要有明确的动机和成长弧线
- 世界观设定要自洽且有特色
- 情节要有冲突和张力