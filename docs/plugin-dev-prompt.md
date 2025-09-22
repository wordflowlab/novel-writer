# Novel Writer 插件开发规范

## 插件文件结构

```
plugin-name/
├── config.yaml          # 配置文件（必需）
├── README.md           # 使用说明（必需）
├── commands/           # 命令文件目录
│   └── *.md           # 命令实现文件
└── experts/            # 专家模式（可选）
    └── *.md           # 专家文件
```

## config.yaml 规范

```yaml
# 必需字段
name: plugin-id         # 唯一标识，使用小写和连字符
version: 1.0.0         # 语义化版本号
displayName: 显示名称   # 用户界面显示的中文名
description: 功能描述   # 一句话说明插件用途

# 可选字段
author: 作者名
homepage: URL

# 命令配置
commands:
  - id: command-id      # 命令标识，需加插件前缀
    name: 命令名称       # 中文显示名
    description: 命令说明
    file: commands/command-id.md  # 对应文件路径

# 专家配置（可选）
experts:
  - id: expert-id
    name: 专家名称
    description: 专家说明
    file: experts/expert-id.md
```

## 命令文件模板

```markdown
# [命令中文名] - /[command-id]

## 系统角色
你是一位[角色定位]，擅长[专业领域]。

## 任务
[明确的任务描述]

## 前置要求
[可选，如需要先执行其他命令]

## 工作流程
1. [步骤1]
2. [步骤2]
3. [步骤3]

## 输出格式
[具体的输出格式示例]

## 注意事项
- [重要提醒1]
- [重要提醒2]
```

## 开发规则

### 命名规范
- 插件名：`novel-[功能]-[子功能]`，如 `novel-character-generator`
- 命令ID：使用前缀避免冲突，如 `/char-`、`/plot-`、`/style-`
- 文件名：与命令ID保持一致

### 必须遵守
1. 每个命令一个独立文件，单一职责
2. 命令间通过"前置要求"协作，不直接通信
3. README.md 必须包含：功能介绍、使用方法、示例
4. 不依赖外部API或服务
5. 中文为主要语言

### 专家模式（可选）
当需要深度交互指导时添加专家：

```markdown
# [专家名称]

## 专家简介
[专家背景和专长]

## 核心能力
- [能力1]
- [能力2]

## 服务内容
[提供的具体服务]

## 交互方式
[如何与用户互动]
```

## AI 开发插件流程

当收到插件开发需求时：

1. **分析需求**
   - 明确插件解决什么问题
   - 确定需要几个命令
   - 是否需要专家模式

2. **设计结构**
   - 确定插件名和命令前缀
   - 规划命令列表和功能分工

3. **生成文件**
   - config.yaml - 插件配置
   - README.md - 使用说明
   - commands/*.md - 各命令实现
   - experts/*.md - 专家文件（如需要）

4. **输出格式**
   按以下顺序输出完整代码：
   - 首先：config.yaml
   - 其次：每个命令文件
   - 然后：专家文件（如有）
   - 最后：README.md

## 示例结构参考

### 简单插件（2-3个命令）
```yaml
name: novel-idea-generator
commands:
  - id: idea-plot      # 生成情节创意
  - id: idea-character # 生成人物创意
```

### 复杂插件（多命令协作）
```yaml
name: novel-analysis-tool
commands:
  - id: analyze-load    # 主命令：加载文件
  - id: analyze-plot    # 分析情节（依赖load）
  - id: analyze-style   # 分析文笔（依赖load）
experts:
  - id: analysis-coach  # 分析指导专家
```

## 输出要求

生成插件时必须：
1. 所有文件完整可用，不要省略
2. 命令描述清晰，避免歧义
3. 提供至少2个使用示例
4. 代码块正确标记语言类型
5. 不要添加实现说明或注释，直接输出代码