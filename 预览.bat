@echo off
chcp 65001 >nul
cd /d "%~dp0"

where hugo >nul 2>nul
if errorlevel 1 (
  if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\hugo.exe" (
    set "HUGO=%LOCALAPPDATA%\Microsoft\WinGet\Links\hugo.exe"
  ) else (
    echo 没找到 hugo。先运行一次：winget install --id Hugo.Hugo.Extended -e
    pause
    exit /b 1
  )
) else (
  set "HUGO=hugo"
)

echo 正在启动本地预览：http://localhost:1313
echo 关闭这个窗口即停止预览。
start "" http://localhost:1313
"%HUGO%" server -D --navigateToChanged --port 1313
pause
