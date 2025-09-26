#!/usr/bin/env pwsh
# 公用函数（PowerShell）

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ProjectRoot {
  $current = (Get-Location).Path
  while ($true) {
    $cfg = Join-Path $current ".specify/config.json"
    if (Test-Path $cfg) { return $current }
    $parent = Split-Path $current -Parent
    if (-not $parent -or $parent -eq $current) { break }
    $current = $parent
  }
  throw "未找到项目根目录（缺少 .specify/config.json）"
}

function Get-CurrentStoryDir {
  $root = Get-ProjectRoot
  $stories = Join-Path $root "stories"
  if (-not (Test-Path $stories)) { return $null }
  $dirs = Get-ChildItem -Path $stories -Directory | Sort-Object LastWriteTime -Descending
  if ($dirs.Count -gt 0) { return $dirs[0].FullName }
  return $null
}

