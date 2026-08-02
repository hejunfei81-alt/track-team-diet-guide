#!/bin/bash
# 高校田径队饮食指导手册 - 一键部署脚本
# 用法: bash deploy.sh "更新说明"   (或直接 bash deploy.sh，用默认信息)
#
# 它会：git add → commit → push → 自动触发 GitHub Pages 重新部署
# 部署后等 1-2 分钟，访问 https://hejunfei81-alt.github.io/track-team-diet-guide/

set -e

# 自适应代理：检测本机代理端口，有就自动用（Lucky/Clash 常用 7897/7890/10809）；没有就直连
for P in 7897 7890 10809 1080; do
  if curl -s -o /dev/null --max-time 2 -x "http://127.0.0.1:$P" https://github.com 2>/dev/null; then
    echo "→ 检测到本机代理 127.0.0.1:$P，走代理推送"
    export HTTPS_PROXY="http://127.0.0.1:$P"
    export HTTP_PROXY="http://127.0.0.1:$P"
    export ALL_PROXY="http://127.0.0.1:$P"
    break
  fi
done

# 提交说明：有参数用参数，没有用时间戳
MSG="${1:-更新于 $(date '+%Y-%m-%d %H:%M')}"

cd "$(dirname "$0")"
git add -A
git commit -m "$MSG" || { echo "⚠️ 没有需要提交的改动"; exit 0; }
git push origin main
echo ""
echo "✅ 已部署！等待 1-2 分钟后生效："
echo "   https://hejunfei81-alt.github.io/track-team-diet-guide/"
