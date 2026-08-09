#!/bin/bash
# 高校田径队训练与饮食指导手册 - 一键部署脚本
# 用法: bash deploy.sh "更新说明"   (或直接 bash deploy.sh，用默认信息)
#
# 它会：git add → commit → push → 自动触发 GitHub Pages 重新部署
# 部署后等 1-2 分钟，访问 https://hejunfei81-alt.github.io/sports-diet/
#
# 代理策略（重点）：
#   1. 若检测到本机 Clash 代理（clash-verge / mihomo 常用端口 7897/7890），优先强制走代理推 GitHub —— 快且稳
#   2. 否则试其它常见代理端口
#   3. 都没有才退回直连（GitHub 直连在国内经常很慢/超时，可能失败）

set -e

# 探测函数：返回"代理端口是否真能用"（用国内可访问的站点测，避免误判）
try_proxy() {
  local P=$1
  # github 直连在慢网络下也能"通"，所以用国内站 baidu 测代理有效性更准
  if curl -s -o /dev/null --max-time 3 -x "http://127.0.0.1:$P" https://www.baidu.com 2>/dev/null; then
    echo "$P"
    return 0
  fi
  return 1
}

PROXY=""
# 优先：检测到 Clash（clash-verge / mihomo）就跑它的常用端口
if tasklist 2>/dev/null | grep -qiE "clash|mihomo|verge"; then
  for P in 7897 7890 7891; do
    if R=$(try_proxy $P); then PROXY=$P; echo "→ 检测到 Clash 代理，走 127.0.0.1:$P 推送"; break; fi
  done
fi
# 其次：其它常见代理端口
if [ -z "$PROXY" ]; then
  for P in 10809 1080 7899 10801 20171 8888; do
    if R=$(try_proxy $P); then PROXY=$P; echo "→ 检测到本机代理 127.0.0.1:$P，走代理推送"; break; fi
  done
fi

if [ -n "$PROXY" ]; then
  export HTTPS_PROXY="http://127.0.0.1:$PROXY"
  export HTTP_PROXY="http://127.0.0.1:$PROXY"
  export ALL_PROXY="http://127.0.0.1:$PROXY"
  export NO_PROXY="localhost,127.0.0.1"
  echo "→ 已设置代理 http://127.0.0.1:$PROXY"
else
  echo "→ 未检测到可用代理，尝试直连（GitHub 直连国内可能很慢/失败）"
fi

# 提交说明：有参数用参数，没有用时间戳
MSG="${1:-更新于 $(date '+%Y-%m-%d %H:%M')}"

cd "$(dirname "$0")"
git add -A
git commit -m "$MSG" || { echo "⚠️ 没有需要提交的改动"; exit 0; }

# 推送：默认走已设置的代理/直连；万一失败，加大超时重试一次
if ! git push origin main; then
  echo "→ 首次推送失败，加大超时重试一次..."
  git -c http.connectTimeout=90 -c http.timeout=300 push origin main
fi

echo ""
echo "✅ 已部署！等待 1-2 分钟后生效："
echo "   https://hejunfei81-alt.github.io/sports-diet/"
