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

# 创建编号目录
$storyNum = Get-NextNumber -Dir $STORIES_DIR -Prefix "story"
$storyNumFormatted = "{0:D3}" -f $storyNum
$safeName = $storyData.name -replace '[^\w\-]', '_'
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