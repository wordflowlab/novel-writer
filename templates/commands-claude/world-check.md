---
name: world-check
description: 验证世界观设定的一致性
allowed-tools: Read(//spec/knowledge/**), Read(//stories/**/content/**), Bash(find:*), Bash(grep:*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/check-world.sh
---

## 动态上下文加载（Claude Code 增强）

**世界观设定文件**：
!`find spec/knowledge -name "world-setting.md" 2>/dev/null && echo "✅ 世界观文件存在" || echo "⚠️  无世界观文件"`

**知识库文件列表**：
!`find spec/knowledge -type f 2>/dev/null | sort`

**核心设定摘要**：
!`test -f spec/knowledge/world-setting.md && head -30 spec/knowledge/world-setting.md | grep -E "^#|^-" || echo "无设定内容"`

**地点数量统计**：
!`test -f spec/knowledge/locations.md && grep -c "^##" spec/knowledge/locations.md | xargs echo "已定义地点:" || echo "地点: 0"`

**专有名词统计**：
!`find spec/knowledge -type f -exec grep -h "^-" {} \; 2>/dev/null | wc -l | xargs echo "专有名词约:"`

**已写章节检索**：
!`find stories/*/content -name "*.md" ! -name "README.md" | wc -l | xargs echo "需检查章节:"`

---

# 世界观一致性检查

确保故事中的世界观设定保持前后一致，避免矛盾和冲突。

## 检查范围

1. **设定一致性** - 验证规则、法则、体系的一致
2. **地理逻辑** - 检查地点、距离、方位的合理性
3. **文化连贯** - 确保风俗、语言、传统的统一
4. **科技/魔法水平** - 验证能力范围和限制

## 使用方法

执行脚本 {SCRIPT}，将会：
- 扫描 `spec/knowledge/world-setting.md`
- 分析已写章节中的设定描述
- 对比查找矛盾和冲突
- 生成一致性报告

## 知识库结构

世界观设定存储在 `spec/knowledge/` 目录：
- `world-setting.md` - 核心世界观
- `locations.md` - 地点描述
- `culture.md` - 文化风俗
- `rules.md` - 特殊规则

## 输出示例

```
🌍 世界观一致性报告
━━━━━━━━━━━━━━━━━━━━
✅ 检查通过：23项
⚠️ 潜在问题：2项

⚠️ 发现的问题：
1. 第15章提到"三日路程"，但按地图应为五日
2. 第23章的官职名称与第3章不一致

📚 设定统计：
- 地点：15个
- 组织：8个
- 特殊规则：5条
- 专有名词：47个

💡 建议创建术语表以保持一致性
```
