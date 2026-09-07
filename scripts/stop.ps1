# 一键停止 Ghost 博客系统
# 用法: .\scripts\stop.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  开源技术博客系统 - 停止脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$RuntimeDir = Join-Path $ProjectRoot "runtime"

Write-Host "[1/3] 检查项目目录..." -ForegroundColor Yellow
if (-not (Test-Path $RuntimeDir)) {
    Write-Host "错误: runtime 目录不存在: $RuntimeDir" -ForegroundColor Red
    exit 1
}
Write-Host "  运行目录: $RuntimeDir" -ForegroundColor Green
Write-Host ""

# 检查 Ghost 是否在运行
Write-Host "[2/3] 检查 Ghost 运行状态..." -ForegroundColor Yellow
$portInUse = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
if (-not $portInUse) {
    Write-Host "  端口 2368 未被占用，Ghost 可能已停止" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Ghost 已停止" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    exit 0
}
Write-Host "  Ghost 正在运行 (端口 2368)" -ForegroundColor Green
Write-Host ""

# 停止 Ghost
Write-Host "[3/3] 停止 Ghost..." -ForegroundColor Yellow
Set-Location $RuntimeDir
ghost stop

# 确认端口已释放
Start-Sleep -Seconds 2
$portStillInUse = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
if ($portStillInUse) {
    Write-Host "  警告: 端口 2368 仍被占用，尝试强制结束进程..." -ForegroundColor Yellow
    $procId = $portStillInUse.OwningProcess | Select-Object -Unique
    Write-Host "  结束进程 PID: $procId" -ForegroundColor Yellow
    Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ghost 已停止" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  数据已保存到 SQLite 数据库" -ForegroundColor White
Write-Host "  数据库位置: runtime/content/data/ghost-dev.db" -ForegroundColor White
Write-Host ""
Write-Host "  重新启动: .\scripts\start.ps1" -ForegroundColor Yellow
Write-Host ""
