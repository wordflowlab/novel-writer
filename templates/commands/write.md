---
description: 基于任务清单执行章节写作，自动加载上下文和验证规则
argument-hint: [章节编号或任务ID]
allowed-tools: Read(//**), Write(//stories/**/content/**), Bash(ls:*), Bash(find:*), Bash(wc:*), Bash(grep:*), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/check-writing-state.sh
  ps: .specify/scripts/powershell/check-writing-state.ps1
---

基于七步方法论流程执行章节写作。
---

## 前置检查

1. 运行脚本 `{SCRIPT}` 检查创作状态
2. 加载方法论基准文档：
   - **创作宪法**：`memory/novel-constitution.md`
   - **故事规格**：`stories/*/specification.md`
   - **创作计划**：`stories/*/creative-plan.md`
   - **任务清单**：`stories/*/tasks.md`
   - **前文内容**：`stories/*/content/` (如有)
   - **角色验证规则**：`spec/tracking/validation-rules.json` (如有)
   - **角色状态**：`spec/tracking/character-state.json`
   - **关系规则**：`spec/tracking/relationships.json`
   - **个人语料**：`memory/personal-voice.md`
   - **自然化表达**：`spec/knowledge/natural-expression.md`
   - **反AI检测**：`spec/presets/anti-ai-detection.md`

## 写作执行流程

### 1. 选择写作任务
从 `tasks.md` 中选择状态为 `pending` 的写作任务，标记为 `in_progress`。

### 2. 验证前置条件
- 检查相关依赖任务是否完成
- 验证必要的设定是否就绪
- 确认前序章节是否完成

### 3. 写作前提醒
**基于宪法原则提醒**：
- 核心价值观要点
- 质量标准要求
- 风格一致性准则

**基于规格要求提醒**：
- P0 必须包含的元素
- 目标读者特征
- 内容红线提醒

**分段格式规范（重要）**：
- ⛔ **禁止使用**："一"、"二"、"三"等数字标记分段
- ✅ **使用方式**：场景转换时用两个空行（一个空白行）分隔
- 📖 **原因**：数字标记过于生硬，破坏阅读沉浸感，不符合网络小说习惯

### 4. 根据计划创作内容：
   - **开场**：吸引读者，承接前文
   - **发展**：推进情节，深化人物
   - **转折**：制造冲突或悬念
   - **收尾**：适当收束，引出下文

### 5. 质量自检
**宪法合规检查**：
- 是否符合核心价值观
- 是否达到质量标准
- 是否保持风格一致

**规格符合检查**：
- 是否包含必要元素
- 是否符合目标定位
- 是否遵守约束条件

**计划执行检查**：
- 是否按照章节架构
- 是否符合节奏设计
- 是否达到字数要求

**格式规范检查**：
- ⚠️ 确认未使用"一"、"二"、"三"等数字标记分段
- ✅ 场景转换使用两个空行（一个空白行）
- ✅ 保持段落间距自然流畅

### 6. 保存和更新
- 将章节内容保存到 `stories/*/content/`
- 更新任务状态为 `completed`
- 记录完成时间和字数

## 写作要点

- **遵循宪法**：始终符合创作原则
- **满足规格**：确保包含必要元素
- **执行计划**：按照技术方案推进
- **完成任务**：系统化推进任务清单
- **持续验证**：定期运行 `/analyze` 检查

## 完成后行动

### 7. 验证字数和更新进度

**字数统计说明**：
- 使用准确的中文字数统计方法
- 排除Markdown标记（`#`、`*`、`-`等）
- 只统计实际内容字符
- 字数要求来自 `spec/tracking/validation-rules.json`（默认2000-4000字）

**验证方法**：
使用项目提供的字数统计脚本验证章节字数：
```bash
source scripts/bash/common.sh
count_chinese_words "stories/*/content/第X章.md"
```

⚠️ **注意**：不要使用 `wc -w` 统计中文字数，它对中文极不准确！

**完成报告**：
```
✅ 章节写作完成
- 已保存：stories/*/content/第X章.md
- 实际字数：[X]字
- 字数要求：2000-4000字
- 字数状态：✅ 符合要求 / ⚠️ 字数不足 / ⚠️ 字数超出
- 任务状态：已更新
```

### 8. 建议下一步
- 继续下一个写作任务
- 每5章运行 `/analyze` 进行质量检查
- 发现问题及时调整计划

## 与方法论的关系

```
/constitution → 提供创作原则
     ↓
/specify → 定义故事需求
     ↓
/clarify → 澄清关键决策
     ↓
/plan → 制定技术方案
     ↓
/tasks → 分解执行任务
     ↓
/write → 【当前】执行写作
     ↓
/analyze → 验证质量一致
```

记住：写作是执行层，要严格遵循上层的规格和计划。