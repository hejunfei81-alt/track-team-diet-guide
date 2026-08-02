@echo off
chcp 65001 >nul
REM 高校田径队饮食指导手册 - 双击即可部署更新
cd /d "%~dp0"

echo.
echo  ═══════════════════════════════════════
echo   正在更新网页...
echo   （用 git 提交并推送到 GitHub Pages）
echo  ═══════════════════════════════════════
echo.

git add -A
git commit -m "自动更新 %date% %time%"
if errorlevel 1 (
  echo.
  echo  ⚠ 没有检测到新改动，不需要更新。
  echo    （如果你改了 index.html 却提示这个，说明没保存）
) else (
  git push origin main
  echo.
  echo  ✅ 已推送到 GitHub，等待 1-2 分钟生效！
  echo  🌐 https://hejunfei81-alt.github.io/track-team-diet-guide/
)

echo.
pause
