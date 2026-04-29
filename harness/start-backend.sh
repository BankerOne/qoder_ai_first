#!/bin/bash
# 启动后端开发服务器
# 用法: ./harness/start-backend.sh

set -e

# 依赖检查
for cmd in python3 pip; do
  command -v $cmd >/dev/null 2>&1 || { echo "❌ 缺少依赖: $cmd"; exit 1; }
done

cd "$(dirname "$0")/../back_end"

# 激活虚拟环境
if [ -d "venv" ]; then
  source venv/bin/activate
else
  echo "❌ venv 不存在，请先运行: cd back_end && python -m venv venv"
  exit 1
fi

# 安装依赖（如有更新）
pip install -r requirements.txt -q

# 执行数据库迁移
alembic upgrade head 2>/dev/null || echo "⚠️  Alembic 迁移跳过（可能无迁移文件）"

# 启动开发服务器
echo "🚀 后端启动中: http://localhost:8000"
echo "📄 API 文档: http://localhost:8000/docs"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
