#!/usr/bin/env pwsh
# 综合一致性检查（PowerShell）

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "未找到故事项目（stories/*）" }

$progress = Join-Path $storyDir "progress.json"
$plot = Join-Path $storyDir "spec/tracking/plot-tracker.json"
if (-not (Test-Path $plot)) { $plot = Join-Path $root "spec/tracking/plot-tracker.json" }
$timeline = Join-Path $storyDir "spec/tracking/timeline.json"
if (-not (Test-Path $timeline)) { $timeline = Join-Path $root "spec/tracking/timeline.json" }
$rels = Join-Path $storyDir "spec/tracking/relationships.json"
if (-not (Test-Path $rels)) { $rels = Join-Path $root "spec/tracking/relationships.json" }
$charState = Join-Path $storyDir "spec/tracking/character-state.json"
if (-not (Test-Path $charState)) { $charState = Join-Path $root "spec/tracking/character-state.json" }

$TOTAL=0; $PASS=0; $WARN=0; $ERR=0
function Check([string]$name, [bool]$ok, [string]$msg) {
  $script:TOTAL++
  if ($ok) { Write-Host "✓ $name" -ForegroundColor Green; $script:PASS++ }
  else { Write-Host "✗ $name: $msg" -ForegroundColor Red; $script:ERR++ }
}
function Warn([string]$msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow; $script:WARN++ }

function Check-FileIntegrity {
  Write-Host "📁 检查文件完整性"
  Write-Host "────────────────"
  Check "progress.json" (Test-Path $progress) "文件不存在"
  Check "plot-tracker.json" (Test-Path $plot) "文件不存在"
  Check "timeline.json" (Test-Path $timeline) "文件不存在"
  Check "relationships.json" (Test-Path $rels) "文件不存在"
  Check "character-state.json" (Test-Path $charState) "文件不存在"
  Write-Host ""
}

function Check-ChapterConsistency {
  Write-Host "📖 检查章节号一致性"
  Write-Host "───────────────────"
  if ((Test-Path $progress) -and (Test-Path $plot)) {
    $p = Get-Content -LiteralPath $progress -Raw -Encoding UTF8 | ConvertFrom-Json
    $j = Get-Content -LiteralPath $plot -Raw -Encoding UTF8 | ConvertFrom-Json
    $pCh = [int]($p.statistics.currentChapter ?? 0)
    $plCh = [int]($j.currentState.chapter ?? 0)
    Check "章节号同步" ($pCh -eq $plCh) "progress($pCh) != plot-tracker($plCh)"
    if (Test-Path $charState) {
      $cs = Get-Content -LiteralPath $charState -Raw -Encoding UTF8 | ConvertFrom-Json
      # 示例结构中 protagonist 字段不稳定，回退 characters->主角
      $csCh = [int]($cs.protagonist.currentStatus.chapter)
      if (-not $csCh) { $csCh = [int]($cs.characters.'主角'.lastSeen.chapter) }
      if ($csCh) { Check "角色状态章节同步" ($pCh -eq $csCh) "与character-state($csCh)不一致" }
    }
  } else { Warn "部分追踪文件缺失，无法完成章节检查" }
  Write-Host ""
}

function Check-TimelineConsistency {
  Write-Host "⏰ 检查时间线连续性"
  Write-Host "───────────────────"
  if (Test-Path $timeline) {
    $j = Get-Content -LiteralPath $timeline -Raw -Encoding UTF8 | ConvertFrom-Json
    $events = @($j.events | Sort-Object chapter)
    $issues=0; $prev=-1
    foreach ($e in $events) { if ($prev -ge 0 -and $e.chapter -le $prev) { $issues++ }; $prev=$e.chapter }
    Check "时间事件顺序" ($issues -eq 0) "发现${issues}个乱序事件"
    $curTime = $j.storyTime.current
    Check "当前时间设置" ([bool]$curTime) "当前故事时间未设置"
  } else { Warn "时间线文件不存在" }
  Write-Host ""
}

function Check-CharacterConsistency {
  Write-Host "👥 检查角色状态合理性"
  Write-Host "─────────────────────"
  if ((Test-Path $charState) -and (Test-Path $rels)) {
    $cs = Get-Content -LiteralPath $charState -Raw -Encoding UTF8 | ConvertFrom-Json
    $rel = Get-Content -LiteralPath $rels -Raw -Encoding UTF8 | ConvertFrom-Json
    $name = $cs.protagonist.name
    if (-not $name) { $name = $cs.characters.'主角'.name }
    if ($name) {
      $has = $false
      if ($rel.characters) { $has = $rel.characters.PSObject.Properties.Name -contains $name }
      Check "主角关系记录" $has "主角'$name'在relationships中无记录"
    }
    $loc = $cs.protagonist.currentStatus.location
    if (-not $loc) { $loc = $cs.characters.'主角'.location }
    Check "主角位置记录" ([bool]$loc) "主角当前位置未记录"
  } else { Warn "角色追踪文件不完整" }
  Write-Host ""
}

function Check-ForeshadowingPlan {
  Write-Host "🎯 检查伏笔管理"
  Write-Host "──────────────"
  if (Test-Path $plot) {
    $j = Get-Content -LiteralPath $plot -Raw -Encoding UTF8 | ConvertFrom-Json
    $fs = @($j.foreshadowing)
    $total = $fs.Count
    $active = @($fs | Where-Object { $_.status -eq 'active' }).Count
    Write-Host "  📊 伏笔统计: 总计${total}个，活跃${active}个"
    if ($active -gt 10) { Warn "活跃伏笔过多(${active}个)，可能造成读者困惑" }
  } else { Warn "情节追踪文件不存在" }
  Write-Host ""
}

Write-Host "═══════════════════════════════════════"
Write-Host "📊 综合一致性检查报告"
Write-Host "═══════════════════════════════════════"
Write-Host ""

Check-FileIntegrity
Check-ChapterConsistency
Check-TimelineConsistency
Check-CharacterConsistency
Check-ForeshadowingPlan

Write-Host "═══════════════════════════════════════"
Write-Host "📈 检查结果汇总"
Write-Host "───────────────────"
Write-Host "  总检查项: $TOTAL"
Write-Host "  通过: $PASS"
Write-Host "  警告: $WARN"
Write-Host "  错误: $ERR"

if ($ERR -eq 0 -and $WARN -eq 0) { Write-Host "`n✅ 完美！所有检查项全部通过" -ForegroundColor Green }
elseif ($ERR -eq 0) { Write-Host "`n⚠️  存在$WARN 个警告，建议关注" -ForegroundColor Yellow }
else { Write-Host "`n❌ 发现$ERR 个错误，需要修正" -ForegroundColor Red }

Write-Host "═══════════════════════════════════════"
Write-Host "检查时间: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

if ($ERR -gt 0) { exit 1 } else { exit 0 }

