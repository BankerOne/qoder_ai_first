#!/bin/bash
# 启动前端开发服务器
# 用法: ./harness/start-frontend.sh

set -e

# 依赖检查
for cmd in node npm; do
  command -v $cmd >/dev/null 2>&1 || { echo "❌ 缺少依赖: $cmd"; exit 1; }
done

cd "$(dirname "$0")/../front_end"

# 安装依赖（如有更新）
npm install --silent

# 启动开发服务器
echo "🚀 前端启动中: http://localhost:5173"
npm run dev
