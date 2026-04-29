#!/bin/bash
# 前端冒烟验证脚本
# 用途: 检查前端开发服务器是否正常运行，页面是否可访问
# 前提: 前端服务已启动 (./harness/start-frontend.sh)
#
# 用法: ./harness/verify-frontend.sh

set -euo pipefail

# 依赖检查
for cmd in curl node; do
  command -v $cmd >/dev/null 2>&1 || { echo "❌ 缺少依赖: $cmd"; exit 1; }
done

FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASS=0
FAIL=0

assert_accessible() {
  local desc="$1" url="$2"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$url" 2>/dev/null)
  if [ "$status" = "200" ]; then
    echo -e "  ${GREEN}✓${NC} $desc ($url)"
    ((PASS++))
  else
    echo -e "  ${RED}✗${NC} $desc ($url → HTTP $status)"
    ((FAIL++))
  fi
}

assert_contains() {
  local desc="$1" url="$2" keyword="$3"
  local body
  body=$(curl -s --max-time 5 "$url" 2>/dev/null)
  if echo "$body" | grep -q "$keyword"; then
    echo -e "  ${GREEN}✓${NC} $desc (包含 '$keyword')"
    ((PASS++))
  else
    echo -e "  ${RED}✗${NC} $desc (未找到 '$keyword')"
    ((FAIL++))
  fi
}

echo "╔══════════════════════════════════════╗"
echo "║    AI-First Scaffold 前端冒烟验证                ║"
echo "╚══════════════════════════════════════╝"

# 检查服务是否运行
if ! curl -s --max-time 3 "$FRONTEND_URL" > /dev/null 2>&1; then
  echo -e "${RED}❌ 前端服务未运行${NC}"
  echo "请先启动: ./harness/start-frontend.sh"
  exit 1
fi
echo -e "${GREEN}✓${NC} 前端服务已运行: $FRONTEND_URL"

echo ""
echo "━━━ 页面可访问性 ━━━"
assert_accessible "首页" "$FRONTEND_URL/"
assert_contains "HTML 包含 React 挂载点" "$FRONTEND_URL/" "id=\"root\""

echo ""
echo "━━━ TypeScript 类型检查 ━━━"
cd "$(dirname "$0")/../front_end"
tsc_output=$(npx tsc --noEmit 2>&1)
tsc_exit=$?
if [ $tsc_exit -eq 0 ]; then
  echo -e "  ${GREEN}✓${NC} TypeScript 类型检查通过"
  ((PASS++))
else
  echo -e "  ${RED}✗${NC} TypeScript 类型检查失败:"
  echo "$tsc_output" | head -20 | sed 's/^/    /'
  [ $(echo "$tsc_output" | wc -l) -gt 20 ] && echo "    ... (更多错误省略，运行 cd front_end && npx tsc --noEmit 查看完整输出)"
  ((FAIL++))
fi

echo ""
echo "━━━ 验证结果 ━━━"
echo -e "  ${GREEN}通过: $PASS${NC}  ${RED}失败: $FAIL${NC}"

if [ $FAIL -gt 0 ]; then
  echo -e "\n${RED}❌ 有 $FAIL 项验证失败${NC}"
  exit 1
else
  echo -e "\n${GREEN}✅ 全部验证通过${NC}"
  exit 0
fi
