#!/bin/bash
# AI-First Scaffold —— 端到端 API 验证脚本
#
# 用途：针对已启动的后端服务执行真实 HTTP 断言，覆盖注册、登录、/me 等认证主流程。
# 前提：后端已启动（./harness/start-backend.sh），并可访问 $BASE_URL。
#
# 用法：
#   ./harness/verify-api.sh              # 全量（当前只有 auth）
#   ./harness/verify-api.sh auth         # 仅验证认证模块
#
# 扩展方式：参考 docs/dev-guide.md「端到端验证规范」章节。
#   1. 新增 verify_<module> 函数；
#   2. 在 main 里按依赖顺序调用；
#   3. 在 cleanup 里按 FK 级联倒序清理数据。

set -euo pipefail

# ---------- 依赖检查 ----------
for cmd in curl jq sqlite3; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "❌ 缺少依赖: $cmd"; exit 1; }
done

BASE_URL="${BASE_URL:-http://localhost:8000}"
DB_PATH="${DB_PATH:-$(dirname "$0")/../back_end/app.db}"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0

# ---------- 测试账号 ----------
ADMIN_NAME="验证管理员"
ADMIN_PHONE="13900000001"
ADMIN_PASSWORD="Admin@12345"

USER_NAME="验证用户"
USER_PHONE="13900000002"
USER_PASSWORD="User@12345"
USER_PASSWORD_NEW="User@67890"

ADMIN_TOKEN=""
USER_TOKEN=""

# ---------- 工具函数 ----------
log_pass() { echo -e "  ${GREEN}✓${NC} $1"; ((PASS++)) || true; }
log_fail() { echo -e "  ${RED}✗${NC} $1"; ((FAIL++)) || true; }
log_info() { echo -e "  ${YELLOW}ℹ${NC} $1"; }

http() {
  local method="$1" path="$2" token="${3:-}" body="${4:-}"
  local args=(-s -o /tmp/verify_body.$$ -w "%{http_code}" -X "$method" "${BASE_URL}${path}" \
    -H 'Content-Type: application/json')
  [ -n "$token" ] && args+=(-H "Authorization: Bearer $token")
  [ -n "$body" ] && args+=(-d "$body")
  curl "${args[@]}"
}

assert_status() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$actual" = "$expected" ]; then
    log_pass "$desc (HTTP $actual)"
  else
    log_fail "$desc (期望 $expected，实际 $actual)"
    [ -s /tmp/verify_body.$$ ] && sed 's/^/      /' /tmp/verify_body.$$ | head -5
  fi
}

assert_json_eq() {
  local desc="$1" jq_expr="$2" expected="$3"
  local actual
  actual=$(jq -r "$jq_expr" /tmp/verify_body.$$ 2>/dev/null || echo "<parse-error>")
  if [ "$actual" = "$expected" ]; then
    log_pass "$desc ($jq_expr = $actual)"
  else
    log_fail "$desc (期望 $expected，实际 $actual)"
  fi
}

# ---------- 清理 ----------
cleanup() {
  log_info "清理测试数据..."
  if [ -f "$DB_PATH" ]; then
    sqlite3 "$DB_PATH" "DELETE FROM users WHERE name IN ('$ADMIN_NAME', '$USER_NAME');" 2>/dev/null || true
    log_info "已删除测试用户"
  else
    log_info "数据库文件不存在，跳过清理 ($DB_PATH)"
  fi
  rm -f /tmp/verify_body.$$
}
trap cleanup EXIT

# ---------- 服务可达性 ----------
check_service() {
  echo "━━━ 服务可达性 ━━━"
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${BASE_URL}/api/v1/health" 2>/dev/null || echo "000")
  if [ "$status" = "200" ]; then
    log_pass "后端健康检查 ($BASE_URL)"
  else
    log_fail "后端不可达 ($BASE_URL → HTTP $status)"
    echo -e "${RED}请先启动: ./harness/start-backend.sh${NC}"
    exit 1
  fi
}

