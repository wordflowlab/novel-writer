# 故事规格定义脚本
# 用于 /specify 命令

param(
    [switch]$Json,
    [string]$StoryName
)

# 导入通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目根目录
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 确定故事名称和路径
if ([string]::IsNullOrEmpty($StoryName)) {
    # 查找最新的故事
    $StoriesDir = "stories"
    if (Test-Path $StoriesDir) {
        $latestStory = Get-ChildItem $StoriesDir -Directory |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        if ($latestStory) {
            $StoryName = $latestStory.Name
        }
    }

    # 如果还是没有，生成默认名称
    if ([string]::IsNullOrEmpty($StoryName)) {
        $StoryName = "story-$(Get-Date -Format 'yyyyMMdd')"
    }
}

# 设置路径
$StoryDir = "stories\$StoryName"
$SpecFile = "$StoryDir\specification.md"
$OldStoryFile = "$StoryDir\story.md"

# 创建目录
if (-not (Test-Path $StoryDir)) {
    New-Item -ItemType Directory -Path $StoryDir -Force | Out-Null
}

# 检查文件状态
$SpecExists = $false
$OldExists = $false
$Status = "new"

if (Test-Path $SpecFile) {
    $SpecExists = $true
    $Status = "exists"
}
elseif (Test-Path $OldStoryFile) {
    $OldExists = $true
    $Status = "migrate"
}

# 输出 JSON 格式
if ($Json) {
    @{
        STORY_NAME = $StoryName
        STORY_DIR = $StoryDir
        SPEC_PATH = $SpecFile
        STATUS = $Status
        PROJECT_ROOT = $ProjectRoot
    } | ConvertTo-Json
}
else {
    Write-Host "故事规格初始化"
    Write-Host "================"
    Write-Host "故事名称：$StoryName"
    Write-Host "规格路径：$SpecFile"

    if ($SpecExists) {
        Write-Host "状态：规格文件已存在，准备更新"
    }
    elseif ($OldExists) {
        Write-Host "状态：发现旧版故事文件，建议迁移"
        Write-Host "旧文件：$OldStoryFile"
    }
    else {
        Write-Host "状态：准备创建新规格"
    }

    # 检查宪法
    if (Test-Path "memory\novel-constitution.md") {
        Write-Host ""
        Write-Host "✅ 检测到创作宪法，规格将遵循宪法原则" -ForegroundColor Green
    }
}