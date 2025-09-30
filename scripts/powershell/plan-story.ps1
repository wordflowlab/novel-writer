# 创作计划脚本
# 用于 /plan 命令

param(
    [string]$StoryName
)

# 导入通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目根目录
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 确定故事名称
if ([string]::IsNullOrEmpty($StoryName)) {
    $StoryName = Get-ActiveStory
}

$StoryDir = "stories\$StoryName"
$SpecFile = "$StoryDir\specification.md"
$ClarifyFile = "$StoryDir\clarification.md"
$PlanFile = "$StoryDir\creative-plan.md"

Write-Host "创作计划制定"
Write-Host "============"
Write-Host "故事：$StoryName"
Write-Host ""

# 检查前置文档
$missing = @()

if (-not (Test-Path "memory\novel-constitution.md")) {
    $missing += "宪法文件"
}

if (-not (Test-Path $SpecFile)) {
    $missing += "规格文件"
}

if ($missing.Count -gt 0) {
    Write-Host "⚠️ 缺少以下前置文档：" -ForegroundColor Yellow
    foreach ($doc in $missing) {
        Write-Host "  - $doc"
    }
    Write-Host ""
    Write-Host "请先完成："
    if (-not (Test-Path "memory\novel-constitution.md")) {
        Write-Host "  1. /constitution - 创建创作宪法"
    }
    if (-not (Test-Path $SpecFile)) {
        Write-Host "  2. /specify - 定义故事规格"
    }
    exit 1
}

# 检查是否有未澄清的点
if (Test-Path $SpecFile) {
    $content = Get-Content $SpecFile -Raw
    $unclearCount = ([regex]::Matches($content, '\[需要澄清\]')).Count

    if ($unclearCount -gt 0) {
        Write-Host "⚠️ 规格中有 $unclearCount 处需要澄清" -ForegroundColor Yellow
        Write-Host "建议先运行 /clarify 澄清关键决策"
        Write-Host ""
    }
}

# 检查澄清记录
if (Test-Path $ClarifyFile) {
    Write-Host "✅ 已完成澄清，将基于澄清决策制定计划" -ForegroundColor Green
}
else {
    Write-Host "📝 未找到澄清记录，将基于原始规格制定计划"
}

# 检查计划文件
if (Test-Path $PlanFile) {
    Write-Host ""
    Write-Host "📋 计划文件已存在，将更新现有计划"

    # 显示当前版本
    $planContent = Get-Content $PlanFile -Raw
    if ($planContent -match "版本：(.+)") {
        Write-Host "  当前版本：$($matches[1])"
    }
}
else {
    Write-Host ""
    Write-Host "📝 将创建新的创作计划"
}

Write-Host ""
Write-Host "计划文件路径：$PlanFile"
Write-Host ""
Write-Host "准备就绪，可以制定创作计划"