#!/usr/bin/env pwsh
# 生成写作任务

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
$tasksFile = "$storyDir/tasks.md"

if (!(Test-Path $outlineFile)) {
    Write-Host "错误：没有找到章节规划"
    Write-Host "请先使用 /outline 命令创建章节规划"
    exit 1
}

Write-Host "故事目录: $storyDir"
Write-Host "规划文件: $outlineFile"
Write-Host "任务文件: $tasksFile"
Write-Host ""
Write-Host "基于章节规划生成任务："
Write-Host "- 章节写作任务"
Write-Host "- 角色完善任务"
Write-Host "- 世界观补充"
Write-Host "- 修订任务"