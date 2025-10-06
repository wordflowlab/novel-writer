# 小说创作宪法管理脚本
# 用于 /constitution 命令

param(
    [string]$Command = "check"
)

# 导入通用函数
. "$PSScriptRoot\common.ps1"

# 获取项目根目录
$ProjectRoot = Get-ProjectRoot
Set-Location $ProjectRoot

# 定义文件路径
$ConstitutionFile = "memory\novel-constitution.md"

switch ($Command) {
    "check" {
        # 检查宪法文件是否存在
        if (Test-Path $ConstitutionFile) {
            Write-Host "✅ 宪法文件已存在：$ConstitutionFile" -ForegroundColor Green

            # 提取版本信息
            $content = Get-Content $ConstitutionFile -Raw
            if ($content -match "- 版本：(.+)") {
                $version = $matches[1].Trim()
            } else {
                $version = "未知"
            }

            if ($content -match "- 最后修订：(.+)") {
                $updated = $matches[1].Trim()
            } else {
                $updated = "未知"
            }

            Write-Host "  版本：$version"
            Write-Host "  最后修订：$updated"
            exit 0
        }
        else {
            Write-Host "❌ 尚未创建宪法文件" -ForegroundColor Red
            Write-Host "  建议：运行 /constitution 创建创作宪法"
            exit 1
        }
    }

    "init" {
        # 初始化宪法文件
        $dir = Split-Path $ConstitutionFile -Parent
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        if (Test-Path $ConstitutionFile) {
            Write-Host "宪法文件已存在，准备更新"
        }
        else {
            Write-Host "准备创建新的宪法文件"
        }
    }

    "validate" {
        # 验证宪法文件格式
        if (-not (Test-Path $ConstitutionFile)) {
            Write-Host "错误：宪法文件不存在" -ForegroundColor Red
            exit 1
        }

        Write-Host "验证宪法文件..."

        # 检查必要章节
        $requiredSections = @("核心价值观", "质量标准", "创作风格", "内容规范", "读者契约")
        $content = Get-Content $ConstitutionFile -Raw
        $missingSections = @()

        foreach ($section in $requiredSections) {
            if ($content -notmatch "## .* $section") {
                $missingSections += $section
            }
        }

        if ($missingSections.Count -gt 0) {
            Write-Host "⚠️ 缺少以下章节：" -ForegroundColor Yellow
            foreach ($section in $missingSections) {
                Write-Host "  - $section"
            }
        }
        else {
            Write-Host "✅ 所有必要章节都存在" -ForegroundColor Green
        }

        # 检查版本信息
        if ($content -match "^- 版本：") {
            Write-Host "✅ 版本信息完整" -ForegroundColor Green
        }
        else {
            Write-Host "⚠️ 缺少版本信息" -ForegroundColor Yellow
        }
    }

    "export" {
        # 导出宪法摘要
        if (-not (Test-Path $ConstitutionFile)) {
            Write-Host "错误：宪法文件不存在" -ForegroundColor Red
            exit 1
        }

        Write-Host "# 创作宪法摘要"
        Write-Host ""

        $content = Get-Content $ConstitutionFile -Raw

        # 提取核心原则
        Write-Host "## 核心原则"
        if ($content -match "### 原则[\s\S]*?\*\*声明\*\*：(.+)") {
            Write-Host $matches[1]
        }
        else {
            Write-Host "（未找到原则声明）"
        }

        Write-Host ""
        Write-Host "## 质量底线"
        if ($content -match "### 标准[\s\S]*?\*\*要求\*\*：(.+)") {
            Write-Host $matches[1]
        }
        else {
            Write-Host "（未找到质量标准）"
        }

        Write-Host ""
        Write-Host "详细内容请查看：$ConstitutionFile"
    }

    default {
        Write-Host "未知命令：$Command" -ForegroundColor Red
        Write-Host "支持的命令：check, init, validate, export"
        exit 1
    }
}