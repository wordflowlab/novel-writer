#!/usr/bin/env pwsh
# 综合追踪小说创作进度（PowerShell）

param(
  [switch]$check,
  [switch]$fix,
  [switch]$brief,
  [switch]$plot,
  [switch]$stats
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
$progress = Join-Path $root "stories/current/progress.json"
$plotPath = Join-Path $root "spec/tracking/plot-tracker.json"

function Show-BasicReport {
  Write-Host "📊 小说创作综合报告"
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if (Test-Path $progress) {
    Write-Host "✍️ 写作进度"
    Write-Host "  完成情况等待分析..."
  }
  if (Test-Path $plotPath) {
    Write-Host "📍 情节状态"
    Write-Host "  主线进度等待分析..."
  }
}

function Run-DeepCheck {
  Write-Host "🔍 执行深度验证..."
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "Phase 1: 基础验证"
  Write-Host "  [P] 执行情节一致性检查..."
  Write-Host "  [P] 执行时间线验证..."
  Write-Host "  [P] 执行关系验证..."
  Write-Host "  [P] 执行世界观验证..."
  Write-Host "Phase 2: 角色深度验证"
  $rules = Join-Path $root "spec/tracking/validation-rules.json"
  if (Test-Path $rules) {
    Write-Host "  ✅ 加载验证规则"
    Set-Content -LiteralPath "$env:TEMP/validation-tasks.md" -Encoding UTF8 -Value @"
# 验证任务 (自动生成)

## Phase 1: 基础验证 [并行]
- [ ] T001 [P] 执行情节一致性检查
- [ ] T002 [P] 执行时间线验证
- [ ] T003 [P] 执行关系验证
- [ ] T004 [P] 执行世界观验证

## Phase 2: 角色验证
- [ ] T005 加载validation-rules.json
- [ ] T006 扫描章节角色名称
- [ ] T007 验证名称一致性
- [ ] T008 检查称呼准确性
- [ ] T009 验证行为一致性

## Phase 3: 生成报告
- [ ] T010 汇总结果
- [ ] T011 标记问题
- [ ] T012 生成建议
"@
    Write-Host "  ✅ 验证任务已生成"
  } else {
    Write-Host "  ⚠️ 未找到验证规则文件"
  }
  Write-Host "📊 深度验证报告"
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "AI将分析所有章节并生成详细报告..."
  Write-Host "💡 提示：发现问题后可运行 --fix 自动修复"
}

function Run-AutoFix {
  Write-Host "🔧 执行自动修复..."
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Set-Content -LiteralPath "$env:TEMP/fix-tasks.md" -Encoding UTF8 -Value @"
# 修复任务 (自动生成)

## Phase 1: 简单修复 [可自动]
- [ ] F001 读取验证报告
- [ ] F002 [P] 修复角色名称错误
- [ ] F003 [P] 修复称呼错误
- [ ] F004 [P] 修复简单拼写

## Phase 2: 生成报告
- [ ] F005 汇总修复结果
- [ ] F006 更新追踪文件
"@
  Write-Host "🔧 自动修复报告"
  Write-Host "━━━━━━━━━━━━━━━━━━━"
  Write-Host "AI将自动修复简单问题..."
}

if ($check) { Run-DeepCheck }
elseif ($fix) { Run-AutoFix }
else { Show-BasicReport }

Write-Host ""
Write-Host "✅ 追踪分析完成"

