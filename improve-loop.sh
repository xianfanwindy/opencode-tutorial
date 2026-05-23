#!/bin/bash
# 持续改进循环脚本
# 用法: bash improve-loop.sh [间隔分钟]
# 默认每 30 分钟执行一次

INTERVAL=${1:-30}

echo "持续改进循环启动，间隔 ${INTERVAL} 分钟"
echo "按 Ctrl+C 停止"

while true; do
  echo ""
  echo "=== $(date) ==="
  echo "运行 /improve-check ..."
  
  # 在项目目录中启动 opencode 执行检查
  opencode --execute "/improve-check" --headless 2>&1 || \
    echo "提示: 请在 opencode 会话中输入 /improve 或 /improve-check 手动触发"
  
  echo "等待 ${INTERVAL} 分钟后再次检查..."
  sleep $((INTERVAL * 60))
done