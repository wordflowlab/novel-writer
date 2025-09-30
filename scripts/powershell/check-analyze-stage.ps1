#!/usr/bin/env pwsh
# 检测 analyze 命令应该执行的阶段
# 返回 JSON 格式的阶段信息

param(
    [switch]$Json
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# 加载公共函数
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptDir "common.ps1")

# 获取项目根目录和故事目录
try {
    $projectRoot = Get-ProjectRoot
    $storyDir = Get-CurrentStoryDir
} catch {
    Write-Error "错误: $_"
    exit 1
}

if (-not $storyDir) {
    Write-Error "错误: 未找到故事目录"
    exit 1
}

# 默认返回值
$analyzeType = "content"
$chapterCount = 0
$hasSpec = $false
$hasPlan = $false
$hasTasks = $false
$reason = ""

# 检查规格文件
$specPath = Join-Path $storyDir "specification.md"
if (Test-Path $specPath) {
    $hasSpec = $true
}

# 检查计划文件
$planPath = Join-Path $storyDir "creative-plan.md"
if (Test-Path $planPath) {
    $hasPlan = $true
}

# 检查任务文件
$tasksPath = Join-Path $storyDir "tasks.md"
if (Test-Path $tasksPath) {
    $hasTasks = $true
}

# 统计章节数量
$contentDir = Join-Path $storyDir "content"
if (-not (Test-Path $contentDir)) {
    $contentDir = Join-Path $storyDir "chapters"
}

if (Test-Path $contentDir) {
    # 统计 .md 文件数量（排除索引文件）
    $chapters = Get-ChildItem -Path $contentDir -Filter "*.md" -File |
                Where-Object { $_.Name -notin @("README.md", "index.md") }
    $chapterCount = $chapters.Count
}

# 决策逻辑
if ($chapterCount -eq 0) {
    # 无章节内容 → 框架分析
    $analyzeType = "framework"
    $reason = "无章节内容，建议进行框架一致性分析"
} elseif ($chapterCount -lt 3) {
    # 章节数量不足 → 框架分析（但提示可以开始写作）
    $analyzeType = "framework"
    $reason = "章节数量较少（$chapterCount 章），建议继续写作或进行框架验证"
} else {
    # 章节充足 → 内容分析
    $analyzeType = "content"
    $reason = "已完成 $chapterCount 章，可进行内容质量分析"
}

# 输出 JSON 或人类可读格式
if ($Json) {
    # JSON 格式输出
    $output = @{
        analyze_type = $analyzeType
        chapter_count = $chapterCount
        has_spec = $hasSpec
        has_plan = $hasPlan
        has_tasks = $hasTasks
        story_dir = $storyDir
        reason = $reason
    }

    $output | ConvertTo-Json -Compress
} else {
    # 人类可读输出
    Write-Host "分析阶段检测结果"
    Write-Host "=================="
    Write-Host "故事目录: $storyDir"
    Write-Host "章节数量: $chapterCount"
    Write-Host "规格文件: $(if ($hasSpec) { '✅' } else { '❌' })"
    Write-Host "计划文件: $(if ($hasPlan) { '✅' } else { '❌' })"
    Write-Host "任务文件: $(if ($hasTasks) { '✅' } else { '❌' })"
    Write-Host ""
    Write-Host "推荐模式: $analyzeType"
    Write-Host "原因: $reason"
}
