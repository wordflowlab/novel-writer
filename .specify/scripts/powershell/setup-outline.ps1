#!/usr/bin/env pwsh
# 设置章节规划

$STORIES_DIR = "stories"

# 查找最新的故事目录
function Get-LatestStory {
    $latest = Get-ChildItem -Path $STORIES_DIR -Directory |
              Sort-Object Name -Descending |
              Select-Object -First 1

    if ($latest) {
        return $latest.FullName
    }
    return $null
}

$storyDir = Get-LatestStory

if (!$storyDir) {
    Write-Host "错误：没有找到故事项目"
    Write-Host "请先使用 /story 命令创建故事"
    exit 1
}

$outlineFile = "$storyDir/outline.md"
$chaptersDir = "$storyDir/chapters"

# 创建章节目录
if (!(Test-Path $chaptersDir)) {
    New-Item -ItemType Directory -Path $chaptersDir | Out-Null
}

Write-Host "故事目录: $storyDir"
Write-Host "规划文件: $outlineFile"
Write-Host "准备创建章节规划..."
Write-Host ""
Write-Host "请基于故事大纲创建："
Write-Host "- 总体结构"
Write-Host "- 卷/部划分"
Write-Host "- 详细章节"
Write-Host "- 节奏控制"