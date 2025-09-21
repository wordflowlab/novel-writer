#!/usr/bin/env bash
# 智能写作方法助手脚本
# 用于 /method 命令

set -e

# 获取项目根目录
PROJECT_ROOT="$(pwd)"
CONFIG_FILE="${PROJECT_ROOT}/.specify/config.json"

# 检查配置文件
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 未找到项目配置文件"
    echo "请确保在小说项目目录中运行此命令"
    exit 1
fi

# 读取当前方法
CURRENT_METHOD=$(grep -o '"method"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed 's/.*"\([^"]*\)"$/\1/')

# 输出信息供 AI 使用
echo "📚 写作方法助手已启动"
echo "当前方法: ${CURRENT_METHOD:-three-act}"
echo ""
echo "可用的写作方法："
echo "- three-act: 三幕结构"
echo "- hero-journey: 英雄之旅"
echo "- story-circle: 故事圈"
echo "- seven-point: 七点结构"
echo "- pixar-formula: 皮克斯公式"
echo ""
echo "AI 接口已就绪，请通过对话了解用户需求"

# 成功退出
exit 0