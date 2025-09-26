#!/usr/bin/env pwsh
# 初始化追踪系统（PowerShell）

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/common.ps1"

Write-Host "🚀 初始化追踪系统..."

$root = Get-ProjectRoot
$storyDir = Get-CurrentStoryDir
if (-not $storyDir) { throw "请先完成 /story 和 /outline，未找到 stories/*/ 目录" }

$storyName = Split-Path $storyDir -Leaf
$specTrack = Join-Path $root "spec/tracking"
New-Item -ItemType Directory -Path $specTrack -Force | Out-Null

Write-Host "📖 为《$storyName》初始化追踪系统..."

$utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

# plot-tracker.json
$plotPath = Join-Path $specTrack "plot-tracker.json"
if (-not (Test-Path $plotPath)) {
  Write-Host "📝 创建 plot-tracker.json..."
  $plot = @{
    novel = $storyName
    lastUpdated = $utc
    currentState = @{ chapter = 0; volume = 1; mainPlotStage = '准备阶段'; location = '待定'; timepoint = '故事开始前' }
    plotlines = @{ main = @{ name='主线剧情'; description='待从大纲提取'; status='待开始'; currentNode='起点'; completedNodes=@(); upcomingNodes=@(); plannedClimax=@{ chapter=$null; description='待规划' } }; subplots=@() }
    foreshadowing = @()
    conflicts = @{ active=@(); resolved=@(); upcoming=@() }
    checkpoints = @{ volumeEnd=@(); majorEvents=@() }
    notes = @{ plotHoles=@(); inconsistencies=@(); reminders=@('请根据实际故事内容更新追踪数据') }
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $plotPath -Value $plot -Encoding UTF8
}

# timeline.json
$timelinePath = Join-Path $specTrack "timeline.json"
if (-not (Test-Path $timelinePath)) {
  Write-Host "⏰ 创建 timeline.json..."
  $timeline = @{
    novel = $storyName
    lastUpdated = $utc
    storyTimeUnit = '天'
    realWorldReference = $null
    timeline = @(@{ chapter=0; storyTime='第0天'; description='故事开始前'; events=@('待添加'); location='待定' })
    parallelEvents = @()
    timeSpan = @{ start='第0天'; current='第0天'; elapsed='0天' }
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $timelinePath -Value $timeline -Encoding UTF8
}

# relationships.json
$relationsPath = Join-Path $specTrack "relationships.json"
if (-not (Test-Path $relationsPath)) {
  Write-Host "👥 创建 relationships.json..."
  $relations = @{
    novel = $storyName
    lastUpdated = $utc
    characters = @{ '主角' = @{ name='待设定'; relationships=@{ allies=@(); enemies=@(); romantic=@(); neutral=@() } } }
    factions = @{}
    relationshipChanges = @()
    currentTensions = @()
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $relationsPath -Value $relations -Encoding UTF8
}

# character-state.json
$charStatePath = Join-Path $specTrack "character-state.json"
if (-not (Test-Path $charStatePath)) {
  Write-Host "📍 创建 character-state.json..."
  $cs = @{
    novel = $storyName
    lastUpdated = $utc
    characters = @{ '主角' = @{ name='待设定'; status='健康'; location='待定'; possessions=@(); skills=@(); lastSeen=@{ chapter=0; description='尚未出场' }; development=@{ physical=0; mental=0; emotional=0; power=0 } } }
    groupPositions = @{}
    importantItems = @{}
  } | ConvertTo-Json -Depth 12
  Set-Content -LiteralPath $charStatePath -Value $cs -Encoding UTF8
}

Write-Host ""
Write-Host "✅ 追踪系统初始化完成！"
Write-Host ""
Write-Host "📊 已创建以下追踪文件："
Write-Host "   • spec/tracking/plot-tracker.json - 情节追踪"
Write-Host "   • spec/tracking/timeline.json - 时间线管理"
Write-Host "   • spec/tracking/relationships.json - 关系网络"
Write-Host "   • spec/tracking/character-state.json - 角色状态"
Write-Host ""
Write-Host "💡 下一步："
Write-Host "   1. 使用 /write 开始创作（会自动更新追踪数据）"
Write-Host "   2. 定期使用 /track 查看综合报告"
Write-Host "   3. 使用 /plot-check 等命令进行一致性检查"

