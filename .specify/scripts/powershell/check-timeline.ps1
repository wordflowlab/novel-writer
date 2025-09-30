#!/usr/bin/env pwsh
# 时间线管理与检查（PowerShell）

param(
  [ValidateSet('show','add','check','sync')]
  [string]$Command = 'show',
  [string]$Param1,
  [string]$Param2
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "未找到故事项目（stories/*）" }

$timelinePath = Join-Path $storyDir "spec/tracking/timeline.json"
if (-not (Test-Path $timelinePath)) { $timelinePath = Join-Path $root "spec/tracking/timeline.json" }

function Init-Timeline {
  if (-not (Test-Path $timelinePath)) {
    Write-Host "⚠️  未找到时间线文件，正在创建..."
    $tpl = Join-Path $root "templates/tracking/timeline.json"
    if (-not (Test-Path $tpl)) { throw "无法找到模板文件" }
    New-Item -ItemType Directory -Path (Split-Path $timelinePath -Parent) -Force | Out-Null
    Copy-Item $tpl $timelinePath -Force
    Write-Host "✅ 时间线文件已创建"
  }
}

function Show-Timeline {
  Write-Host "📅 故事时间线"
  Write-Host "━━━━━━━━━━━━━━━━━━━━"
  if (-not (Test-Path $timelinePath)) { Write-Host "未找到时间线文件"; return }
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  $cur = $j.storyTime.current
  if (-not $cur) { $cur = '未设定' }
  Write-Host "⏰ 当前时间：$cur"
  Write-Host ""
  $events = @($j.events)
  if ($events.Count -gt 0) {
    Write-Host "📖 重要事件："
    Write-Host "───────────────"
    $events | Sort-Object chapter -Descending | Select-Object -First 5 | ForEach-Object {
      Write-Host ("第{0}章 | {1} | {2}" -f $_.chapter, $_.date, $_.event)
    }
  }
  $p = $j.parallelEvents.timepoints
  if ($p) {
    Write-Host ""
    Write-Host "🔄 并行事件："
    $p.PSObject.Properties | ForEach-Object { Write-Host ("{0}: {1}" -f $_.Name, (@($_.Value) -join ', ')) }
  }
}

function Add-Event([int]$chapter, [string]$date, [string]$event) {
  if (-not $chapter -or -not $date -or -not $event) { throw "用法: check-timeline.ps1 add <章节号> <时间> <事件描述>" }
  Init-Timeline
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $j.events) { $j | Add-Member -NotePropertyName events -NotePropertyValue @() }
  $j.events += [pscustomobject]@{ chapter=$chapter; date=$date; event=$event; duration=''; participants=@() }
  $j.events = @($j.events | Sort-Object chapter)
  $j.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $timelinePath -Encoding UTF8
  Write-Host "✅ 事件已添加：第${chapter}章 - $date - $event"
}

function Check-Continuity {
  Write-Host "🔍 检查时间线连续性"
  Write-Host "━━━━━━━━━━━━━━━━━━━━"
  if (-not (Test-Path $timelinePath)) { throw "时间线文件不存在" }
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  $chapters = @($j.events | Sort-Object chapter | ForEach-Object { $_.chapter })
  $issues = 0
  $prev = -1
  foreach ($c in $chapters) {
    if ($prev -ge 0 -and $c -le $prev) {
      Write-Host "⚠️  章节顺序异常：第$c 章出现在第$prev 章之后"
      $issues++
    }
    $prev = $c
  }
  if ($issues -eq 0) { Write-Host "`n✅ 时间线检查通过，未发现逻辑问题" }
  else { Write-Host "`n⚠️  发现${issues}个潜在问题，请检查" }
  $j.lastChecked = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  if (-not $j.anomalies) { $j | Add-Member anomalies (@{}) }
  $j.anomalies.lastCheckIssues = $issues
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $timelinePath -Encoding UTF8
}

function Sync-Parallel([string]$timepoint, [string]$eventsCsv) {
  if (-not $timepoint -or -not $eventsCsv) { throw "用法: check-timeline.ps1 sync <时间点> <事件列表,逗号分隔>" }
  Init-Timeline
  $j = Get-Content -LiteralPath $timelinePath -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $j.parallelEvents) { $j | Add-Member -NotePropertyName parallelEvents -NotePropertyValue @{ timepoints=@{} } }
  $events = $eventsCsv.Split(',').Trim()
  $j.parallelEvents.timepoints[$timepoint] = $events
  $j.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $timelinePath -Encoding UTF8
  Write-Host "✅ 并行事件已同步：$timepoint"
}

switch ($Command) {
  'show'  { Init-Timeline; Show-Timeline }
  'add'   { Add-Event -chapter ([int]$Param1) -date $Param2 -event ($args | Select-Object -Skip 2 | Out-String).Trim() }
  'check' { Check-Continuity }
  'sync'  { Sync-Parallel -timepoint $Param1 -eventsCsv $Param2 }
}

