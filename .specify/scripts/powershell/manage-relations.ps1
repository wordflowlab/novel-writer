#!/usr/bin/env pwsh
# 角色关系管理（PowerShell）

param(
  [ValidateSet('show','update','history','check')]
  [string]$Command = 'show',
  [string]$A,
  [ValidateSet('allies','enemies','romantic','neutral','family','mentors')]
  [string]$Relation,
  [string]$B,
  [int]$Chapter,
  [string]$Note
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
$relPath = $null
if ($storyDir -and (Test-Path (Join-Path $storyDir 'spec/tracking/relationships.json'))) {
  $relPath = Join-Path $storyDir 'spec/tracking/relationships.json'
} elseif (Test-Path (Join-Path $root 'spec/tracking/relationships.json')) {
  $relPath = Join-Path $root 'spec/tracking/relationships.json'
} else {
  $tpl1 = Join-Path $root '.specify/templates/tracking/relationships.json'
  $tpl2 = Join-Path $root 'templates/tracking/relationships.json'
  $dest = Join-Path $root 'spec/tracking/relationships.json'
  New-Item -ItemType Directory -Path (Split-Path $dest -Parent) -Force | Out-Null
  if (Test-Path $tpl1) { Copy-Item $tpl1 $dest -Force; $relPath = $dest }
  elseif (Test-Path $tpl2) { Copy-Item $tpl2 $dest -Force; $relPath = $dest }
  else { throw '未找到 relationships.json，且无法从模板创建' }
}

function Show-Header { Write-Host "👥 角色关系管理"; Write-Host "━━━━━━━━━━━━━━━━━━━━" }

function Show-Relations {
  Show-Header
  try { $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { throw 'relationships.json 格式无效' }
  Write-Host "文件：$relPath"; Write-Host ''
  $main = $j.characters.PSObject.Properties.Name | Select-Object -First 1
  if (-not $main) { Write-Host '无角色记录'; return }
  Write-Host "主角：$main"
  $c = $j.characters.$main
  $r = if ($c.relationships) { $c.relationships } else { $c }
  $map = @{
    romantic = '💕 爱慕'; allies='🤝 盟友'; mentors='📚 导师'; enemies='⚔️ 敌对'; family='👪 家人'; neutral='・ 关系'
  }
  foreach ($k in 'romantic','allies','mentors','enemies','family','neutral') {
    $lst = @($r.$k)
    if ($lst.Count -gt 0) { Write-Host ("├─ {0}：{1}" -f $map[$k], ($lst -join '、')) }
  }
  Write-Host ''
  if ($j.history) {
    Write-Host '最近变化：'
    $last = $j.history[-1]
    if ($last) { $last.changes | ForEach-Object { Write-Host ("- " + ($_.characters -join '↔') + "：" + ($_.relation ?? $_.type)) } }
  } elseif ($j.relationshipChanges) {
    Write-Host '最近变化：'
    $j.relationshipChanges | Select-Object -Last 5 | ForEach-Object { Write-Host ("- " + ($_.type ?? '变化') + ": " + ($_.characters -join '↔')) }
  }
}

function Ensure-Character($json, [string]$name) {
  if (-not $json.characters.$name) {
    $json.characters | Add-Member -NotePropertyName $name -NotePropertyValue (@{ name=$name; relationships=@{ allies=@(); enemies=@(); romantic=@(); family=@(); mentors=@(); neutral=@() } })
  }
}

function Update-Relation([string]$a, [string]$rel, [string]$b) {
  if (-not $a -or -not $rel -or -not $b) { throw '用法: manage-relations.ps1 update -A 人物A -Relation allies|enemies|romantic|neutral|family|mentors -B 人物B [-Chapter N] [-Note 说明]' }
  $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json
  Ensure-Character $j $a
  Ensure-Character $j $b
  $lst = @($j.characters.$a.relationships.$rel)
  if ($lst -notcontains $b) { $lst += $b }
  $j.characters.$a.relationships.$rel = $lst
  $j.lastUpdated = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  if ($j.history) {
    $chg = [pscustomobject]@{ type='update'; characters=@($a,$b); relation=$rel; note=($Note ?? '') }
    $rec = [pscustomobject]@{ chapter=($Chapter ? $Chapter : $null); date=(Get-Date).ToString('s'); changes=@($chg) }
    $j.history += $rec
  } elseif ($j.relationshipChanges) {
    $j.relationshipChanges += [pscustomobject]@{ type='update'; characters=@($a,$b); relation=$rel }
  } else {
    $j | Add-Member -NotePropertyName history -NotePropertyValue @()
  }
  $j | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $relPath -Encoding UTF8
  Write-Host "✅ 已更新关系：$a [$rel] $b"
}

function Show-History {
  Show-Header
  $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($j.history) {
    foreach ($h in $j.history) {
      $chap = if ($h.chapter) { $h.chapter } else { 0 }
      $desc = ($h.changes | ForEach-Object { ($_.characters -join '↔') + '→' + ($_.relation ?? $_.type) }) -join '；'
      Write-Host ("第{0}章：{1}" -f $chap, $desc)
    }
  } elseif ($j.relationshipChanges) {
    foreach ($h in $j.relationshipChanges) { Write-Host ((($h.date ?? '') + ' ' + ($h.type ?? '') + ': ' + ($h.characters -join '↔') + '→' + ($h.relation ?? ''))) }
  } else { Write-Host '暂无历史记录' }
}

function Check-Relations {
  Show-Header
  $j = Get-Content -LiteralPath $relPath -Raw -Encoding UTF8 | ConvertFrom-Json
  $names = @($j.characters.PSObject.Properties.Name)
  $refs = @()
  foreach ($name in $names) {
    $rel = $j.characters.$name.relationships
    if (-not $rel) { continue }
    foreach ($k in 'allies','enemies','romantic','family','mentors','neutral') {
      $refs += @($rel.$k)
    }
  }
  $refs = $refs | Where-Object { $_ } | Select-Object -Unique
  $missing = @($refs | Where-Object { $names -notcontains $_ })
  if ($missing.Count -gt 0) {
    Write-Host "⚠ 发现未建档角色引用，建议补充："
    $missing | ForEach-Object { Write-Host "  - $_" }
  } else { Write-Host "✅ 关系数据检查通过" }
}

switch ($Command) {
  'show'   { Show-Relations }
  'update' { Update-Relation -a $A -rel $Relation -b $B }
  'history'{ Show-History }
  'check'  { Check-Relations }
}

