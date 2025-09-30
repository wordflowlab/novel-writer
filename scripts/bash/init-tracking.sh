#!/bin/bash

echo "🚀 初始化追踪系统..."

# 检查前置条件
story_exists=false
outline_exists=false

# 查找 specification 文件
if ls stories/*/specification.md 1> /dev/null 2>&1; then
    story_exists=true
    story_file=$(ls stories/*/specification.md | head -1)
fi

# 查找 outline 文件
if ls stories/*/outline.md 1> /dev/null 2>&1; then
    outline_exists=true
    outline_file=$(ls stories/*/outline.md | head -1)
fi

if [ "$story_exists" = false ] || [ "$outline_exists" = false ]; then
    echo "❌ 请先完成 /specify 和 /plan 命令"
    echo "   缺少: ${story_exists:+}${story_exists:-specification.md} ${outline_exists:+}${outline_exists:-outline.md}"
    exit 1
fi

# 创建追踪目录
mkdir -p spec/tracking

# 获取故事名称
story_dir=$(dirname "$story_file")
story_name=$(basename "$story_dir")

echo "📖 为《${story_name}》初始化追踪系统..."

# 初始化 plot-tracker.json
if [ ! -f "spec/tracking/plot-tracker.json" ]; then
    echo "📝 创建 plot-tracker.json..."
    cat > spec/tracking/plot-tracker.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "currentState": {
    "chapter": 0,
    "volume": 1,
    "mainPlotStage": "准备阶段",
    "location": "待定",
    "timepoint": "故事开始前"
  },
  "plotlines": {
    "main": {
      "name": "主线剧情",
      "description": "待从大纲提取",
      "status": "待开始",
      "currentNode": "起点",
      "completedNodes": [],
      "upcomingNodes": [],
      "plannedClimax": {
        "chapter": null,
        "description": "待规划"
      }
    },
    "subplots": []
  },
  "foreshadowing": [],
  "conflicts": {
    "active": [],
    "resolved": [],
    "upcoming": []
  },
  "checkpoints": {
    "volumeEnd": [],
    "majorEvents": []
  },
  "notes": {
    "plotHoles": [],
    "inconsistencies": [],
    "reminders": ["请根据实际故事内容更新追踪数据"]
  }
}
EOF
fi

# 初始化 timeline.json
if [ ! -f "spec/tracking/timeline.json" ]; then
    echo "⏰ 创建 timeline.json..."
    cat > spec/tracking/timeline.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "storyTimeUnit": "天",
  "realWorldReference": null,
  "timeline": [
    {
      "chapter": 0,
      "storyTime": "第0天",
      "description": "故事开始前",
      "events": ["待添加"],
      "location": "待定"
    }
  ],
  "parallelEvents": [],
  "timeSpan": {
    "start": "第0天",
    "current": "第0天",
    "elapsed": "0天"
  }
}
EOF
fi

# 初始化 relationships.json
if [ ! -f "spec/tracking/relationships.json" ]; then
    echo "👥 创建 relationships.json..."
    cat > spec/tracking/relationships.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "characters": {
    "主角": {
      "name": "待设定",
      "relationships": {
        "allies": [],
        "enemies": [],
        "romantic": [],
        "neutral": []
      }
    }
  },
  "factions": {},
  "relationshipChanges": [],
  "currentTensions": []
}
EOF
fi

# 初始化 character-state.json
if [ ! -f "spec/tracking/character-state.json" ]; then
    echo "📍 创建 character-state.json..."
    cat > spec/tracking/character-state.json <<EOF
{
  "novel": "${story_name}",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "characters": {
    "主角": {
      "name": "待设定",
      "status": "健康",
      "location": "待定",
      "possessions": [],
      "skills": [],
      "lastSeen": {
        "chapter": 0,
        "description": "尚未出场"
      },
      "development": {
        "physical": 0,
        "mental": 0,
        "emotional": 0,
        "power": 0
      }
    }
  },
  "groupPositions": {},
  "importantItems": {}
}
EOF
fi

echo ""
echo "✅ 追踪系统初始化完成！"
echo ""
echo "📊 已创建以下追踪文件："
echo "   • spec/tracking/plot-tracker.json - 情节追踪"
echo "   • spec/tracking/timeline.json - 时间线管理"
echo "   • spec/tracking/relationships.json - 关系网络"
echo "   • spec/tracking/character-state.json - 角色状态"
echo ""
echo "💡 下一步："
echo "   1. 使用 /write 开始创作（会自动更新追踪数据）"
echo "   2. 定期使用 /track 查看综合报告"
echo "   3. 使用 /plot-check 等命令进行一致性检查"
echo ""
echo "📝 提示：追踪文件已预填充基础结构，会在写作过程中自动更新"