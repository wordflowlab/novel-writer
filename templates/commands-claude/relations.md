---
name: relations
description: 管理和追踪角色关系变化
argument-hint: [update | show | history | check] [角色] [关系] [目标角色]
allowed-tools: Read(//spec/tracking/relationships.json), Write(//spec/tracking/relationships.json), Bash(find:*), Bash(*)
model: claude-sonnet-4-5-20250929
scripts:
  sh: .specify/scripts/bash/manage-relations.sh
  ps: .specify/scripts/powershell/manage-relations.ps1
---

## 动态上下文加载（Claude Code 增强）

**关系网络文件**：
!`test -f spec/tracking/relationships.json && echo "✅ relationships.json 存在" || echo "⚠️  无关系文件"`

**角色数量统计**：
!`cat spec/tracking/relationships.json 2>/dev/null | grep -c '"name":' | xargs echo "已追踪角色:"`

**派系统计**：
!`cat spec/tracking/relationships.json 2>/dev/null | grep -E '"factions"' -A 20 | grep -c '"name":' | xargs echo "派系数量:"`

**主要角色关系**：
!`cat spec/tracking/relationships.json 2>/dev/null | grep -E '"主角"|"protagonist"' -A 10 || echo "无主角关系数据"`

**最近关系变化**：
!`cat spec/tracking/relationships.json 2>/dev/null | grep -E '"history"|"chapter"' | tail -10 || echo "无历史记录"`

---

# 角色关系管理

追踪和管理角色之间的关系动态，确保关系发展的合理性。

## 功能

1. **关系网络** - 维护角色之间的关系图谱
2. **关系变化** - 记录关系的演变历程
3. **派系管理** - 追踪各势力派系的对立与合作
4. **情感追踪** - 管理角色间的情感发展

## 使用方法

执行脚本 {SCRIPT} [操作] [参数]：
- `update` - 更新角色关系
- `show` - 显示关系网络
- `history` - 查看关系变化历史
- `check` - 验证关系逻辑

示例：
```
{SCRIPT} update 李中庸 allies 沈玉卿 --chapter 61 --note 初入翰林相助
# PowerShell:
{SCRIPT} -Command update -A 李中庸 -Relation allies -B 沈玉卿 -Chapter 61 -Note 初入翰林相助
```

## 数据存储

关系数据存储在 `spec/tracking/relationships.json`：
```json
{
  "characters": {
    "主角": {
      "盟友": ["角色A", "角色B"],
      "敌对": ["角色C"],
      "爱慕": ["角色D"],
      "未知": ["角色E"]
    }
  },
  "factions": {
    "改革派": ["主角", "角色A"],
    "保守派": ["角色C", "角色F"]
  }
}
```

## 输出示例

```
👥 角色关系网络
━━━━━━━━━━━━━━━━━━━━
主角：李中庸
├─ 💕 爱慕：沈玉卿
├─ 🤝 盟友：张居正（隐藏）
├─ 📚 导师：利玛窦
├─ ⚔️ 敌对：申时行派系
└─ 👁️ 监视：东厂

派系对立：
改革派 ←→ 保守派
东林党 ←→ 阉党

最近变化（第60章）：
- 沈玉卿：陌生人 → 相互吸引
- 张居正：未知 → 师承关系
```
