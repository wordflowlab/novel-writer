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

# 从 outline.md 解析卷册信息
function Parse-VolumeInfo {
    param(
        [string]$OutlineFile,
        [int]$ChapterNum
    )

    if (Test-Path $OutlineFile) {
        $content = Get-Content $OutlineFile -Raw
        $volumeNum = 1

        # 匹配卷册和章节范围
        $pattern = '###\s+第.*?卷.*?\n[\s\S]*?章节范围.*?第(\d+)-(\d+)章'
        $matches = [regex]::Matches($content, $pattern)

        foreach ($match in $matches) {
            $startCh = [int]$match.Groups[1].Value
            $endCh = [int]$match.Groups[2].Value

            if ($ChapterNum -ge $startCh -and $ChapterNum -le $endCh) {
                return "volume-$volumeNum"
            }
            $volumeNum++
        }
    }

    # 默认规则：每60章一卷
    $volume = [math]::Floor(($ChapterNum - 1) / 60) + 1
    return "volume-$volume"
}

# 确定章节所属卷册
function Get-Volume {
    param([int]$ChapterNum)

    $outlineFile = "$storyDir/outline.md"
    return Parse-VolumeInfo -OutlineFile $outlineFile -ChapterNum $ChapterNum
}

# 获取下一个待写章节
function Get-NextChapter {
    param([string]$ChaptersDir)

    # 从 outline.md 获取总章节数
    $maxChapters = 500  # 默认最大值
    $outlineFile = "$storyDir/outline.md"

    if (Test-Path $outlineFile) {
        $content = Get-Content $outlineFile -Raw
        if ($content -match '总章节数.*?(\d+)章') {
            $maxChapters = [int]$matches[1]
        }
    }

    # 遍历所有可能的章节查找第一个未写的
    for ($i = 1; $i -le $maxChapters; $i++) {
        $volume = Get-Volume -ChapterNum $i
        $chapterNumFormatted = "{0:D3}" -f $i
        $chapterFile = "$ChaptersDir/$volume/chapter-$chapterNumFormatted.md"

        if (!(Test-Path $chapterFile)) {
            return $i
        }
    }
    return $maxChapters + 1  # 所有章节都已写完
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
$volume = Get-Volume -ChapterNum $nextChapter
$chapterNumFormatted = "{0:D3}" -f $nextChapter
$volumeDir = "$chaptersDir/$volume"

# 创建卷册目录（如果不存在）
if (!(Test-Path $volumeDir)) {
    New-Item -ItemType Directory -Path $volumeDir | Out-Null
}

$chapterFile = "$volumeDir/chapter-$chapterNumFormatted.md"

Write-Host "故事目录: $storyDir"
Write-Host "章节文件: $chapterFile"
Write-Host "当前章节: 第 $nextChapter 章 ($volume)"
Write-Host ""
Write-Host "相关文件："
if (Test-Path $styleFile) {
    Write-Host "- 创作风格: $styleFile"
}
Write-Host "- 故事大纲: $storyFile"
Write-Host "- 章节规划: $outlineFile"
Write-Host ""
Write-Host "开始写作第 $nextChapter 章..."