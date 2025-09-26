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
   - **角色验证规则**：`spec/tracking/validation-rules.json` (如有)
   - **角色状态**：`spec/tracking/character-state.json`
   - **关系规则**：`spec/tracking/relationships.json`
   - **个人语料**：`memory/personal-voice.md`
   - **自然化表达**：`spec/knowledge/natural-expression.md`
   - **反AI检测**：`spec/presets/anti-ai-detection.md`

## 写作前验证提醒

**如果存在验证规则文件，执行以下检查**：
1. 显示主角正确名称和别名
2. 列出本章将出现的角色及其正确称呼
3. 提醒常见错误（从validation-rules.json的common_errors读取）

示例输出：
```
📝 写作提醒
━━━━━━━━━━━━━━━━━━━
主角：李中庸（中庸、李公子）
配角：沈玉卿 → 主角称呼为"公子"
⚠️ 避免使用：李明、张华、主角
```

3. **应用反AI检测策略**：
   - **词汇优化**：替换AI特征词为口语表达
   - **句法自然化**：长短句交错，加入口语特征
   - **认知模拟**：体现人类思维的不完美性
   - **缺陷植入**：适度的错别字和标点随意（每2000字1处）
   - **个性标记**：应用personal-voice.md的个人特征

4. 根据章节大纲创作内容：
   - **开场**：吸引读者，承接前文
   - **发展**：推进情节，深化人物
   - **转折**：制造冲突或悬念
   - **收尾**：适当收束，引出下文

5. 确保内容符合：
   - 设定的创作风格
   - 角色性格一致性
   - 世界观规则
   - 情节逻辑
   - **自然化要求**：避免过于完美的表达
6. **写作后快速验证**（如果存在validation-rules.json）：
   - 扫描生成内容中的角色名称
   - 检查是否有forbidden列表中的错误名称
   - 验证称呼是否符合relationships规则
   - 如发现问题，立即提示并建议修正

7. **AI检测自检**：
   - 检查是否有连续3句结构相似
   - 检查用词是否过于书面化
   - 确认有适度的口语化特征
   - 验证文本不过于完美

8. 将章节内容写入对应文件
9. 更新写作进度和任务状态

写作要点：
- 保持风格一致性
- 注意伏笔的埋设和回收
- 对话要符合角色身份
- 描写要有画面感
- 每章要有明确的推进作用
- **反AI要点**：
  - 自然化表达优于完美文字
  - 适度缺陷增加真实感
  - 个人特征贯穿全文

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
   - /track --check 批量验证最近章节（推荐每10章执行一次）
   ```

这样确保追踪数据始终与写作进度同步。

## 批量验证提醒

当完成多个章节后（建议每5-10章），运行：
```
/track --check   # 深度验证所有内容一致性
/track --fix     # 自动修复发现的简单问题
```