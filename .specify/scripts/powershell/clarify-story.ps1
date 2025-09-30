param(
    [switch]$Json,
    [switch]$PathsOnly
)

# 澄清故事大纲的支撑脚本
# 用于 /clarify 命令，扫描并返回当前故事路径

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Source common functions
. "$ScriptDir\common.ps1"

# Get project root
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# Find the current story directory
$StoriesDir = "stories"
if (-not (Test-Path $StoriesDir -PathType Container)) {
    if ($Json) {
        Write-Output '{"error": "No stories directory found"}'
    } else {
        Write-Error "错误：未找到 stories 目录，请先运行 /story 创建故事大纲"
    }
    exit 1
}

# Get the latest story
$StoryDirs = Get-ChildItem -Path $StoriesDir -Directory | Sort-Object Name -Descending
if ($StoryDirs.Count -eq 0) {
    if ($Json) {
        Write-Output '{"error": "No story found"}'
    } else {
        Write-Error "错误：未找到故事，请先运行 /story 创建故事大纲"
    }
    exit 1
}

$StoryDir = $StoryDirs[0]
$StoryName = $StoryDir.Name

# Find story file (新格式 specification.md)
$StoryFile = Join-Path $StoryDir.FullName "specification.md"
if (-not (Test-Path $StoryFile -PathType Leaf)) {
    if ($Json) {
        Write-Output '{"error": "Story file not found (specification.md required)"}'
    } else {
        Write-Error "错误：未找到故事文件 specification.md"
    }
    exit 1
}

# Check if clarification already exists
$ClarificationExists = $false
$StoryContent = Get-Content $StoryFile -Raw
if ($StoryContent -match "## 澄清记录") {
    $ClarificationExists = $true
}

# Count existing clarification sessions
$ClarificationCount = 0
if ($ClarificationExists) {
    $matches = [regex]::Matches($StoryContent, "### 澄清会话")
    $ClarificationCount = $matches.Count
}

# Convert paths to forward slashes for JSON
$StoryFilePath = $StoryFile.Replace('\', '/')
$StoryDirPath = $StoryDir.FullName.Replace('\', '/')
$ProjectRootPath = $ProjectRoot.Replace('\', '/')

# Output in JSON format if requested
if ($Json) {
    if ($PathsOnly) {
        # Minimal output for command template
        $output = @{
            STORY_PATH = $StoryFilePath
            STORY_NAME = $StoryName
            STORY_DIR = $StoryDirPath
        }
    } else {
        # Full output for analysis
        $output = @{
            STORY_PATH = $StoryFilePath
            STORY_NAME = $StoryName
            STORY_DIR = $StoryDirPath
            CLARIFICATION_EXISTS = $ClarificationExists
            CLARIFICATION_COUNT = $ClarificationCount
            PROJECT_ROOT = $ProjectRootPath
        }
    }
    Write-Output (ConvertTo-Json $output -Compress)
} else {
    Write-Output "找到故事：$StoryName"
    Write-Output "文件路径：$StoryFile"
    if ($ClarificationExists) {
        Write-Output "已有澄清会话：$ClarificationCount 次"
    } else {
        Write-Output "尚未进行过澄清"
    }
}