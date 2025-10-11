# Checklists 目录

本目录存放所有质量检查清单（Checklist）文件。

## 📋 Checklist 类型

### 规格质量类（问题生成式）
验证规划文档本身的质量，类似"需求的单元测试"：

- **大纲质量** (`outline-quality.md`) - 检查 outline.md 的完整性、清晰度、一致性
- **角色设定** (`character-clarity.md`) - 检查角色设定文档
- **世界观** (`world-quality.md`) - 检查世界观设定文档
- **创作计划** (`plan-quality.md`) - 检查创作计划文档
- **伏笔管理** (`foreshadowing-quality.md`) - 检查伏笔定义和规划

### 内容验证类（结果报告式）
扫描已写章节，验证实际内容：

- **世界观一致性** (`world-consistency-YYYYMMDD.md`) - 扫描章节内容
- **情节对齐** (`plot-alignment-YYYYMMDD.md`) - 对比进度与大纲
- **数据同步** (`data-sync-YYYYMMDD.md`) - 验证 tracking 数据
- **时间线** (`timeline-YYYYMMDD.md`) - 检查时间逻辑
- **写作状态** (`writing-state-YYYYMMDD.md`) - 检查写作准备度

## 🎯 命名规则

### 规格质量类
固定文件名，覆盖更新：
```
[类型]-quality.md
```

示例：
- `outline-quality.md`
- `character-clarity.md`
- `world-quality.md`

### 内容验证类
带日期戳，每次生成新文件：
```
[类型]-YYYYMMDD.md
```

示例：
- `world-consistency-20251011.md`
- `plot-alignment-20251011.md`
- `data-sync-20251011.md`

## 📖 使用方法

### 生成 Checklist

使用统一的 `/checklist` 命令：

```bash
# 规格质量检查（写作前）
/checklist 大纲质量
/checklist 角色设定
/checklist 世界观

# 内容验证检查（写作后）
/checklist 世界观一致性
/checklist 情节对齐
/checklist 数据同步
```

### Checklist 格式

所有 checklist 使用统一的 Markdown 格式：

```markdown
# [检查类型] Checklist

**检查时间**: 2025-10-11 14:30:00
**检查对象**: [文件或范围]
**检查维度**: [维度说明]

---

## [维度 1]

- [ ] CHK001 检查项描述 [标签]
- [x] CHK002 检查项描述 [标签] ✓
- [!] CHK003 检查项描述 [标签] ⚠️ 发现问题

## 发现的问题

### CHK003
**问题**: 详细描述
**位置**: 文件:行号
**建议**: 如何改进

---

## 后续行动

- [ ] 行动项 1
- [ ] 行动项 2
```

### 勾选方式

- `[ ]` - 未检查
- `[x]` - 已检查，通过
- `[!]` - 已检查，发现问题（需记录详情）

## 🔄 工作流程

### 规划阶段（写作前）
1. 完成大纲、角色、世界观等规划文档
2. 运行规格质量类 checklist
3. 根据检查结果改进文档
4. 确保规划质量合格再开始写作

### 写作阶段（写作中/后）
1. 完成章节写作
2. 定期运行内容验证类 checklist
3. 发现并修复一致性问题
4. 保持历史记录，追踪改进

## 📊 最佳实践

1. **双保险机制**
   - 规划阶段：验证文档质量
   - 写作阶段：验证内容一致性

2. **早发现早修复**
   - 在大纲阶段就发现逻辑漏洞
   - 避免写到后期才发现问题

3. **定期检查**
   - 每完成 5-10 章节，运行一次内容验证
   - 大的情节转折前，运行规格质量检查

4. **保留历史**
   - 内容验证类 checklist 按日期保存
   - 可追踪问题的发现和解决过程

5. **清理过期文件**
   - 定期清理已解决的旧 checklist
   - 保留关键里程碑的检查记录

## 🆘 故障排查

### Checklist 未生成
- 检查 `/checklist` 命令是否正确
- 确认相关脚本有执行权限
- 查看错误信息

### 检查项全部未通过
- 确认文件路径正确
- 检查 JSON 文件格式是否有效
- 运行 `jq` 命令测试 JSON 文件

### 旧命令迁移
旧命令仍可用，但推荐迁移：
- `/world-check` → `/checklist 世界观一致性`
- `/plot-check` → `/checklist 情节对齐`

## 📚 相关文档

- [Checklist 命令文档](../../templates/commands/checklist.md)
- [Checklist 模板](../../templates/checklist-template.md)
- [检查脚本](../../scripts/bash/)

---

**版本**: 1.0
**最后更新**: 2025-10-11
