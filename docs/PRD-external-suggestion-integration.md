# PRD: 外部AI建议整合功能
> Product Requirement Document

## 1. 概述

### 1.1 背景
用户在使用 Novel Writer 创作10章内容后，希望通过其他AI工具（如Gemini、ChatGPT等）获取写作建议，并将这些建议优雅地整合到现有的创作规范（spec）中，以持续改进作品质量。

### 1.2 目标
- 提供标准化的外部建议整合机制
- 保持系统简洁性，不增加不必要的命令
- 实现建议的可追溯性和版本管理
- 确保建议格式的标准化和可解析性

### 1.3 价值主张
- **提升作品质量**：多AI协同，取长补短
- **保持创作连贯**：建议自动整合到规范中
- **提高效率**：标准化流程，减少手动操作

## 2. 功能设计

### 2.1 核心功能
扩展现有 `/constitution` 命令，新增 `refine` 子命令：
```
/constitution refine [建议内容]
```

### 2.2 功能流程
```mermaid
graph LR
    A[作者完成N章] --> B[使用外部AI分析]
    B --> C[获得结构化建议]
    C --> D[复制建议到Claude Code]
    D --> E[执行/constitution refine]
    E --> F[系统解析建议]
    F --> G[智能合并到spec]
    G --> H[生成改进报告]
    H --> I[继续创作]
```

### 2.3 建议分类处理

| 建议类型 | 目标文件 | 处理方式 |
|---------|---------|----------|
| 写作风格 | `.specify/memory/writing-constitution.md` | 合并到对应章节 |
| 角色优化 | `spec/knowledge/character-profiles.md` | 更新角色档案 |
| 情节建议 | `spec/tracking/plot-tracker.json` | 添加新节点 |
| 世界观补充 | `spec/knowledge/world-setting.md` | 扩展设定 |
| 节奏调整 | `.specify/memory/writing-constitution.md` | 更新质量标准 |

## 3. 第三方AI输出规范

### 3.1 标准建议格式
第三方AI必须按照以下JSON格式输出建议：

```json
{
  "version": "1.0",
  "source": "Gemini Pro",
  "analysis_date": "2025-01-24",
  "chapters_analyzed": {
    "start": 1,
    "end": 10,
    "total_words": 42000
  },
  "suggestions": {
    "style": {
      "priority": "high",
      "items": [
        {
          "type": "narrative_voice",
          "current": "第三人称全知视角存在跳跃",
          "suggestion": "保持单一视角，建议固定在主角视角",
          "examples": ["第3章第2段", "第7章开头"],
          "impact": "提升叙事连贯性"
        },
        {
          "type": "pacing",
          "current": "第5-7章节奏过于紧凑",
          "suggestion": "适当加入过渡段落，给读者喘息空间",
          "examples": ["第6章战斗后直接进入下一场冲突"],
          "impact": "改善阅读体验"
        }
      ]
    },
    "characters": {
      "priority": "medium",
      "items": [
        {
          "character": "女主角",
          "issue": "性格转变过快",
          "suggestion": "第4章到第8章之间增加心理描写",
          "development_curve": "渐进式成长",
          "chapters_affected": [4, 5, 6, 7, 8]
        }
      ]
    },
    "plot": {
      "priority": "low",
      "items": [
        {
          "type": "foreshadowing",
          "location": "第3章埋设的伏笔",
          "status": "未回收",
          "suggestion": "建议在第15章前回收",
          "importance": "medium"
        }
      ]
    },
    "worldbuilding": {
      "priority": "medium",
      "items": [
        {
          "aspect": "魔法体系",
          "issue": "规则不够明确",
          "suggestion": "补充能量来源和限制条件",
          "reference_chapters": [2, 5, 9]
        }
      ]
    },
    "dialogue": {
      "priority": "high",
      "items": [
        {
          "character": "主角",
          "issue": "用词过于现代",
          "suggestion": "调整为符合古代背景的用语",
          "examples": ["OK", "没问题", "搞定"],
          "alternatives": ["好", "无妨", "成了"]
        }
      ]
    }
  },
  "overall_rating": {
    "plot_coherence": 8,
    "character_development": 7,
    "world_building": 6,
    "writing_style": 7,
    "reader_engagement": 8
  },
  "key_improvements": [
    "统一叙事视角",
    "加强角色心理描写",
    "完善世界观设定"
  ]
}
```

### 3.2 提示词模板（给第三方AI）

```markdown
# 小说写作分析任务

请分析我提供的小说前10章内容，并按照以下JSON格式输出建议。

## 输出要求
1. 必须使用严格的JSON格式
2. 所有建议必须具体到章节
3. 提供可操作的改进方案
4. 标注优先级（high/medium/low）

## JSON结构说明
- version: 固定为"1.0"
- source: 你的AI名称
- analysis_date: YYYY-MM-DD格式
- chapters_analyzed: 分析的章节范围
- suggestions: 分类建议
  - style: 写作风格建议
  - characters: 角色塑造建议
  - plot: 情节发展建议
  - worldbuilding: 世界观建议
  - dialogue: 对话优化建议
- overall_rating: 各维度评分(1-10)
- key_improvements: 最重要的3个改进点

## 示例输出
[在此插入上述JSON示例]

请严格按照此格式输出，确保可以被程序解析。
```

