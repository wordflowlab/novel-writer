# 给Gemini的小说分析提示词

## 使用方法
1. 复制下面的完整提示词
2. 将[X]替换为实际章节数
3. 在提示词后粘贴你的小说内容
4. Gemini会返回可以直接用于Novel Writer的结构化建议

---

## 完整提示词（直接复制）

```
我需要你分析我的小说前10章，给出改进建议。请严格按照下面的JSON格式输出，不要添加任何额外说明。

直接返回这个JSON结构（填充实际内容）：

{
  "version": "1.0",
  "source": "Gemini",
  "analysis_date": "2025-01-24",
  "chapters_analyzed": {
    "start": 1,
    "end": 10,
    "total_words": 实际字数
  },
  "suggestions": {
    "style": {
      "priority": "high/medium/low",
      "items": [
        {
          "type": "问题类型",
          "current": "当前存在的问题",
          "suggestion": "具体改进建议",
          "examples": ["具体章节位置"],
          "impact": "预期改进效果"
        }
      ]
    },
    "characters": {
      "priority": "high/medium/low",
      "items": [
        {
          "character": "角色名",
          "issue": "存在问题",
          "suggestion": "改进建议",
          "development_curve": "成长曲线",
          "chapters_affected": [影响的章节数字]
        }
      ]
    },
    "plot": {
      "priority": "high/medium/low",
      "items": [
        {
          "type": "情节类型",
          "location": "章节位置",
          "status": "当前状态",
          "suggestion": "处理建议",
          "importance": "high/medium/low"
        }
      ]
    },
    "worldbuilding": {
      "priority": "high/medium/low",
      "items": [
        {
          "aspect": "世界观方面",
          "issue": "问题描述",
          "suggestion": "补充建议",
          "reference_chapters": [相关章节]
        }
      ]
    },
    "dialogue": {
      "priority": "high/medium/low",
      "items": [
        {
          "character": "角色名",
          "issue": "对话问题",
          "suggestion": "改进方案",
          "examples": ["问题示例"],
          "alternatives": ["替代方案"]
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
    "最重要的改进点1",
    "最重要的改进点2",
    "最重要的改进点3"
  ]
}

请分析以下小说内容：
[在此粘贴你的小说章节]
```

## 示例对话

### 用户输入
```
我需要你分析我的小说前10章，给出改进建议。请严格按照下面的JSON格式输出，不要添加任何额外说明。

[JSON格式模板...]

请分析以下小说内容：
第一章：xxx
第二章：xxx
...
```

### Gemini应该返回
```json
{
  "version": "1.0",
  "source": "Gemini",
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
          "current": "第三人称视角不统一",
          "suggestion": "保持第三人称限制视角",
          "examples": ["第3章第2段", "第7章开头"],
          "impact": "提升叙事连贯性"
        }
      ]
    },
    ...
  }
}
```

## 使用返回的建议

1. 复制Gemini返回的完整JSON
2. 在Claude Code中执行：
```
/constitution refine [粘贴JSON]
```
3. 系统会自动整合建议到你的创作规范中

## 注意事项
- 确保Gemini返回的是纯JSON格式
- 如果返回内容有额外文字，只复制JSON部分
- 建议每10章分析一次，保持迭代改进