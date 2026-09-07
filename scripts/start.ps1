# 一键启动 Ghost 博客系统（直接 node 启动，避免 ghost-cli Node 版本冲突）
# 用法: .\scripts\start.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  开源技术博客系统 - 启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RuntimeDir = Join-Path $ProjectRoot "runtime"

Write-Host "[1/5] 检查项目目录..." -ForegroundColor Yellow
if (-not (Test-Path $RuntimeDir)) {
    Write-Host "错误: runtime 目录不存在: $RuntimeDir" -ForegroundColor Red
    exit 1
}
Write-Host "  项目根目录: $ProjectRoot" -ForegroundColor Green
Write-Host "  运行目录: $RuntimeDir" -ForegroundColor Green
Write-Host ""

# 检查端口 2368
Write-Host "[2/5] 检查端口 2368..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "  警告: 端口 2368 已被占用，可能 Ghost 已在运行" -ForegroundColor Yellow
    $procId = $portInUse.OwningProcess | Select-Object -Unique
    Write-Host "  占用进程 PID: $procId" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Ghost 可能已在运行，访问 http://localhost:2368/ 验证" -ForegroundColor Green
    Write-Host "  如需重启，请先运行 .\scripts\stop.ps1" -ForegroundColor Yellow
    exit 0
}
Write-Host "  端口 2368 可用" -ForegroundColor Green
Write-Host ""

# 检查 Node.js
Write-Host "[3/5] 检查 Node.js 环境..." -ForegroundColor Yellow
$nodeVersion = node --version 2>$null
if (-not $nodeVersion) {
    Write-Host "  错误: 未找到 Node.js，请先安装 Node.js v22 LTS" -ForegroundColor Red
    exit 1
}
$nodeMajor = [int]($nodeVersion -replace 'v(\d+).*', '$1')
if ($nodeMajor -lt 22) {
    Write-Host "  警告: Node.js 版本 $nodeVersion 低于 v22，Ghost v6 可能无法正常运行" -ForegroundColor Yellow
    Write-Host "  建议安装 Node.js v22 LTS: https://nodejs.org/" -ForegroundColor Yellow
} else {
    Write-Host "  Node.js 版本: $nodeVersion (符合要求)" -ForegroundColor Green
}
Write-Host ""

# 检查 Ghost 入口文件
Write-Host "[4/5] 检查 Ghost 安装..." -ForegroundColor Yellow
$ghostEntry = Join-Path $RuntimeDir "current\index.js"
if (-not (Test-Path $ghostEntry)) {
    Write-Host "  错误: Ghost 入口文件不存在: $ghostEntry" -ForegroundColor Red
    Write-Host "  请先在 runtime 目录运行: ghost install local" -ForegroundColor Red
    exit 1
}
$dbFile = Join-Path $RuntimeDir "content\data\ghost-dev.db"
if (Test-Path $dbFile) {
    $dbSize = (Get-Item $dbFile).Length
    Write-Host "  Ghost 入口: 存在" -ForegroundColor Green
    Write-Host "  数据库: 存在 ($([math]::Round($dbSize / 1KB, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "  Ghost 入口: 存在" -ForegroundColor Green
    Write-Host "  数据库: 不存在（首次启动将自动创建）" -ForegroundColor Yellow
}
Write-Host ""

# 启动 Ghost（直接 node 后台启动）
Write-Host "[5/5] 启动 Ghost（后台运行）..." -ForegroundColor Yellow
Set-Location $RuntimeDir
$env:NODE_ENV = "development"

# 使用 Start-Process 在后台启动 node
$process = Start-Process -FilePath "node" -ArgumentList "current/index.js" -WorkingDirectory $RuntimeDir -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $RuntimeDir "content\logs\ghost-stdout.log") -RedirectStandardError (Join-Path $RuntimeDir "content\logs\ghost-stderr.log")

Write-Host "  Ghost 进程已启动，PID: $($process.Id)" -ForegroundColor Green
Write-Host ""

# 等待启动并验证
Write-Host "  等待 Ghost 启动（最多 30 秒）..." -ForegroundColor Yellow
$started = $false
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:2368/" -UseBasicParsing -TimeoutSec 3
        if ($response.StatusCode -eq 200) {
            $started = $true
            Write-Host "  Ghost 启动成功！（耗时 $($i + 1) 秒）" -ForegroundColor Green
            break
        }
    } catch {
        # 还在启动中，继续等待
    }
}

if (-not $started) {
    Write-Host "  警告: 30 秒内未检测到 Ghost 响应，请检查日志" -ForegroundColor Yellow
    Write-Host "  日志文件: $RuntimeDir\content\logs\" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  前台首页: http://localhost:2368/" -ForegroundColor White
Write-Host "  管理后台: http://localhost:2368/ghost/" -ForegroundColor White
Write-Host "  收藏列表: http://localhost:2368/bookmarks/" -ForegroundColor White
Write-Host ""
Write-Host "  管理员账号: admin@lab.local" -ForegroundColor White
Write-Host "  管理员密码: Admin@123456" -ForegroundColor White
Write-Host "  会员账号: member1@lab.local" -ForegroundColor White
Write-Host "  会员密码: Member@123456" -ForegroundColor White
Write-Host ""
Write-Host "  停止服务: .\scripts\stop.ps1" -ForegroundColor Yellow
Write-Host "  进程 PID: $($process.Id)" -ForegroundColor Yellow
Write-Host ""
