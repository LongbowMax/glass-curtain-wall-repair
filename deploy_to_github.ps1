# 玻璃幕墙维修App - GitHub部署脚本
# 用法: 在PowerShell中运行: .\deploy_to_github.ps1

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  玻璃幕墙维修App - GitHub部署脚本" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 检查是否在正确的目录
if (-not (Test-Path "lib\main.dart")) {
    Write-Host "错误: 请在项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 设置变量
$Username = "LongbowMax"
$RepoName = "glass-curtain-wall-repair"
$RepoUrl = "https://github.com/$Username/$RepoName"

Write-Host "准备部署到: $RepoUrl" -ForegroundColor White
Write-Host ""

# 配置Git
Write-Host "步骤 1/4: 配置Git..." -ForegroundColor Yellow
git config user.name "LongbowMax" 2>$null
git config user.email "developer@glassrepair.com" 2>$null
Write-Host "  Git用户配置完成" -ForegroundColor Green

# 添加远程仓库
Write-Host ""
Write-Host "步骤 2/4: 配置远程仓库..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin "$RepoUrl.git"
Write-Host "  远程仓库已配置" -ForegroundColor Green

# 显示状态
Write-Host ""
Write-Host "步骤 3/4: 检查提交状态..." -ForegroundColor Yellow
git status
Write-Host ""

# 显示推送指南
Write-Host "步骤 4/4: 请按以下步骤完成部署" -ForegroundColor Yellow
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  请先在GitHub创建仓库:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. 打开浏览器访问:" -ForegroundColor White
Write-Host "   https://github.com/new" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. 填写仓库信息:" -ForegroundColor White
Write-Host "   仓库名称: $RepoName" -ForegroundColor Yellow
Write-Host "   描述: 玻璃幕墙维修方案生成器 - Flutter跨平台应用" -ForegroundColor Yellow
Write-Host "   可见性: Public (公开)" -ForegroundColor Yellow
Write-Host "   不要勾选 'Add a README file'" -ForegroundColor Red
Write-Host ""
Write-Host "3. 点击 'Create repository'" -ForegroundColor White
Write-Host ""
Write-Host "4. 创建完成后，运行以下命令推送:" -ForegroundColor White
Write-Host ""
Write-Host "   git push -u origin master" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "   或使用下方简化命令:" -ForegroundColor Gray
Write-Host ""
Write-Host "   git push https://github.com/LongbowMax/glass-curtain-wall-repair.git master" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  提示:" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "如果提示输入密码，请使用GitHub Token:" -ForegroundColor Yellow
Write-Host "  1. 访问 https://github.com/settings/tokens" -ForegroundColor White
Write-Host "  2. 生成新Token，勾选 repo 权限" -ForegroundColor White
Write-Host "  3. 用Token作为密码输入" -ForegroundColor White
Write-Host ""
