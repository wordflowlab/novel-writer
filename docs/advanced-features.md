# 高级功能使用指南

## 📊 方法智能推荐系统

### 功能说明
根据你的作品特征，智能推荐最适合的写作方法。

### 使用方式
```bash
novel recommend [options]
```

### 参数说明
- `-g, --genre <type>` - 小说类型（奇幻/科幻/悬疑/爱情/现实等）
- `-l, --length <number>` - 预计字数（默认：100000）
- `-a, --audience <type>` - 目标读者（儿童/青少年/成人/大众等）
- `-e, --experience <level>` - 写作经验（初级/中级/高级）
- `-f, --focus <type>` - 创作重点（情节/角色/主题/平衡）
- `-p, --pace <speed>` - 节奏偏好（快/中/慢）
- `-c, --complexity <level>` - 复杂度（简单/中等/复杂）

### 使用示例

#### 1. 奇幻长篇推荐
```bash
novel recommend --genre 奇幻 --length 200000 --complexity 复杂
```

#### 2. 儿童短篇推荐
```bash
novel recommend --genre 儿童 --length 30000 --audience 儿童 --experience 初级
```

#### 3. 悬疑小说推荐
```bash
novel recommend --genre 悬疑 --focus 情节 --pace 快
```

### 输出结果
系统会提供：
- 作品特征分析
- 首选推荐方法（匹配度和理由）
- 备选推荐方法
- 具体创作建议

## 🔄 方法转换工具

### 功能说明
帮助你在不同写作方法之间转换现有项目。

### 使用方式
```bash
novel convert <target> [options]
```

### 参数说明
- `target` - 目标方法（必需）
- `-f, --from <method>` - 源方法（默认读取当前配置）
- `-o, --output <file>` - 输出转换报告文件
- `--dry-run` - 仅生成报告，不实际转换

### 使用示例

#### 1. 查看转换方案（不实际转换）
```bash
novel convert hero-journey --dry-run
```

#### 2. 从三幕转换到七点结构
```bash
novel convert seven-point --from three-act
```

#### 3. 生成详细转换报告
```bash
novel convert story-circle --output conversion-report.md
```

### 转换映射示例

#### 三幕到七点结构
- 第一幕开始 → 钩子
- 第一幕结尾 → 第一情节点
- 第二幕前段 → 第一收紧点
- 第二幕中点 → 中点
- 第二幕后段 → 第二收紧点
- 第二幕结尾 → 第二情节点
- 第三幕 → 结局

## 🎯 混合方法支持

### 功能说明
允许在不同叙事层级使用不同的写作方法，实现更灵活的创作。

### 三个层级
1. **主要方法**：控制整体故事结构（主线情节）
2. **次要方法**：用于支线情节、角色弧线或章节结构
3. **微观方法**：用于单个场景或章节内部

### 使用方式
```bash
novel hybrid <action> [options]
```

### 操作类型

#### 1. 查看信息
```bash
novel hybrid info
```

#### 2. 获取推荐
```bash
novel hybrid recommend
```

#### 3. 创建混合结构
```bash
novel hybrid create --primary <method> [options]
```

### 参数说明
- `-p, --primary <method>` - 主要方法
- `-s, --secondary <method>` - 次要方法
- `-m, --micro <method>` - 微观方法
- `--scope <type>` - 次要方法范围：
  - `sub-plot` - 支线情节
  - `character-arc` - 角色弧线
  - `chapter` - 章节结构

### 使用示例

#### 1. 史诗奇幻组合
```bash
novel hybrid create --primary hero-journey --secondary story-circle --scope character-arc
```
主线用英雄之旅，角色成长用故事圈。

#### 2. 悬疑惊悚组合
```bash
novel hybrid create --primary seven-point --secondary three-act --scope chapter
```
整体用七点结构，章节用三幕组织。

#### 3. 多线叙事组合
```bash
novel hybrid create --primary three-act --secondary story-circle --scope sub-plot --micro pixar
```
主线三幕，支线故事圈，场景用皮克斯公式。

### 推荐组合

| 类型 | 主要方法 | 次要方法 | 适用场景 |
|------|----------|----------|----------|
| 史诗奇幻 | 英雄之旅 | 故事圈（角色） | 长篇奇幻、系列小说 |
| 悬疑惊悚 | 七点结构 | 三幕（章节） | 紧张节奏、商业小说 |
| 群像叙事 | 三幕结构 | 故事圈（支线） | 多线故事、现代文学 |
| 成长故事 | 故事圈 | 英雄之旅（关键章节） | 青春、成长类型 |

### 输出文件
创建混合结构后会生成 `hybrid-structure.md`，包含：
- 方法配置
- 结构映射
- 使用指南
- 示例说明

## 💡 最佳实践

### 1. 开始新项目
1. 先用 `novel recommend` 获取推荐
2. 考虑是否需要混合方法
3. 使用推荐的方法初始化项目

### 2. 转换现有项目
1. 先用 `--dry-run` 查看转换方案
2. 备份当前项目
3. 执行转换并检查映射

### 3. 混合方法使用
1. 主线保持一致性
2. 支线不要喧宾夺主
3. 微观服务于宏观

## 📈 功能对比

| 功能 | 适用场景 | 输入要求 | 输出结果 |
|------|----------|----------|----------|
| 智能推荐 | 新项目选择方法 | 作品特征 | 推荐报告 |
| 方法转换 | 现有项目改变方法 | 目标方法 | 转换映射 |
| 混合方法 | 复杂作品结构 | 多个方法组合 | 混合结构文档 |

## 🔗 相关文档
- [写作方法指南](spec/knowledge/writing-methods-guide.md)
- [各方法详细说明](spec/presets/)
- [项目配置说明](.specify/config.json)

## 📝 更新日志
- v0.4.3 - 实现三大高级功能
  - 智能推荐系统
  - 自动转换工具
  - 混合方法支持