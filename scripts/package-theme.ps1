# 打包自定义主题为 zip 文件
# 用法: .\scripts\package-theme.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  自定义主题打包脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 项目根目录
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$ThemeDir = Join-Path $ProjectRoot "theme\oss-blog-theme"
$OutputDir = Join-Path $ProjectRoot "dist"
$OutputFile = Join-Path $OutputDir "oss-blog-theme.zip"

Write-Host "[1/4] 检查主题目录..." -ForegroundColor Yellow
if (-not (Test-Path $ThemeDir)) {
    Write-Host "错误: 主题目录不存在: $ThemeDir" -ForegroundColor Red
    exit 1
}
Write-Host "  主题目录: $ThemeDir" -ForegroundColor Green
Write-Host ""

# 读取主题版本
Write-Host "[2/4] 读取主题信息..." -ForegroundColor Yellow
$packageJson = Get-Content (Join-Path $ThemeDir "package.json") -Raw | ConvertFrom-Json
$themeName = $packageJson.name
$themeVersion = $packageJson.version
Write-Host "  主题名称: $themeName" -ForegroundColor Green
Write-Host "  主题版本: $themeVersion" -ForegroundColor Green
Write-Host ""

# 创建输出目录
Write-Host "[3/4] 创建输出目录..." -ForegroundColor Yellow
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
Write-Host "  输出目录: $OutputDir" -ForegroundColor Green
Write-Host ""

# 打包主题
Write-Host "[4/4] 打包主题..." -ForegroundColor Yellow
if (Test-Path $OutputFile) {
    Remove-Item $OutputFile -Force
}

# 压缩主题目录（排除 node_modules 和 .git）
Compress-Archive -Path "$ThemeDir\*" -DestinationPath $OutputFile -Force

$fileSize = (Get-Item $OutputFile).Length
$fileSizeKB = [math]::Round($fileSize / 1KB, 2)

Write-Host "  打包完成: $OutputFile" -ForegroundColor Green
Write-Host "  文件大小: $fileSizeKB KB" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  主题打包完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  主题文件: $OutputFile" -ForegroundColor White
Write-Host ""
Write-Host "  安装方法:" -ForegroundColor Yellow
Write-Host "  1. 管理后台 → 设置 → 主题 → 上传主题" -ForegroundColor White
Write-Host "  2. 选择 oss-blog-theme.zip 文件" -ForegroundColor White
Write-Host "  3. 上传后激活主题" -ForegroundColor White
Write-Host ""
