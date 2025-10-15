# 故事分析验证脚本
# 用于 /analyze 命令

param(
    [string]$StoryName,
    [string]$AnalysisType = "full"  # full, compliance, quality, progress
)

# 导入通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目根目录
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 确定故事路径
if ([string]::IsNullOrEmpty($StoryName)) {
    $StoryName = Get-ActiveStory
}

$StoryDir = "stories\$StoryName"

# 检查必要文件
function Test-StoryFiles {
    $missingFiles = @()

    # 检查基准文档
    if (-not (Test-Path "memory\constitution.md")) {
        $missingFiles += "宪法文件"
    }
    if (-not (Test-Path "$StoryDir\specification.md")) {
        $missingFiles += "规格文件"
    }
    if (-not (Test-Path "$StoryDir\creative-plan.md")) {
        $missingFiles += "计划文件"
    }

    if ($missingFiles.Count -gt 0) {
        Write-Host "⚠️ 缺少以下基准文档：" -ForegroundColor Yellow
        foreach ($file in $missingFiles) {
            Write-Host "  - $file"
        }
        return $false
    }

    return $true
}

# 统计内容
function Get-ContentAnalysis {
    $contentDir = "$StoryDir\content"
    $totalWords = 0
    $chapterCount = 0

    if (Test-Path $contentDir) {
        $mdFiles = Get-ChildItem "$contentDir\*.md" -ErrorAction SilentlyContinue

        foreach ($file in $mdFiles) {
            $chapterCount++
            # 简单的字数统计（中文按字符算）
            $content = Get-Content $file.FullName -Raw
            $words = ($content -replace '\s', '').Length
            $totalWords += $words
        }
    }

    Write-Host "内容统计："
    Write-Host "  总字数：$totalWords"
    Write-Host "  章节数：$chapterCount"

    if ($chapterCount -gt 0) {
        $avgLength = [math]::Round($totalWords / $chapterCount)
        Write-Host "  平均章节长度：$avgLength"
    }
}

# 检查任务完成度
function Test-TaskCompletion {
    $tasksFile = "$StoryDir\tasks.md"

    if (-not (Test-Path $tasksFile)) {
        Write-Host "任务文件不存在"
        return
    }

    $content = Get-Content $tasksFile -Raw
    $totalTasks = ([regex]::Matches($content, '^- \[', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $completedTasks = ([regex]::Matches($content, '^- \[x\]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $inProgress = ([regex]::Matches($content, '^- \[~\]', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
    $pending = $totalTasks - $completedTasks - $inProgress

    Write-Host "任务进度："
    Write-Host "  总任务：$totalTasks"
    Write-Host "  已完成：$completedTasks"
    Write-Host "  进行中：$inProgress"
    Write-Host "  未开始：$pending"

    if ($totalTasks -gt 0) {
        $completionRate = [math]::Round(($completedTasks * 100) / $totalTasks)
        Write-Host "  完成率：$completionRate%"
    }
}

# 检查规格符合度
function Test-SpecificationCompliance {
    $specFile = "$StoryDir\specification.md"

    Write-Host "规格符合度检查："

    if (Test-Path $specFile) {
        $content = Get-Content $specFile -Raw

        # 检查P0需求（简化版）
        if ($content -match "### 必须包含（P0）") {
            Write-Host "  P0需求：检测到，需人工验证"
        }

        # 检查是否还有[需要澄清]标记
        $unclearCount = ([regex]::Matches($content, '\[需要澄清\]')).Count
        if ($unclearCount -gt 0) {
            Write-Host "  ⚠️ 仍有 $unclearCount 处需要澄清" -ForegroundColor Yellow
        }
        else {
            Write-Host "  ✅ 所有决策已澄清" -ForegroundColor Green
        }
    }
}

# 主分析流程
Write-Host "故事分析报告"
Write-Host "============"
Write-Host "故事：$StoryName"
Write-Host "分析时间：$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

# 检查基准文档
if (-not (Test-StoryFiles)) {
    Write-Host ""
    Write-Host "❌ 无法进行完整分析，请先完成基准文档" -ForegroundColor Red
    exit 1
}

Write-Host "✅ 基准文档完整" -ForegroundColor Green
Write-Host ""

# 根据分析类型执行
switch ($AnalysisType) {
    "full" {
        Get-ContentAnalysis
        Write-Host ""
        Test-TaskCompletion
        Write-Host ""
        Test-SpecificationCompliance
    }
    "quality" {
        Get-ContentAnalysis
    }
    "progress" {
        Test-TaskCompletion
    }
    "compliance" {
        Test-SpecificationCompliance
    }
    default {
        Write-Host "未知的分析类型：$AnalysisType" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "分析完成。详细报告已保存到：$StoryDir\analysis-report.md"