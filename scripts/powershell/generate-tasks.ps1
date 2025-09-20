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
$progressFile = "$storyDir/progress.json"

if (!(Test-Path $outlineFile)) {
    Write-Host "错误：没有找到章节规划"
    Write-Host "请先使用 /outline 命令创建章节规划"
    exit 1
}

# 获取当前日期
$currentDate = Get-Date -Format "yyyy-MM-dd"
$currentDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# 创建任务文件，预先填充基础信息
$tasksContent = @"
# 写作任务清单

## 任务概览
- **创建日期**：$currentDate
- **最后更新**：$currentDate
- **任务状态**：待生成

---
"@
$tasksContent | Out-File -FilePath $tasksFile -Encoding UTF8

# 创建或更新进度文件
if (!(Test-Path $progressFile)) {
    $progressContent = @{
        created_at = $currentDateTime
        updated_at = $currentDateTime
        total_chapters = 0
        completed = 0
        in_progress = 0
        word_count = 0
    } | ConvertTo-Json
    $progressContent | Out-File -FilePath $progressFile -Encoding UTF8
}

Write-Host "故事目录: $storyDir"
Write-Host "规划文件: $outlineFile"
Write-Host "任务文件: $tasksFile"
Write-Host "当前日期: $currentDate"
Write-Host ""
Write-Host "基于章节规划生成任务："
Write-Host "- 章节写作任务"
Write-Host "- 角色完善任务"
Write-Host "- 世界观补充"
Write-Host "- 修订任务"