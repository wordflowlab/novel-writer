#!/usr/bin/env pwsh
# 写作章节内容

$STORIES_DIR = "stories"
$MEMORY_DIR = "memory"

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

# 获取下一个待写章节
function Get-NextChapter {
    param([string]$ChaptersDir)

    $maxNum = 0
    if (Test-Path $ChaptersDir) {
        Get-ChildItem -Path $ChaptersDir -Filter "*.md" | ForEach-Object {
            if ($_.BaseName -match "chapter-(\d+)") {
                $num = [int]$Matches[1]
                if ($num -gt $maxNum) { $maxNum = $num }
            }
        }
    }
    return $maxNum + 1
}

$storyDir = Get-LatestStory

if (!$storyDir) {
    Write-Host "错误：没有找到故事项目"
    exit 1
}

$chaptersDir = "$storyDir/chapters"
$outlineFile = "$storyDir/outline.md"
$storyFile = "$storyDir/story.md"
$styleFile = "$MEMORY_DIR/writing-constitution.md"

# 检查必要文件
if (!(Test-Path $outlineFile)) {
    Write-Host "错误：没有找到章节规划"
    Write-Host "请先使用 /outline 命令创建章节规划"
    exit 1
}

$nextChapter = Get-NextChapter -ChaptersDir $chaptersDir
$chapterFile = "$chaptersDir/chapter-$nextChapter.md"

Write-Host "故事目录: $storyDir"
Write-Host "章节文件: $chapterFile"
Write-Host "当前章节: 第 $nextChapter 章"
Write-Host ""
Write-Host "相关文件："
if (Test-Path $styleFile) {
    Write-Host "- 创作风格: $styleFile"
}
Write-Host "- 故事大纲: $storyFile"
Write-Host "- 章节规划: $outlineFile"
Write-Host ""
Write-Host "开始写作第 $nextChapter 章..."