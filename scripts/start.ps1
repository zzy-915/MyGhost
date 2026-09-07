# 一键启动 Ghost 博客系统
# 用法: .\scripts\start.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  开源技术博客系统 - 启动脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RuntimeDir = Join-Path $ProjectRoot "runtime"

Write-Host "[1/4] 检查项目目录..." -ForegroundColor Yellow
if (-not (Test-Path $RuntimeDir)) {
    Write-Host "错误: runtime 目录不存在: $RuntimeDir" -ForegroundColor Red
    exit 1
}
Write-Host "  项目根目录: $ProjectRoot" -ForegroundColor Green
Write-Host "  运行目录: $RuntimeDir" -ForegroundColor Green
Write-Host ""

# 检查端口 2368
Write-Host "[2/4] 检查端口 2368..." -ForegroundColor Yellow
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
Write-Host "[3/4] 检查 Node.js 环境..." -ForegroundColor Yellow
$nodeVersion = node --version 2>$null
if (-not $nodeVersion) {
    Write-Host "  错误: 未找到 Node.js，请先安装 Node.js v22 LTS" -ForegroundColor Red
    exit 1
}
Write-Host "  Node.js 版本: $nodeVersion" -ForegroundColor Green

# 检查 Ghost CLI
$ghostVersion = ghost --version 2>$null
if (-not $ghostVersion) {
    Write-Host "  警告: 未找到 Ghost CLI，尝试使用 npx..." -ForegroundColor Yellow
} else {
    Write-Host "  Ghost CLI: $ghostVersion" -ForegroundColor Green
}
Write-Host ""

# 启动 Ghost
Write-Host "[4/4] 启动 Ghost..." -ForegroundColor Yellow
Set-Location $RuntimeDir
ghost start

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
Write-Host "  会员账号: member1@lab.local" -ForegroundColor White
Write-Host ""
Write-Host "  停止服务: .\scripts\stop.ps1" -ForegroundColor Yellow
Write-Host "  查看状态: ghost ls" -ForegroundColor Yellow
Write-Host ""
