#!/usr/bin/env pwsh
# 风格管理器（PowerShell）- 参考 Bash 版完整实现

param(
  [string]$Mode = "init"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ProjectRoot {
  # 从当前目录向上查找包含 .specify/config.json 的目录
  $current = (Get-Location).Path
  while ($true) {
    $cfg = Join-Path $current ".specify/config.json"
    if (Test-Path $cfg) { return $current }
    $parent = Split-Path $current -Parent
    if (-not $parent -or $parent -eq $current) { break }
    $current = $parent
  }
  throw "未找到小说项目根目录（缺少 .specify/config.json）"
}

function Ensure-Dir($path) {
  if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

function Ensure-File($file, $template) {
  if (-not (Test-Path $file)) {
    if ($template -and (Test-Path $template)) {
      Copy-Item $template $file -Force
    } else {
      New-Item -ItemType File -Path $file | Out-Null
    }
  }
}

$ProjectRoot = Get-ProjectRoot
$MemoryDir   = Join-Path $ProjectRoot ".specify/memory"
$SpecDir     = Join-Path $ProjectRoot "spec"
$KnowledgeDir= Join-Path $SpecDir "knowledge"
$TrackingDir = Join-Path $SpecDir "tracking"

Ensure-Dir $MemoryDir
Ensure-Dir $KnowledgeDir
Ensure-Dir $TrackingDir

function Integrate-PersonalVoice([string]$constitutionFile) {
  $pvFile = Join-Path $ProjectRoot ".specify/memory/personal-voice.md"
  if (-not (Test-Path $pvFile)) { return }

  $lines = Get-Content -LiteralPath $pvFile -Encoding UTF8
  $out = @()
  $out += ""
  $out += "## 个人语料摘要（自动引用）"
  $out += "来源：.specify/memory/personal-voice.md"
  $out += ""

  # 模拟 Bash 版：取若干个 H2 的前2条列表项
  $countSections = 0
  $take = 2
  $inSection = $false
  $takenInSection = 0
  foreach ($l in $lines) {
    if ($l -match '^## ') {
      $countSections++
      if ($countSections -gt 6) { break }
      $out += $l
      $inSection = $true
      $takenInSection = 0
      continue
    }
    if ($inSection -and $l -match '^## ') {
      $inSection = $false
      $takenInSection = 0
    }
    if ($inSection -and $l -match '^- ' -and $takenInSection -lt $take) {
      $out += $l
      $takenInSection++
    }
  }

  $constText = if (Test-Path $constitutionFile) { Get-Content -LiteralPath $constitutionFile -Raw -Encoding UTF8 } else { "" }
  if ($constText -notmatch '个人语料摘要（自动引用）') {
    Add-Content -LiteralPath $constitutionFile -Value ($out -join "`n") -Encoding UTF8
    Write-Host "    ✅ 已引用个人语料摘要"
  }
}

function Sync-PersonalBaseline([string]$constitutionFile) {
  $pvFile = Join-Path $ProjectRoot ".specify/memory/personal-voice.md"
  if (-not (Test-Path $pvFile)) { return }

  $sections = @(
    @{ title='口头禅与常用表达'; label='口头禅与常用表达'; take=6 },
    @{ title='固定句式与节奏偏好'; label='固定句式与节奏偏好'; take=6 },
    @{ title='行业/地域词汇（口音、俚语、术语）'; label='行业/地域词汇'; take=6 },
    @{ title='比喻口味与意象库'; label='比喻与意象'; take=8 },
    @{ title='写作忌口与避讳'; label='写作忌口'; take=6 }
  )

  $lines = Get-Content -LiteralPath $pvFile -Encoding UTF8

  function FetchList($title, $take) {
    $result = @()
    $hit = $false; $cnt = 0
    foreach ($l in $lines) {
      if ($l -match "^## \Q$title\E$") { $hit = $true; $cnt = 0; continue }
      if ($hit -and $l -match '^## ') { break }
      if ($hit -and $l -match '^- ' -and $cnt -lt $take) { $result += $l; $cnt++ }
    }
    return $result
  }

  $block = @()
  $block += "<!-- BEGIN: PERSONAL_BASELINE_AUTO -->"
  $block += "## 个人表达基线（自动同步）"
  $block += "来源：.specify/memory/personal-voice.md（只读镜像，修改请在源文件）"
  $block += ""
  foreach ($sec in $sections) {
    $block += "### $($sec.label)"
    $block += (FetchList $sec.title $sec.take)
    $block += ""
  }
  $block += "<!-- END: PERSONAL_BASELINE_AUTO -->"
  $blockText = ($block -join "`n")

  $constText = if (Test-Path $constitutionFile) { Get-Content -LiteralPath $constitutionFile -Raw -Encoding UTF8 } else { "" }
  if ($constText -match '<!-- BEGIN: PERSONAL_BASELINE_AUTO -->') {
    $constText = [regex]::Replace($constText, "<!-- BEGIN: PERSONAL_BASELINE_AUTO -->[\s\S]*<!-- END: PERSONAL_BASELINE_AUTO -->", [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $blockText })
  } else {
    if (-not [string]::IsNullOrWhiteSpace($constText)) { $constText += "`n" }
    $constText += $blockText
  }
  Set-Content -LiteralPath $constitutionFile -Value $constText -Encoding UTF8
  Write-Host "    ✅ 已同步个人表达基线"
}

function Init-Style {
  Write-Host "📝 初始化创作风格..."
  $constitution = Join-Path $MemoryDir "writing-constitution.md"
  $template = Join-Path $ProjectRoot ".specify/templates/writing-constitution-template.md"
  Ensure-File $constitution $template
  Integrate-PersonalVoice $constitution
  Sync-PersonalBaseline $constitution
  Write-Host "CONSTITUTION_FILE: $constitution"
  Write-Host "STATUS: ready"
  Write-Host "✅ 创作风格初始化完成"
}

function Append-Lines($path, [string[]]$lines) {
  Ensure-Dir (Split-Path $path -Parent)
  if (-not (Test-Path $path)) { New-Item -ItemType File -Path $path | Out-Null }
  Add-Content -LiteralPath $path -Value ($lines -join "`n") -Encoding UTF8
}

function Process-StyleSuggestions($data) {
  if (-not $data.suggestions -or -not $data.suggestions.style) { return }
  Write-Host "  📝 处理风格建议..."
  $items = $data.suggestions.style.items
  if (-not $items) { return }
  $constitution = Join-Path $MemoryDir "writing-constitution.md"
  $hdr = @()
  $date = (Get-Date -Format 'yyyy-MM-dd')
  $hdr += ""
  $hdr += "## 外部建议优化 ($date)"
  $hdr += ""
  $body = @()
  foreach ($it in $items) {
    $body += "### $($it.type ?? '未分类')"
    $body += "- **问题**：$($it.current)"
    $body += "- **建议**：$($it.suggestion)"
    $body += "- **预期效果**：$($it.impact)"
    $body += ""
  }
  Append-Lines $constitution ($hdr + $body)
  Write-Host "    ✅ 已更新创作准则"
}

function Process-CharacterSuggestions($data) {
  if (-not $data.suggestions -or -not $data.suggestions.characters) { return }
  Write-Host "  👥 处理角色建议..."
  $items = $data.suggestions.characters.items
  if (-not $items) { return }
  $profiles = Join-Path $KnowledgeDir "character-profiles.md"
  if (-not (Test-Path $profiles)) { return }
  $date = (Get-Date -Format 'yyyy-MM-dd')
  $lines = @("", "## 角色优化建议 ($date)", "")
  foreach ($it in $items) {
    $lines += "### $($it.character ?? '未知角色')"
    $lines += "- **问题**：$($it.issue)"
    $lines += "- **建议**：$($it.suggestion)"
    $lines += "- **发展曲线**：$($it.development_curve)"
    if ($it.chapters_affected) {
      $lines += "- **影响章节**：$((@($it.chapters_affected) -join ', '))"
    }
    $lines += ""
  }
  Append-Lines $profiles $lines
  Write-Host "    ✅ 已更新角色档案"
}

function Process-PlotSuggestions($data) {
  if (-not $data.suggestions -or -not $data.suggestions.plot) { return }
  Write-Host "  📖 处理情节建议..."
  $file = Join-Path $TrackingDir "plot-tracker.json"
  if (-not (Test-Path $file)) { return }
  $tracker = Get-Content -LiteralPath $file -Raw -Encoding UTF8 | ConvertFrom-Json
  if (-not $tracker.suggestions) { $tracker | Add-Member -NotePropertyName suggestions -NotePropertyValue @() }
  $date = (Get-Date -Format 'yyyy-MM-dd')
  foreach ($it in $data.suggestions.plot.items) {
    $tracker.suggestions += [pscustomobject]@{
      date = $date
      type = $it.type
      location = $it.location
      suggestion = $it.suggestion
      importance = ($it.importance ?? 'medium')
      status = 'pending'
    }
  }
  $tracker | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $file -Encoding UTF8
  Write-Host "    ✅ 已更新情节追踪器"
}

function Process-WorldSuggestions($data) {
  if (-not $data.suggestions -or -not $data.suggestions.worldbuilding) { return }
  Write-Host "  🌍 处理世界观建议..."
  $items = $data.suggestions.worldbuilding.items
  if (-not $items) { return }
  $file = Join-Path $KnowledgeDir "world-setting.md"
  if (-not (Test-Path $file)) { return }
  $date = (Get-Date -Format 'yyyy-MM-dd')
  $lines = @("", "## 世界观完善建议 ($date)", "")
  foreach ($it in $items) {
    $lines += "### $($it.aspect ?? '未分类')"
    $lines += "- **问题**：$($it.issue)"
    $lines += "- **建议**：$($it.suggestion)"
    if ($it.reference_chapters) {
      $lines += "- **参考章节**：$((@($it.reference_chapters) -join ', '))"
    }
    $lines += ""
  }
  Append-Lines $file $lines
  Write-Host "    ✅ 已更新世界观设定"
}

function Process-DialogueSuggestions($data) {
  if (-not $data.suggestions -or -not $data.suggestions.dialogue) { return }
  Write-Host "  💬 处理对话建议..."
  $items = $data.suggestions.dialogue.items
  if (-not $items) { return }
  $file = Join-Path $KnowledgeDir "character-voices.md"
  if (-not (Test-Path $file)) {
    Set-Content -LiteralPath $file -Value "# 角色语言规范`n`n## 通用原则`n" -Encoding UTF8
  }
  $date = (Get-Date -Format 'yyyy-MM-dd')
  $lines = @("", "## 对话优化建议 ($date)", "")
  foreach ($it in $items) {
    $lines += "### $($it.character ?? '通用')"
    $lines += "- **问题**：$($it.issue)"
    $lines += "- **建议**：$($it.suggestion)"
    if ($it.examples -and $it.alternatives) {
      $lines += "- **替换示例："
      for ($i=0; $i -lt $it.examples.Count; $i++) {
        $ex = $it.examples[$i]
        $alt = if ($i -lt $it.alternatives.Count) { $it.alternatives[$i] } else { $null }
        if ($alt) { $lines += "  - $ex → $alt" }
      }
    }
    $lines += ""
  }
  Append-Lines $file $lines
  Write-Host "    ✅ 已更新角色语言规范"
}

function Parse-JsonSuggestions([string]$jsonText) {
  try { $data = $jsonText | ConvertFrom-Json } catch { throw "JSON格式无效" }
  $source = if ($data.source) { $data.source } else { 'Unknown' }
  $date = if ($data.analysis_date) { $data.analysis_date } else { (Get-Date -Format 'yyyy-MM-dd') }
  Write-Host "📊 解析来自 $source 的建议 ($date)"
  Process-StyleSuggestions $data
  Process-CharacterSuggestions $data
  Process-PlotSuggestions $data
  Process-WorldSuggestions $data
  Process-DialogueSuggestions $data
}

function Parse-MarkdownSuggestions([string]$md) {
  Write-Host "📊 解析Markdown格式建议..."
  # 简化：提取“写作风格建议”与“角色优化建议”两个区块
  $constitution = Join-Path $MemoryDir "writing-constitution.md"
  $profiles = Join-Path $KnowledgeDir "character-profiles.md"
  $date = (Get-Date -Format 'yyyy-MM-dd')

  if ($md -match "## 写作风格建议") {
    $lines = @("", "## 外部建议优化 ($date)", "")
    $segment = ($md -split "## 写作风格建议")[1]
    if ($segment) { $segment = ($segment -split "\n## ")[0] }
    if ($segment) { $lines += ($segment.TrimEnd()).Split("`n") }
    Append-Lines $constitution $lines
    Write-Host "    ✅ 已更新创作准则"
  }

  if ((Test-Path $profiles) -and ($md -match "## 角色优化建议")) {
    $lines = @("", "## 外部优化建议 ($date)", "")
    $segment = ($md -split "## 角色优化建议")[1]
    if ($segment) { $segment = ($segment -split "\n## ")[0] }
    if ($segment) { $lines += ($segment.TrimEnd()).Split("`n") }
    Append-Lines $profiles $lines
    Write-Host "    ✅ 已更新角色档案"
  }
}

function Update-ImprovementLog([string]$source, [string]$summary) {
  $log = Join-Path $KnowledgeDir "improvement-log.md"
  if (-not (Test-Path $log)) {
    Set-Content -LiteralPath $log -Value "# 改进建议历史`n`n记录所有外部AI建议和采纳情况。`n" -Encoding UTF8
  }
  $lines = @()
  $lines += ""
  $lines += "## $(Get-Date -Format 'yyyy-MM-dd') - $source"
  $lines += ""
  $lines += "### 建议摘要"
  $lines += $summary
  $lines += ""
  $lines += "### 采纳状态"
  $lines += "- [x] 已自动整合到规范文件"
  $lines += "- [ ] 待人工审核确认"
  $lines += "- [ ] 待实施修订"
  $lines += ""
  $lines += "### 影响文件"
  $lines += "- writing-constitution.md"
  if (Test-Path (Join-Path $KnowledgeDir "character-profiles.md")) { $lines += "- character-profiles.md" }
  if (Test-Path (Join-Path $TrackingDir "plot-tracker.json")) { $lines += "- plot-tracker.json" }
  if (Test-Path (Join-Path $KnowledgeDir "world-setting.md")) { $lines += "- world-setting.md" }
  if (Test-Path (Join-Path $KnowledgeDir "character-voices.md")) { $lines += "- character-voices.md" }
  $lines += ""
  $lines += "---"
  Append-Lines $log $lines
}

function Refine-Style {
  Write-Host "🔄 开始整合外部建议..."
  $text = $null
  # 读取管道或参数
  if ($MyInvocation.ExpectingInput) {
    $text = ($input | Out-String)
  } elseif ($args.Count -gt 0) {
    $text = [string]::Join(' ', $args)
  }
  if (-not $text -or [string]::IsNullOrWhiteSpace($text)) { throw "请提供建议内容" }

  $isJson = ($text -match '"version"') -and ($text -match '"suggestions"')
  if ($isJson) {
    Write-Host "检测到JSON格式"
    Parse-JsonSuggestions $text
    Update-ImprovementLog "外部AI" "已处理JSON格式建议"
  } elseif ($text -match '# 小说创作建议报告') {
    Write-Host "检测到Markdown格式"
    Parse-MarkdownSuggestions $text
    Update-ImprovementLog "外部AI" "已处理Markdown格式建议"
  } else {
    throw "无法识别建议格式。请使用标准JSON或Markdown格式（参考 docs/ai-suggestion-prompt-template.md）"
  }

  Write-Host ""
  Write-Host "✅ 建议整合完成"
  Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  Write-Host "📊 整合报告："
  # 简化统计：列出近 2 分钟内修改的文件数
  $changed = Get-ChildItem $MemoryDir, $KnowledgeDir, $TrackingDir -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-2) }
  Write-Host "  - 更新文件：$($changed.Count) 个"
  Write-Host "  - 建议来源：外部AI分析"
  Write-Host "  - 处理时间：$(Get-Date -Format 'HH:mm:ss')"
  Write-Host ""
}

switch ($Mode.ToLower()) {
  'init'   { Init-Style }
  'refine' { Refine-Style }
  default  { throw "未知模式：$Mode（可用：init, refine）" }
}

