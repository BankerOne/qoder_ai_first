#!/bin/bash
# AI-First Scaffold 初始化脚本
# 用法：./init.sh <project-name> [target-dir]
#
# 选项：
#   --no-git              不初始化 git 仓库
#   --keep-sample-spec    保留 specs/001-user-auth（默认保留）
#   --drop-sample-spec    派生时清空 specs/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 默认值
INIT_GIT=1
KEEP_SAMPLE=1

# 解析参数
POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-git) INIT_GIT=0; shift ;;
    --keep-sample-spec) KEEP_SAMPLE=1; shift ;;
    --drop-sample-spec) KEEP_SAMPLE=0; shift ;;
    -h|--help)
      head -10 "$0" | tail -8
      exit 0
      ;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

if [ ${#POSITIONAL[@]} -lt 1 ]; then
  echo "用法: $0 <project-name> [target-dir]" >&2
  exit 1
fi

PROJECT_NAME="${POSITIONAL[0]}"
TARGET_DIR="${POSITIONAL[1]:-../$PROJECT_NAME}"
# 归一化为绝对路径（允许父目录尚不存在）
case "$TARGET_DIR" in
  /*) ;;
  *)  TARGET_DIR="$(pwd)/$TARGET_DIR" ;;
esac
TARGET_DIR="${TARGET_DIR%/}"

echo "━━━ AI-First Scaffold 派生 ━━━"
echo "  项目名：  $PROJECT_NAME"
echo "  目标目录：$TARGET_DIR"
echo "  保留样例 Spec：$([ $KEEP_SAMPLE -eq 1 ] && echo 是 || echo 否)"
echo "  初始化 Git：$([ $INIT_GIT -eq 1 ] && echo 是 || echo 否)"
echo ""

if [ -e "$TARGET_DIR" ]; then
  echo "❌ 目标目录已存在: $TARGET_DIR" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET_DIR")"
mkdir -p "$TARGET_DIR"

# 复制文件（rsync 排除脚手架自身与运行时产物）
rsync -a   --exclude ".git"   --exclude "node_modules"   --exclude "venv"   --exclude ".venv"   --exclude "__pycache__"   --exclude ".pytest_cache"   --exclude "dist"   --exclude "*.tsbuildinfo"   --exclude "app.db"   --exclude "test.db"   --exclude "uploads"   --exclude ".env"   --exclude "init.sh"   --exclude "README.md"   "$SCRIPT_DIR/" "$TARGET_DIR/"

# 清理样例 Spec（如选择）
if [ $KEEP_SAMPLE -eq 0 ]; then
  rm -rf "$TARGET_DIR/specs/"*
fi

# 替换项目名占位符（sed -i 在 macOS/BSD 需要 "" 作备份扩展，GNU 则不需要）
sed_inplace() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i "" "$@"
  fi
}

# package.json
if [ -f "$TARGET_DIR/front_end/package.json" ]; then
  sed_inplace "s|\"name\": \"ai-first-scaffold\"|\"name\": \"$PROJECT_NAME\"|" "$TARGET_DIR/front_end/package.json"
fi

# index.html title
if [ -f "$TARGET_DIR/front_end/index.html" ]; then
  sed_inplace "s|<title>AI-First Scaffold</title>|<title>$PROJECT_NAME</title>|" "$TARGET_DIR/front_end/index.html"
fi

# AGENTS.md 项目名（全文替换，保留 docs/README 中的溯源链接）
if [ -f "$TARGET_DIR/AGENTS.md" ]; then
  sed_inplace "s|AI-First Scaffold|$PROJECT_NAME|g" "$TARGET_DIR/AGENTS.md"
fi

# 生成 .env（随机 SECRET）
SECRET=$(openssl rand -hex 32 2>/dev/null || python3 -c "import secrets; print(secrets.token_hex(32))")
cat > "$TARGET_DIR/back_end/.env" <<ENV
JWT_SECRET_KEY=$SECRET
DATABASE_URL=sqlite:///./app.db
DEBUG=true
ENV

# 新项目 README（覆写）
cat > "$TARGET_DIR/README.md" <<MD
# $PROJECT_NAME

基于 [AI-First Scaffold](https://github.com/) 派生，具备 SDD 方法论 + FastAPI + React 全栈骨架。

## 快速开始

\`\`\`bash
./harness/start-backend.sh   # localhost:8000
./harness/start-frontend.sh  # localhost:5173
\`\`\`

详细说明见 \`AGENTS.md\` 与 \`docs/sdd_flow.md\`。
MD

# 初始化 Git
if [ $INIT_GIT -eq 1 ]; then
  (cd "$TARGET_DIR" && git init -q && git add -A && git -c user.email=init@local -c user.name=init commit -q -m "chore: init from ai-first-scaffold")
  echo "✓ git 仓库已初始化"
fi

echo ""
echo "✅ 派生完成：$TARGET_DIR"
echo ""
echo "下一步："
echo "  cd $TARGET_DIR"
echo "  ./harness/start-backend.sh   # 启动后端 (localhost:8000)"
echo "  ./harness/start-frontend.sh  # 启动前端 (localhost:5173)"
