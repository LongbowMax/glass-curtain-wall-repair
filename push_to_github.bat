@echo off
chcp 65001 >nul
title 推送到 GitHub - LongbowMax

echo =========================================
echo   玻璃幕墙维修App - GitHub一键推送
echo =========================================
echo.
echo 仓库: https://github.com/LongbowMax/glass-curtain-wall-repair
echo.

:: 检查Git
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到Git，请先安装Git
    pause
    exit /b 1
)

:: 设置变量
set USERNAME=LongbowMax
set REPO_NAME=glass-curtain-wall-repair
set REPO_URL=https://github.com/%USERNAME%/%REPO_NAME%.git

echo [1/5] 配置Git...
git config user.name "LongbowMax" 2>nul
git config user.email "developer@glassrepair.com" 2>nul
echo     完成

echo.
echo [2/5] 配置远程仓库...
git remote remove origin 2>nul
git remote add origin %REPO_URL%
echo     远程仓库: %REPO_URL%

echo.
echo [3/5] 检查提交状态...
git status --short
echo.

echo [4/5] 准备推送...
echo     请确保已在GitHub创建仓库: %REPO_URL%
echo.

:: 检查是否有token文件
if exist .github_token (
    set /p TOKEN=<.github_token
    echo     检测到Token文件，使用Token推送...
    echo.
    echo [5/5] 正在推送代码...
    echo %USERNAME%:%TOKEN% | git push -u origin master
) else (
    echo [5/5] 正在推送代码...
    echo.
    echo =========================================
    echo   如果提示输入密码，请使用GitHub Token
echo =========================================
    echo.
    echo Token获取方法:
    echo   1. 访问 https://github.com/settings/tokens
echo   2. 点击 "Generate new token (classic)"
echo   3. 勾选 "repo" 权限
echo   4. 复制Token作为密码输入
echo.
    git push -u origin master
)

if %errorlevel% equ 0 (
    echo.
    echo =========================================
    echo   推送成功!  
echo =========================================
    echo.
    echo 访问: https://github.com/%USERNAME%/%REPO_NAME%
    echo.
    start https://github.com/%USERNAME%/%REPO_NAME%
) else (
    echo.
    echo =========================================
    echo   推送失败，请检查:
    echo =========================================
    echo.
    echo 1. 是否已在GitHub创建仓库?
    echo    访问 https://github.com/new 创建
echo.
    echo 2. Token是否正确?
    echo    可以在当前目录创建 .github_token 文件，将token写入
echo.
    echo 3. 网络连接是否正常?
echo.
)

pause
