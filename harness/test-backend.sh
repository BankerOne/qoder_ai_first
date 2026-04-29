#!/bin/bash
# 运行后端 pytest 测试
# 用法: ./harness/test-backend.sh [pytest 参数]
# 示例: ./harness/test-backend.sh -v
#       ./harness/test-backend.sh tests/test_auth.py -v
#       ./harness/test-backend.sh -k "test_login"

set -e

# 依赖检查
command -v python3 >/dev/null 2>&1 || { echo "❌ 缺少依赖: python3"; exit 1; }

cd "$(dirname "$0")/../back_end"

# 激活虚拟环境
if [ -d "venv" ]; then
  source venv/bin/activate
else
  echo "❌ venv 不存在"
  exit 1
fi

echo "🧪 运行后端测试..."
pytest "$@"
