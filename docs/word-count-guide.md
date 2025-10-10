# 中文字数统计使用指南

## 问题背景

### 为什么不能使用 `wc -w`？

`wc -w` 命令统计的是"词数"（word count），它以空格、制表符、换行符为分隔符。

**对于中文文本的问题**：
- 中文通常没有空格分隔词语
- 导致统计结果极不准确
- 例如："今天天气很好" 会被统计为 **1个词**（因为没有空格）

**实际案例**：
```bash
# 一个包含74个中文字符的文件
wc -w test.md
# 输出: 6    # 错误！只统计到6个词

# 使用正确的方法
count_chinese_words test.md
# 输出: 74   # 正确！统计到74个字符
```

### 为什么 `wc -m` 也不够好？

`wc -m` 统计字符数（character count），虽然比 `wc -w` 准确，但会统计：
- 空格
- 换行符
- 标点符号
- Markdown 标记（`#`、`*`、`-`等）

这些都不应该算在正文字数中。

## 正确的解决方案

### 使用 `count_chinese_words` 函数

项目提供了专门的中文字数统计函数，位于 `scripts/bash/common.sh`：

```bash
# 加载函数
source scripts/bash/common.sh

# 统计单个文件
count_chinese_words "stories/my-story/content/第001章.md"

# 输出: 2845
```

### 功能特点

✅ **排除无关内容**：
- 自动排除 Markdown 标记（`#`、`**`、`*`、`_`、`[`、`]`等）
- 排除代码块（```...```）
- 排除空格、换行、制表符
- 排除标点符号

✅ **准确统计**：
- 统计实际的中文字符
- 统计英文字母
- 统计数字
- 只计算正文内容

✅ **性能良好**：
- 处理大文件速度快（~10ms）
- 适合批量处理

## 使用方法

### 1. 在脚本中使用

```bash
#!/bin/bash

# 引入函数库
source "$(dirname "$0")/common.sh"

# 统计字数
file_path="stories/test/content/chapter-001.md"
word_count=$(count_chinese_words "$file_path")

echo "字数：$word_count"
```

### 2. 在命令行使用

```bash
# 统计单个章节
source scripts/bash/common.sh && \
  count_chinese_words "stories/my-story/content/第001章.md"

# 统计所有章节
for file in stories/my-story/content/*.md; do
  words=$(source scripts/bash/common.sh && count_chinese_words "$file")
  echo "$(basename "$file"): $words 字"
done
```

### 3. 使用辅助函数显示友好信息

```bash
source scripts/bash/common.sh

# 显示字数并验证是否符合要求
show_word_count_info "stories/my-story/content/第001章.md" 2000 4000

# 输出示例:
# 字数：2845
# ✅ 符合字数要求（2000-4000）
```

## 集成到工作流

### 1. 写作完成后自动验证

在 `/write` 命令完成后，会自动显示字数统计：

```
✅ 章节写作完成
- 已保存：stories/my-story/content/第001章.md
- 实际字数：2845字
- 字数要求：2000-4000字
- 字数状态：✅ 符合要求
- 任务状态：已更新
```

### 2. 使用 `/analyze` 查看全书统计

运行 `/analyze` 命令会显示每个章节的详细字数：

```
内容统计：

  第001章.md: 2845 字
  第002章.md: 3120 字
  第003章.md: 2678 字

  总字数：8643
  章节数：3
  平均章节长度：2881 字
```

### 3. 使用检查脚本验证进度

运行写作状态检查：

```bash
.specify/scripts/bash/check-writing-state.sh
```

输出示例：
```
已完成章节：3
字数要求：2000-4000 字

最近写作：
  - 第003章.md: 2678 字 ✅
  - 第002章.md: 3120 字 ✅
  - 第001章.md: 2845 字 ✅
```

## 配置字数要求

字数要求配置在 `spec/tracking/validation-rules.json`：

