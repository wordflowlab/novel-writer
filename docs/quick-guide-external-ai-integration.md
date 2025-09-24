# 外部AI建议整合 - 快速指南

## 🚀 三步完成建议整合

### 第1步：获取建议
复制下面的提示词给Gemini/ChatGPT：

```
分析我的小说前10章并按JSON格式返回建议：
{
  "version": "1.0",
  "source": "Gemini",
  "analysis_date": "2025-01-24",
  "suggestions": {
    "style": {"priority": "high", "items": [建议列表]},
    "characters": {"priority": "medium", "items": [建议列表]},
    "dialogue": {"priority": "high", "items": [建议列表]}
  },
  "key_improvements": ["改进点1", "改进点2", "改进点3"]
}

小说内容：[粘贴你的章节]
```

### 第2步：复制建议
复制AI返回的JSON内容

### 第3步：执行整合
在Claude Code中运行：
```
/style refine
[粘贴JSON]
```

## ✅ 完成！
系统会自动：
- 解析建议内容
- 更新相关规范文件
- 生成整合报告
- 记录到改进历史

## 📝 支持的建议类型

| 建议类型 | 更新文件 | 示例 |
|---------|---------|------|
| 写作风格 | writing-constitution.md | 视角统一、节奏控制 |
| 角色优化 | character-profiles.md | 性格发展、动机强化 |
| 对话改进 | character-voices.md | 用词规范、语言特色 |
| 情节建议 | plot-tracker.json | 伏笔回收、冲突设置 |
| 世界观 | world-setting.md | 规则完善、细节补充 |

## 🔍 查看整合结果
```bash
# 查看改进历史
cat spec/knowledge/improvement-log.md

# 查看更新的规范
cat .specify/memory/writing-constitution.md
```

## 💡 最佳实践

### 建议频率
- 每10章分析一次
- 重大修改后再分析
- 定期（每月）全面评估

### 建议优先级
1. **高优先级**：立即执行，影响后续创作
2. **中优先级**：计划执行，逐步改进
3. **低优先级**：参考借鉴，选择采纳

### 批量处理
可以同时整合多个AI的建议：
```
/style refine --merge
[Gemini的JSON]
---
[ChatGPT的JSON]
```

## ⚠️ 常见问题

### Q: JSON格式错误？
A: 确保复制完整的JSON，包括所有大括号

### Q: 建议没有生效？
A: 检查 improvement-log.md 查看是否成功整合

### Q: 想要撤销建议？
A: 查看git历史，可以回滚相关文件

## 📚 详细文档
- [完整提示词模板](./ai-suggestion-prompt-template.md)
- [Gemini专用模板](./ai-suggestion-prompt-for-gemini.md)
- [实例演示](./suggestion-integration-examples.md)
- [PRD文档](./PRD-external-suggestion-integration.md)

---
*版本：1.0 | 更新：2025-01-24*