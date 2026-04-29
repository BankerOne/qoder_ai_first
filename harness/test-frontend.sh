#!/bin/bash
# 运行前端 Vitest 测试
# 用法: ./harness/test-frontend.sh [vitest 参数]
# 示例: ./harness/test-frontend.sh
#       ./harness/test-frontend.sh --reporter verbose

set -e

# 依赖检查
for cmd in node npm; do
  command -v $cmd >/dev/null 2>&1 || { echo "❌ 缺少依赖: $cmd"; exit 1; }
done

cd "$(dirname "$0")/../front_end"

echo "🧪 运行前端测试..."
npx vitest run "$@"
