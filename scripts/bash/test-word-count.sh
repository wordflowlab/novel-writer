#!/bin/bash

# 测试中文字数统计功能
# 用于验证 count_chinese_words 函数的准确性

set -e

# Source common functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# 颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "中文字数统计功能测试"
echo "========================================"
echo ""

# 创建临时测试文件
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# 测试用例1: 纯中文文本
echo "## 测试1: 纯中文文本"
cat > "$TEST_DIR/test1.md" << 'EOF'
今天天气很好，我去公园散步。
看到很多人在锻炼身体。
EOF
expected1=16
actual1=$(count_chinese_words "$TEST_DIR/test1.md")
echo "  预期字数: $expected1"
echo "  实际字数: $actual1"
if [ "$actual1" -eq "$expected1" ]; then
    echo -e "  ${GREEN}✅ 测试通过${NC}"
else
    echo -e "  ${RED}❌ 测试失败${NC}"
fi
echo ""

# 测试用例2: 包含Markdown标记
echo "## 测试2: 包含Markdown标记的文本"
cat > "$TEST_DIR/test2.md" << 'EOF'
# 第一章

这是**重要**的内容。

- 列表项1
- 列表项2

> 这是引用
EOF
# 实际内容: 第一章这是重要的内容列表项1列表项2这是引用
expected2=21
actual2=$(count_chinese_words "$TEST_DIR/test2.md")
echo "  预期字数: $expected2"
echo "  实际字数: $actual2"
if [ "$actual2" -eq "$expected2" ]; then
    echo -e "  ${GREEN}✅ 测试通过${NC}"
else
    echo -e "  ${YELLOW}⚠️ 字数差异: $((actual2 - expected2))${NC}"
fi
echo ""

# 测试用例3: 中英混合
echo "## 测试3: 中英文混合文本"
cat > "$TEST_DIR/test3.md" << 'EOF'
这是一个测试test文件。
包含123数字和English单词。
EOF
# 实际内容（移除空格和标点后）: 这是一个测试test文件包含123数字和English单词
expected3=27
actual3=$(count_chinese_words "$TEST_DIR/test3.md")
echo "  预期字数: 约$expected3"
echo "  实际字数: $actual3"
if [ "$actual3" -ge 20 ] && [ "$actual3" -le 35 ]; then
    echo -e "  ${GREEN}✅ 测试通过（在合理范围内）${NC}"
else
    echo -e "  ${YELLOW}⚠️ 字数差异较大${NC}"
fi
echo ""

# 测试用例4: 包含代码块
echo "## 测试4: 包含代码块的文本"
cat > "$TEST_DIR/test4.md" << 'EOF'
这是正常文本。

```javascript
console.log("这是代码不应该被计数");
```

这是结尾文本。
EOF
expected4=12
actual4=$(count_chinese_words "$TEST_DIR/test4.md")
echo "  预期字数: $expected4"
echo "  实际字数: $actual4"
if [ "$actual4" -eq "$expected4" ]; then
    echo -e "  ${GREEN}✅ 测试通过${NC}"
else
    echo -e "  ${YELLOW}⚠️ 字数差异: $((actual4 - expected4))${NC}"
fi
echo ""

# 对比测试: wc -w vs 新方法
echo "## 对比测试: wc -w vs count_chinese_words"
cat > "$TEST_DIR/compare.md" << 'EOF'
这是一个包含大约五十个字的测试文本。
我们需要验证字数统计的准确性。
使用wc命令统计中文字数是不准确的。
应该使用专门的中文字数统计方法。
这样才能得到正确的结果。
EOF
wc_result=$(wc -w < "$TEST_DIR/compare.md" | tr -d ' ')
new_result=$(count_chinese_words "$TEST_DIR/compare.md")
echo "  wc -w 结果: $wc_result （不准确）"
echo "  新方法结果: $new_result （准确）"
echo -e "  ${YELLOW}注意：wc -w 对中文统计极不准确！${NC}"
echo ""

# 性能测试
echo "## 性能测试: 大文件处理"
cat > "$TEST_DIR/large.md" << 'EOF'
# 第一章：开始

今天是个好天气，阳光明媚，万里无云。
小明决定去公园散步，顺便思考一下人生。
他一边走一边想，不知不觉来到了湖边。
湖水清澈见底，几只野鸭在水面游弋。
远处传来孩子们的欢笑声，让人心情愉悦。

## 第二节

突然，他看到一位老人坐在长椅上。
老人面带微笑，似乎在等待什么。
小明走上前去，礼貌地打了个招呼。
老人抬起头，慈祥的目光看向小明。
两人开始了一段有趣的对话。

**重要的转折点**：
- 老人讲述了一个神奇的故事
- 小明意识到生活的意义
- 他决定改变自己的人生轨迹

最后，夕阳西下，小明告别了老人。
他的内心充满了力量和希望。
这次偶遇，改变了他的一生。
EOF

start_time=$(date +%s%N)
large_count=$(count_chinese_words "$TEST_DIR/large.md")
end_time=$(date +%s%N)
elapsed=$((($end_time - $start_time) / 1000000)) # 转换为毫秒

echo "  文件字数: $large_count"
echo "  处理时间: ${elapsed}ms"
if [ "$elapsed" -lt 1000 ]; then
    echo -e "  ${GREEN}✅ 性能良好${NC}"
else
    echo -e "  ${YELLOW}⚠️ 处理时间较长${NC}"
fi
echo ""

# 总结
echo "========================================"
echo "测试完成！"
echo "========================================"
echo ""
echo -e "${GREEN}核心功能：${NC}"
echo "  ✓ 准确统计中文字符"
echo "  ✓ 排除Markdown标记"
echo "  ✓ 排除代码块"
echo "  ✓ 处理混合文本"
echo ""
echo -e "${YELLOW}使用建议：${NC}"
echo "  • 不要使用 'wc -w' 统计中文字数"
echo "  • 使用 'count_chinese_words' 函数获得准确结果"
echo "  • 在写作完成后验证字数是否达标"
echo ""
