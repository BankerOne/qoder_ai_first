# 开发规范

> AI 在编码时按需加载本文档，AGENTS.md 的约束精要版不覆盖细节时查这里。

---

## API 契约

### 路径规范

- 统一前缀：`/api/v1/`
- 资源命名：复数形式（`/users`、`/posts`），禁止 `/user`
- 动作命名：动词子路径（`/auth/login`、`/users/me/password`），不用 querystring 表达动作

### 请求/响应

- 请求体用 JSON，`Content-Type: application/json`
- 文件上传用 `multipart/form-data`
- 响应成功：2xx + JSON 资源表示
- 响应失败：HTTPException，Body 统一 `{ "detail": "..." }` 或 `{ "detail": [{ "loc": [...], "msg": "...", "type": "..." }] }`（Pydantic 校验错误）

### 状态码约定

| 场景 | 码 |
|---|---|
| 创建成功 | 201 |
| 更新/查询成功 | 200 |
| 删除成功（无 body） | 204 |
| 输入校验失败 | 422 |
| 未认证 | 401 |
| 无权限 | 403 |
| 资源不存在 | 404 |
| 冲突（重复注册、重复批改等） | 409 |
| 不支持的文件类型 | 415 |
| 服务器异常 | 500 |
| 上游不可用（外部服务/OCR） | 502 |

## 异常处理

后端：**永远** `raise HTTPException(status_code=..., detail="...")`，禁止返回 `{"error": ...}` 自定义错误体。

前端：
- 全局拦截器负责 401（登出跳登录）、5xx（toast）、网络异常（toast）
- 其他 4xx 由页面内调 `extractErrorMessage(err, fallback)` 处理

## 数据库规范

1. 所有表结构变更 **必须** 通过 Alembic 迁移：`alembic revision --autogenerate -m "xxx"` → 人工审查 → `alembic upgrade head`
2. 主键统一使用 `String(36)` + UUID4
3. 每张表包含 `created_at` / `updated_at`（`server_default=func.now()`）
4. 外键必须显式 `ForeignKeyConstraint`，删除策略按业务决定
5. 枚举类型：后端 `enum.Enum` + SQLAlchemy `SAEnum`；前端 TS `union type`，保持命名一致

## 测试规范

### 覆盖范围

- 所有 API 路由必须有 pytest 测试
- 每条需求（REQ-N）至少 1 个验收测试
- 边界场景：参数越界、权限越级、并发竞态

### 组织

```
back_end/tests/
├── conftest.py     # fixtures（client、db_session、admin_token、user_token）
├── test_auth.py
└── test_health.py
```

- `client` fixture 覆盖 `get_db` 为内存测试库
- Token fixtures 直接签发，避免每次走 `/auth/login`
- 每个测试用独立 `db_session`，teardown drop_all

### 前端测试

- 工具：vitest + @testing-library/react
- 主测：`src/test/App.test.tsx`（冒烟） + 按需扩展组件测试
- 组件测试关注交互与可访问性（role、aria），避免断言内部实现

## 端到端验证规范

`harness/verify-api.sh` 是唯一的端到端 API 验证入口：

### 使用方式

```bash
./harness/verify-api.sh            # 全量验证
./harness/verify-api.sh auth       # 指定模块
```

### 扩展脚本

新增业务模块时，在 `verify-api.sh` 中：
1. 新增 `verify_<module>()` 函数
2. 所有测试数据使用**固定姓名前缀**（如 "验证_XXX"），便于 `cleanup` 按姓名级联删除
3. `cleanup()` 中新增按外键链删除的 SQL，保证脚本异常退出也不留垃圾数据
4. 在 `case "$MODULE"` 中注册新模块

### 数据隔离原则

- 手机号：每次运行生成随机 6 位后缀，避免并发冲突
- 姓名：固定前缀（`VERIFY_*_NAME`），作为 cleanup 的锁定键
- 数据库：直接操作 `app.db`，**不使用**测试数据库（端到端验证真实路径）

## Git 工作流

- 主分支：`main`
- 功能分支：`feat/<spec-id>-<slug>`
- 修复分支：`fix/<spec-id>-<slug>`
- 提交信息：Conventional Commits（`feat: ...`、`fix: ...`、`docs: ...`、`chore: ...`）
- 每个 Spec 通常对应一个 PR，合并前：
  1. `./harness/test-backend.sh -v` 通过
  2. `./harness/verify-api.sh <module>` 通过
  3. `./harness/verify-frontend.sh` 通过
  4. Spec 的 tasks 全部 `[x]`

## 命名约定补充

- Enum 值：Python 用全大写（`ADMIN`），数据库存 `ADMIN`，前端 TS 用小写字符串字面量（`'admin'`）
- API 路径：全小写 + 连字符（`/users/me/password`，不用 `/users/mePassword`）
- 环境变量：全大写下划线（`JWT_SECRET_KEY`）