# ---------- verify_auth ----------
verify_auth() {
  echo ""
  echo "━━━ 认证模块 ━━━"

  local status

  # 1. 注册管理员
  status=$(http POST /api/v1/auth/register "" "$(jq -nc \
    --arg name "$ADMIN_NAME" --arg phone "$ADMIN_PHONE" --arg pwd "$ADMIN_PASSWORD" \
    '{name:$name, phone:$phone, password:$pwd, role:"admin"}')")
  assert_status "注册管理员" 201 "$status"

  # 2. 注册普通用户
  status=$(http POST /api/v1/auth/register "" "$(jq -nc \
    --arg name "$USER_NAME" --arg phone "$USER_PHONE" --arg pwd "$USER_PASSWORD" \
    '{name:$name, phone:$phone, password:$pwd, role:"user"}')")
  assert_status "注册普通用户" 201 "$status"

  # 3. 重复注册应拒绝
  status=$(http POST /api/v1/auth/register "" "$(jq -nc \
    --arg name "$USER_NAME" --arg phone "$USER_PHONE" --arg pwd "$USER_PASSWORD" \
    '{name:$name, phone:$phone, password:$pwd, role:"user"}')")
  assert_status "重复手机号拒绝" 409 "$status"

  # 4. 登录管理员
  status=$(http POST /api/v1/auth/login "" "$(jq -nc \
    --arg phone "$ADMIN_PHONE" --arg pwd "$ADMIN_PASSWORD" \
    '{phone:$phone, password:$pwd}')")
  assert_status "管理员登录" 200 "$status"
  ADMIN_TOKEN=$(jq -r '.access_token' /tmp/verify_body.$$ 2>/dev/null || echo "")
  if [ -n "$ADMIN_TOKEN" ] && [ "$ADMIN_TOKEN" != "null" ]; then
    log_pass "管理员 token 已获取"
  else
    log_fail "管理员 token 为空"
  fi

  # 5. 登录普通用户
  status=$(http POST /api/v1/auth/login "" "$(jq -nc \
    --arg phone "$USER_PHONE" --arg pwd "$USER_PASSWORD" \
    '{phone:$phone, password:$pwd}')")
  assert_status "普通用户登录" 200 "$status"
  USER_TOKEN=$(jq -r '.access_token' /tmp/verify_body.$$ 2>/dev/null || echo "")

  # 6. 错误密码拒绝
  status=$(http POST /api/v1/auth/login "" "$(jq -nc \
    --arg phone "$USER_PHONE" '{phone:$phone, password:"wrong-password"}')")
  assert_status "错误密码拒绝" 401 "$status"

  # 7. /me 无 token 拒绝
  status=$(http GET /api/v1/users/me)
  assert_status "未登录访问 /me 拒绝" 401 "$status"

  # 8. /me 返回当前用户
  status=$(http GET /api/v1/users/me "$USER_TOKEN")
  assert_status "/me 返回 200" 200 "$status"
  assert_json_eq "/me.phone 匹配" ".phone" "$USER_PHONE"
  assert_json_eq "/me.role 匹配" ".role" "user"

  # 9. 修改密码
  status=$(http PUT /api/v1/users/me/password "$USER_TOKEN" "$(jq -nc \
    --arg old "$USER_PASSWORD" --arg new "$USER_PASSWORD_NEW" \
    '{old_password:$old, new_password:$new}')")
  assert_status "修改密码" 200 "$status"

  # 10. 新密码登录成功
  status=$(http POST /api/v1/auth/login "" "$(jq -nc \
    --arg phone "$USER_PHONE" --arg pwd "$USER_PASSWORD_NEW" \
    '{phone:$phone, password:$pwd}')")
  assert_status "新密码登录成功" 200 "$status"

  # 11. 旧密码登录失败
  status=$(http POST /api/v1/auth/login "" "$(jq -nc \
    --arg phone "$USER_PHONE" --arg pwd "$USER_PASSWORD" \
    '{phone:$phone, password:$pwd}')")
  assert_status "旧密码登录失败" 401 "$status"
}

# ---------- main ----------
MODULE="${1:-all}"

echo "╔══════════════════════════════════════════════════╗"
echo "║   AI-First Scaffold —— 端到端 API 验证          ║"
echo "╚══════════════════════════════════════════════════╝"
echo "Base URL : $BASE_URL"
echo "DB       : $DB_PATH"
echo ""

check_service

case "$MODULE" in
  all | auth)
    verify_auth
    ;;
  *)
    echo -e "${RED}未知模块: $MODULE${NC}"
    echo "可用模块: all, auth"
    exit 1
    ;;
esac

echo ""
echo "━━━ 验证结果 ━━━"
echo -e "  ${GREEN}通过: $PASS${NC}  ${RED}失败: $FAIL${NC}"

if [ "$FAIL" -gt 0 ]; then
  echo -e "\n${RED}❌ 有 $FAIL 项验证失败${NC}"
  exit 1
else
  echo -e "\n${GREEN}✅ 全部验证通过${NC}"
  exit 0
fi
