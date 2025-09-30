---
name: plot-check
description: 检查情节发展的一致性和连贯性
scripts:
  sh: .specify/scripts/bash/check-plot.sh
  ps: .specify/scripts/powershell/check-plot.ps1
---

# 检查情节发展

分析当前章节与大纲的对齐情况，验证情节发展的连贯性。

## 检查内容

1. **情节节点对齐** - 验证当前进度与大纲规划是否一致
2. **伏笔追踪** - 检查已埋设的伏笔和回收计划
3. **冲突发展** - 确认冲突升级符合预期节奏
4. **角色成长** - 验证角色发展与规划一致

## 使用方法

执行脚本 .specify/scripts/bash/check-plot.sh，将会：
- 读取 `spec/tracking/plot-tracker.json`
- 对比 `outline.md` 中的规划
- 分析已写章节内容
- 生成一致性报告

## 输出示例

```
✅ 情节发展检查报告
━━━━━━━━━━━━━━━━━━━━
📍 当前进度：第61章（第二卷）
📊 对齐状态：与大纲一致

⚠️ 待处理伏笔：
  - 青铜古镜的秘密（第2章埋设）
  - 东厂的真实目的（第9章埋设）

✓ 已完成节点：
  - 科举及第 ✓
  - 获得改革传承 ✓

→ 下一个节点：组建改革派系

💡 建议：第65章前需要引入新的冲突点
```

## 智能检查功能

1. **自动更新当前状态**
   - 读取最新写作进度 `stories/*/progress.json`
   - 更新 `plot-tracker.json` 的 currentState
   - 同步章节和位置信息

2. **关联数据检查**
   - 对比 `timeline.json` 确认时间连续性
   - 检查 `relationships.json` 中的冲突是否体现
   - 验证 `character-state.json` 中的角色位置

3. **智能建议**
   - 根据当前进度提醒即将到来的情节点
   - 建议合适的伏笔回收时机
   - 提示需要加强的冲突升级

## 数据同步

检查完成后自动：
- 更新 plot-tracker.json 的检查时间
- 记录发现的问题到 notes 字段
- 生成下一步行动建议
