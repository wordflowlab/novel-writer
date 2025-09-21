---
name: track
description: 综合追踪小说创作进度和内容
scripts:
  sh: .specify/scripts/bash/track-progress.sh
---

# 综合进度追踪

全面展示小说创作的各项进度和状态。

## 追踪维度

1. **写作进度** - 字数、章节、完成率
2. **情节发展** - 主线进度、支线状态
3. **时间线** - 故事时间推进
4. **角色状态** - 角色发展和位置
5. **伏笔管理** - 埋设和回收状态

## 使用方法

执行脚本 .specify/scripts/bash/track-progress.sh [选项]：
- 无参数 - 显示完整追踪报告
- `--brief` - 显示简要信息
- `--plot` - 仅显示情节追踪
- `--stats` - 仅显示统计数据
- `--check` - 执行一致性检查

## 数据来源

整合多个追踪文件的信息：
- `progress.json` - 写作进度
- `spec/tracking/plot-tracker.json` - 情节追踪
- `spec/tracking/timeline.json` - 时间线
- `spec/tracking/relationships.json` - 关系网络
- `spec/tracking/character-state.json` - 角色状态

## 输出示例

```
📊 小说创作综合报告
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📖 《大明风华录》

✍️ 写作进度
  完成：60/240章 (25%)
  字数：162,000/800,000
  当前：第二卷《朝堂风云》

📍 情节状态
  主线：改革大业 [朝堂初入阶段]
  支线：感情线 [相互了解]

⏰ 时间线
  故事时间：万历三十年春
  时间跨度：5个月

👥 主要角色
  李中庸：翰林院编修 @北京
  沈玉卿：张居正义女 [活跃]

⚡ 待处理
  伏笔：3个未回收
  冲突：改革vs保守 [升级中]

✅ 一致性检查：通过
```