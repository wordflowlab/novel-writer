#!/usr/bin/env pwsh
# 智能写作方法助手脚本（PowerShell）

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = (Get-Location).Path
$configPath = Join-Path $projectRoot ".specify/config.json"

if (-not (Test-Path $configPath)) {
  Write-Host "❌ 未找到项目配置文件"
  Write-Host "请在小说项目目录中运行此命令"
  exit 1
}

$json = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$currentMethod = $json.method.current

Write-Host "📚 写作方法助手已启动"
Write-Host "当前方法: $($currentMethod ?? 'three-act')"
Write-Host ""
Write-Host "可用的写作方法："
Write-Host "- three-act: 三幕结构"
Write-Host "- hero-journey: 英雄之旅"
Write-Host "- story-circle: 故事圈"
Write-Host "- seven-point: 七点结构"
Write-Host "- pixar-formula: 皮克斯公式"
Write-Host "- snowflake: 雪花十步法"
Write-Host ""
Write-Host "AI 接口已就绪，请通过对话了解用户需求"

exit 0

