@echo off
chcp 65001 >nul
echo ==========================================
echo   推送到 GitHub
echo ==========================================
echo.
echo 正在尝试推送到 GitHub...
echo.

git push origin master

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo   推送成功！
    echo ==========================================
    echo.
    echo 请前往 GitHub 查看 Actions 构建状态：
    echo https://github.com/LongbowMax/glass-curtain-wall-repair/actions
    echo.
    pause
) else (
    echo.
    echo ==========================================
    echo   推送失败，请使用手动方案
    echo ==========================================
    echo.
    echo 请按以下步骤操作：
    echo.
    echo 1. 打开 https://github.com/LongbowMax/glass-curtain-wall-repair
    echo.
    echo 2. 逐个创建以下文件：
    echo.
    echo -------- 文件1：android/settings.gradle --------
    cat .\android\settings.gradle
    echo.
    echo -------- 文件2：android/gradle.properties --------
    cat .\android\gradle.properties
    echo.
    echo -------- 文件3：android/gradle/wrapper/gradle-wrapper.properties --------
    cat .\android\gradle\wrapper\gradle-wrapper.properties
    echo.
    echo 3. 修改文件：android/app/build.gradle
    echo    将 buildTypes 部分改为：
    echo    buildTypes {
    echo        release {
    echo            signingConfig signingConfigs.debug
    echo            minifyEnabled false
    echo            shrinkResources false
    echo        }
    echo    }
    echo.
    pause
)
