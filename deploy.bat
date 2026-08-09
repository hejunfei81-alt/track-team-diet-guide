@echo off
chcp 65001 >nul
REM 高校田径队训练与饮食指导手册 - 双击即可部署更新（走 Clash 代理，稳定）
cd /d "%~dp0"

echo.
echo  ══════════════════════════════════════════════
echo   正在更新网页（自动检测 Clash 代理推送）...
echo  ══════════════════════════════════════════════
echo.

REM 有 bash（Git Bash / WSL / Git for Windows 自带）就用新版 deploy.sh（含代理+重试）
where bash >nul 2>nul
if %errorlevel%==0 (
  bash deploy.sh "自动更新 %date% %time%"
  echo.
  echo  ✅ 部署流程结束（详情见上方输出）
) else (
  echo  未找到 bash，退回直连推送（可能较慢）...
  git add -A
  git commit -m "自动更新 %date% %time%"
  if errorlevel 1 (
    echo  ⚠ 没有检测到新改动，不需要更新。
  ) else (
    git push origin main
    echo  ✅ 已推送到 GitHub
  )
)

echo.
echo  🌐 https://hejunfei81-alt.github.io/sports-diet/
echo.
pause
