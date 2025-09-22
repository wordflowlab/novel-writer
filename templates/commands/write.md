---
description: 执行具体的章节写作，AI 辅助创作内容
scripts:
  sh: .specify/scripts/bash/write-chapter.sh
  ps: .specify/scripts/powershell/write-chapter.ps1
---

执行章节写作任务：

1. 运行脚本 `{SCRIPT}` 确定要写作的章节
2. 加载相关文件：
   - 创作风格：`.specify/memory/writing-constitution.md`
   - 故事大纲：`stories/*/story.md`
   - 章节规划：`stories/*/outline.md`
   - 前文内容：`stories/*/chapters/` (如有)
3. 根据章节大纲创作内容：
   - **开场**：吸引读者，承接前文
   - **发展**：推进情节，深化人物
   - **转折**：制造冲突或悬念
   - **收尾**：适当收束，引出下文
4. 确保内容符合：
   - 设定的创作风格
   - 角色性格一致性
   - 世界观规则
   - 情节逻辑
5. 将章节内容写入对应文件
6. 更新写作进度和任务状态

写作要点：
- 保持风格一致性
- 注意伏笔的埋设和回收
- 对话要符合角色身份
- 描写要有画面感
- 每章要有明确的推进作用

## 追踪数据自动更新

写作完成后，自动执行以下更新：

1. **更新情节追踪**
   - 更新 `spec/tracking/plot-tracker.json` 的当前章节
   - 标记完成的情节节点
   - 记录新增的伏笔

2. **更新时间线**
   - 提取章节中的时间信息
   - 更新 `spec/tracking/timeline.json`
   - 检查时间连续性

3. **更新角色关系**
   - 识别关系变化
   - 更新 `spec/tracking/relationships.json`
   - 记录关系演变历程

4. **更新角色状态**
   - 记录角色位置变化
   - 更新 `spec/tracking/character-state.json`
   - 追踪角色发展

5. **生成追踪提醒**
   ```
   ✅ 第N章写作完成，追踪数据已更新

   建议执行：
   - /plot-check 验证情节连贯性
   - /timeline 检查时间逻辑
   - /relations 确认关系变化
   ```

这样确保追踪数据始终与写作进度同步。