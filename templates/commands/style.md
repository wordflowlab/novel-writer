---
description: 设定和优化小说创作风格，支持初始设定和外部建议整合
scripts:
  sh: .specify/scripts/bash/style-manager.sh
  ps: .specify/scripts/powershell/style-manager.ps1
---

## 命令模式

### 模式1：初始设定（默认）
`/style` 或 `/style init`

根据提供的创作风格描述，执行以下操作：

1. 运行脚本 `{SCRIPT} init` 创建或更新创作风格文件
2. 加载 `.specify/memory/writing-constitution.md` 模板，理解所需的章节
3. 根据用户描述填充以下内容：
   - 叙事视角（第一人称/第三人称等）
   - 文字风格（简洁明快/华丽优美等）
   - 创作原则（角色塑造、情节推进等）
   - 质量标准（字数要求、更新频率等）
4. 将创作准则写入 `.specify/memory/writing-constitution.md`
5. 报告完成状态，准备进入下一阶段

附加整合：若检测到 `.specify/memory/personal-voice.md`，在填充风格时参考其中的口头禅、句式与意象，保持个人表达一致性（不强制，避免过拟合）

### 模式2：整合外部建议 ⭐新功能
`/style refine [建议内容]`

智能整合来自其他AI（如Gemini、ChatGPT）的分析建议：

1. **解析建议格式**
   运行脚本 `{SCRIPT} refine` 分析输入内容
   - 自动识别JSON或Markdown格式
   - 提取建议类别和优先级
   - 验证建议完整性

2. **智能分类处理**
   根据建议类型更新对应文件：
   - **写作风格** → `.specify/memory/writing-constitution.md`
   - **角色优化** → `spec/knowledge/character-profiles.md`
   - **情节建议** → `spec/tracking/plot-tracker.json`
   - **世界观** → `spec/knowledge/world-setting.md`
   - **对话规范** → `spec/knowledge/character-voices.md`

3. **建议历史记录**
   - 创建/更新 `spec/knowledge/improvement-log.md`
   - 记录建议来源、日期、采纳状态
   - 生成版本对比报告

4. **冲突处理**
   - 标记与现有规范的冲突
   - 提供合并选项
   - 保留回滚能力

5. **生成整合报告**
   ```
   ✅ 建议整合完成
   - 更新规范：X项
   - 新增任务：Y个
   - 冲突处理：Z个
   详见 improvement-log.md
   ```

### 模式3：多源建议合并
`/style refine --merge [多个建议]`

当有多个AI提供建议时，智能合并处理：
- 识别一致性建议（优先执行）
- 标记冲突建议（人工决策）
- 权重计算和优先级排序

## 建议格式要求

### JSON格式（推荐）
```json
{
  "version": "1.0",
  "source": "AI名称",
  "suggestions": {
    "style": {...},
    "characters": {...},
    "plot": {...}
  }
}
```

### Markdown格式（备选）
```markdown
# 小说创作建议报告
## 写作风格建议 [优先级]
...
```

详细格式见：`docs/ai-suggestion-prompt-template.md`

## 注意事项
- 初始设定应在创作前期完成
- 建议整合建议每10章执行一次
- 保持个人风格，不盲目采纳所有建议
- 定期查看 improvement-log.md 追踪改进效果