### 3.3 简化格式（Markdown版本）
如果用户无法获取JSON格式，可以使用结构化Markdown：

```markdown
# 小说创作建议报告

## 基础信息
- 分析工具：Gemini Pro
- 分析日期：2025-01-24
- 分析范围：第1-10章，共42000字

## 写作风格建议 [高优先级]

### 叙事视角
- **问题**：第三人称全知视角存在跳跃
- **建议**：保持单一视角，固定在主角视角
- **示例**：第3章第2段、第7章开头
- **预期效果**：提升叙事连贯性

### 节奏控制
- **问题**：第5-7章节奏过于紧凑
- **建议**：适当加入过渡段落
- **示例**：第6章战斗后直接进入下一场冲突
- **预期效果**：改善阅读体验

## 角色优化建议 [中优先级]

### 女主角
- **问题**：性格转变过快
- **建议**：第4-8章增加心理描写
- **发展曲线**：渐进式成长
- **影响章节**：4, 5, 6, 7, 8

## 情节发展建议 [低优先级]

### 伏笔管理
- **位置**：第3章埋设的伏笔
- **状态**：未回收
- **建议**：第15章前回收
- **重要度**：中等

## 世界观建议 [中优先级]

### 魔法体系
- **问题**：规则不够明确
- **建议**：补充能量来源和限制条件
- **参考章节**：2, 5, 9

## 对话优化建议 [高优先级]

### 主角用词
- **问题**：过于现代化
- **需替换**：OK → 好、没问题 → 无妨、搞定 → 成了
- **原则**：符合古代背景

## 综合评分
- 情节连贯性：8/10
- 角色发展：7/10
- 世界构建：6/10
- 写作风格：7/10
- 读者吸引力：8/10

## 三个关键改进点
1. 统一叙事视角
2. 加强角色心理描写
3. 完善世界观设定
```

## 4. 技术实现

### 4.1 命令扩展
修改 `templates/commands/constitution.md`：
```yaml
---
description: 设定和优化小说创作风格
scripts:
  sh: .specify/scripts/bash/constitution-manager.sh
---

使用方式：
1. /constitution - 初始化创作风格
2. /constitution refine [建议] - 整合外部建议
```

### 4.2 建议解析器
创建 `.specify/scripts/bash/parse-suggestions.sh`：
```bash
#!/bin/bash
# 解析JSON或Markdown格式的建议
# 自动识别格式
# 提取关键信息
# 生成更新指令
```

### 4.3 数据存储
新增文件：
- `spec/knowledge/improvement-log.md` - 建议历史
- `spec/knowledge/suggestion-templates/` - 建议模板库
- `.specify/memory/refinement-history.json` - 改进记录

## 5. 用户体验

### 5.1 使用流程
1. **获取建议**
   ```
   用户：请分析我的小说前10章，给出改进建议
   Gemini：[返回结构化建议]
   ```

2. **复制建议**
   复制Gemini的完整输出

3. **执行整合**
   ```
   /constitution refine """
   [粘贴建议内容]
   """
   ```

4. **查看报告**
   ```
   ✅ 建议整合完成
   - 更新写作准则：3项
   - 优化角色设定：2项
   - 补充世界观：1项
   详见：spec/knowledge/improvement-log.md
   ```

### 5.2 错误处理
- 格式错误：提供格式修正提示
- 冲突建议：标记需人工确认
- 重复建议：自动去重

## 6. 成功指标

### 6.1 功能指标
- 建议解析成功率 > 95%
- 自动整合准确率 > 90%
- 处理时间 < 3秒

### 6.2 用户指标
- 采纳率 > 70%
- 作品质量提升（基于后续反馈）
- 用户满意度 > 8/10

## 7. 未来扩展

### 7.1 Phase 2
- 支持多AI建议对比
- 建议权重自动计算
- A/B测试不同建议效果

### 7.2 Phase 3
- 建议效果追踪
- 机器学习优化建议采纳
- 个性化建议过滤器

## 8. 风险与对策

| 风险 | 影响 | 对策 |
|-----|------|-----|
| 建议质量参差不齐 | 影响创作 | 提供建议评分机制 |
| 格式不统一 | 解析失败 | 多格式兼容+容错处理 |
| 过度依赖外部建议 | 失去个人风格 | 建议采纳度控制 |

## 9. 附录

### 9.1 相关文档
- [写作方法指南](../spec/knowledge/writing-methods-guide.md)
- [命令系统说明](./command-system.md)
- [追踪系统文档](./tracking-system.md)

### 9.2 版本历史
- v1.0 (2025-01-24): 初始版本

---
*文档状态：草案*
*作者：Novel Writer Team*
*最后更新：2025-01-24*