#!/usr/bin/env pwsh
# 设定创作风格和准则

$MEMORY_DIR = ".specify/memory"

# 创建内存目录
if (!(Test-Path $MEMORY_DIR)) {
    New-Item -ItemType Directory -Path $MEMORY_DIR | Out-Null
    Write-Host "创建 $MEMORY_DIR 目录"
}

$STYLE_FILE = "$MEMORY_DIR/writing-constitution.md"

# 检查文件是否存在
if (Test-Path $STYLE_FILE) {
    Write-Host "更新创作风格文件: $STYLE_FILE"
} else {
    Write-Host "创建创作风格文件: $STYLE_FILE"
}

Write-Host "准备填充创作风格内容..."
Write-Host "请根据用户描述设定："
Write-Host "- 叙事视角"
Write-Host "- 文字风格"
Write-Host "- 创作原则"
Write-Host "- 质量标准"