```json
{
  "rules": {
    "chapterMinWords": 2000,    // 每章最小字数
    "chapterMaxWords": 4000,    // 每章最大字数
    "dailyTarget": 1500,        // 每日目标字数
    "weeklyTarget": 10000       // 每周目标字数
  }
}
```

可以根据项目需求调整这些值。

## 测试验证

运行测试脚本验证字数统计功能：

```bash
./scripts/bash/test-word-count.sh
```

测试会验证：
- 纯中文文本统计
- Markdown 标记排除
- 代码块排除
- 中英文混合处理
- 与 `wc -w` 的对比
- 性能测试

## 常见问题

### Q: 为什么我的字数比预期少？

A: 可能的原因：
1. 使用了 `wc -w`（错误方法）
2. 文件中包含大量 Markdown 标记
3. 文件中包含代码块

**解决方法**：使用 `count_chinese_words` 函数。

### Q: 字数统计包括标点符号吗？

A: 不包括。`count_chinese_words` 函数会排除标点符号，只统计实际的文字内容。

### Q: 英文单词怎么统计？

A: 英文字母按字符数统计。例如 "hello" 统计为 5 个字符。

### Q: 统计速度慢怎么办？

A: 函数已经过优化，处理大文件（~3000字）通常只需 10ms。如果遇到性能问题：
1. 检查文件是否过大（超过 10000 字）
2. 考虑分章节统计
3. 确保 `sed`、`tr`、`grep` 等命令可用

### Q: 能否在 PowerShell 中使用？

A: 目前函数仅支持 Bash。PowerShell 版本正在开发中，可以临时使用 Git Bash 或 WSL。

## 最佳实践

1. **始终使用项目提供的函数**
   ```bash
   # ✅ 正确
   source scripts/bash/common.sh
   count_chinese_words "file.md"

   # ❌ 错误
   wc -w file.md
   wc -m file.md
   ```

2. **在写作完成后立即验证字数**
   - AI 写作完成后会自动显示字数
   - 确认符合字数要求再进行下一步

3. **定期运行 `/analyze` 检查全书进度**
   - 建议每 5 章运行一次
   - 查看总字数和平均章节长度

4. **根据项目调整字数要求**
   - 修改 `validation-rules.json`
   - 不同类型作品有不同要求

## 技术细节

### 函数实现原理

```bash
count_chinese_words() {
    local file="$1"

    cat "$file" | \
        sed '/^```/,/^```/d' |      # 移除代码块
        sed 's/^#\+[[:space:]]*//' | # 移除标题标记
        sed 's/\*\*//g' |            # 移除加粗
        sed 's/__//g' |              # 移除加粗
        sed 's/\*//g' |              # 移除斜体
        sed 's/_//g' |               # 移除斜体
        sed 's/\[//g' |              # 移除链接
        sed 's/\]//g' |              # 移除链接
        sed 's/(http[^)]*)//g' |     # 移除URL
        sed 's/^>[[:space:]]*//' |   # 移除引用
        sed 's/^[[:space:]]*[-*][[:space:]]*//' | # 移除列表
        tr -d '[:space:]' |          # 移除空格
        tr -d '[:punct:]' |          # 移除标点
        grep -o . |                  # 分割字符
        wc -l                        # 统计行数（=字符数）
}
```

### 相关脚本文件

- `scripts/bash/common.sh` - 核心函数库
- `scripts/bash/analyze-story.sh` - 使用字数统计
- `scripts/bash/check-writing-state.sh` - 显示章节字数
- `scripts/bash/test-word-count.sh` - 测试脚本

## 总结

- ❌ 不要用 `wc -w` 统计中文
- ❌ 不要用 `wc -m` 统计字数
- ✅ 使用 `count_chinese_words` 函数
- ✅ 利用自动化工具验证字数
- ✅ 配置合理的字数要求

这样可以确保准确、一致的字数统计，避免因统计方法不当导致的困惑。
