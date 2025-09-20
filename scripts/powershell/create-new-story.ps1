#!/usr/bin/env pwsh
# 创建新故事项目

param(
    [string]$Json = ""
)

$STORIES_DIR = "stories"

# 创建故事目录
if (!(Test-Path $STORIES_DIR)) {
    New-Item -ItemType Directory -Path $STORIES_DIR | Out-Null
}

# 解析 JSON 参数
$storyData = @{
    name = "未命名故事"
    genre = "通用"
    description = ""
}

if ($Json) {
    try {
        $parsed = $Json | ConvertFrom-Json
        if ($parsed.name) { $storyData.name = $parsed.name }
        if ($parsed.genre) { $storyData.genre = $parsed.genre }
        if ($parsed.description) { $storyData.description = $parsed.description }
    } catch {
        Write-Host "警告：无法解析 JSON 参数，使用默认值"
    }
}

# 获取下一个编号
function Get-NextNumber {
    param([string]$Dir, [string]$Prefix)

    $maxNum = 0
    Get-ChildItem -Path $Dir -Directory | ForEach-Object {
        if ($_.Name -match "^(\d{3})-") {
            $num = [int]$Matches[1]
            if ($num -gt $maxNum) { $maxNum = $num }
        }
    }
    return $maxNum + 1
}

# 创建编号目录（参考 spec-kit 方式）
$storyNum = Get-NextNumber -Dir $STORIES_DIR -Prefix "story"
$storyNumFormatted = "{0:D3}" -f $storyNum

# 生成安全的目录名（只保留英文单词）
$safeName = $storyData.name.ToLower() -replace '[^a-z0-9]', '-' -replace '-+', '-' -replace '^-|-$', ''

# 提取前3个词
if ($safeName) {
    $words = $safeName -split '-' | Where-Object { $_ -ne '' } | Select-Object -First 3
    $safeName = $words -join '-'
}

# 如果为空（比如纯中文），使用默认名称
if (-not $safeName) {
    $safeName = "story"
}

$storyDirName = "$storyNumFormatted-$safeName"
$storyPath = "$STORIES_DIR/$storyDirName"

New-Item -ItemType Directory -Path $storyPath | Out-Null
New-Item -ItemType Directory -Path "$storyPath/chapters" | Out-Null
New-Item -ItemType Directory -Path "$storyPath/characters" | Out-Null
New-Item -ItemType Directory -Path "$storyPath/worldbuilding" | Out-Null
New-Item -ItemType Directory -Path "$storyPath/notes" | Out-Null

# 输出 JSON 结果
$result = @{
    STORY_NAME = $storyData.name
    STORY_FILE = "$storyPath/story.md"
    STORY_DIR = $storyPath
} | ConvertTo-Json -Compress

Write-Host $result