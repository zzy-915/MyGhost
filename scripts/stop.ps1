# 一键停止 Ghost 博客系统（直接结束 node 进程）
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
$procIds = $portInUse.OwningProcess | Select-Object -Unique
Write-Host "  Ghost 正在运行 (端口 2368)" -ForegroundColor Green
Write-Host "  进程 PID: $($procIds -join ', ')" -ForegroundColor Green
Write-Host ""

# 停止 Ghost（直接结束 node 进程）
Write-Host "[3/3] 停止 Ghost（结束 node 进程）..." -ForegroundColor Yellow
foreach ($procId in $procIds) {
    $proc = Get-Process -Id $procId -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  结束进程: PID=$procId, Name=$($proc.ProcessName)" -ForegroundColor Yellow
        Stop-Process -Id $procId -Force -ErrorAction SilentlyContinue
    }
}

# 尝试 ghost stop（如果是通过 ghost-cli 启动的）
Set-Location $RuntimeDir
ghost stop 2>$null | Out-Null

# 确认端口已释放
Write-Host "  等待端口释放..." -ForegroundColor Yellow
$portReleased = $false
for ($i = 0; $i -lt 10; $i++) {
    Start-Sleep -Seconds 1
    $portStillInUse = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
    if (-not $portStillInUse) {
        $portReleased = $true
        Write-Host "  端口 2368 已释放（耗时 $($i + 1) 秒）" -ForegroundColor Green
        break
    }
}

if (-not $portReleased) {
    Write-Host "  警告: 端口 2368 仍被占用，强制结束所有相关 node 进程..." -ForegroundColor Yellow
    Get-Process -Name node -ErrorAction SilentlyContinue | Where-Object { $_.Path -like "*oss-blog*" -or $_.CommandLine -like "*ghost*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    $portFinal = Get-NetTCPConnection -LocalPort 2368 -ErrorAction SilentlyContinue
    if ($portFinal) {
        Write-Host "  错误: 无法释放端口 2368，请手动结束进程" -ForegroundColor Red
        Write-Host "  占用进程 PID: $($portFinal.OwningProcess -join ', ')" -ForegroundColor Red
    } else {
        Write-Host "  端口 2368 已释放" -ForegroundColor Green
    }
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
