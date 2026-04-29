# Design: User Auth - 用户认证模块

> Related: [requirements.md](./requirements.md)

## Context

AI-First Scaffold平台需要区分管理员和普通用户两种角色，所有业务操作都需要认证和授权。
当前 `back_end/app/` 已完成认证模块的开发，使用 FastAPI + SQLAlchemy + SQLite 技术栈。

**约束条件**：
- 后端使用 Python + FastAPI + SQLite（技术栈决策详见 [docs/architecture.md](../../docs/architecture.md)）
- 一期不实现微信登录、短信验证码
- 数据模型需为二期 AI 功能预留字段

## Goals / Non-Goals

**Goals:**
- 实现完整的注册/登录/JWT 认证流程
- 通过 FastAPI `Depends` 实现声明式角色校验
- 提供可通过 Swagger UI 测试的 API 文档

**Non-Goals:**
- 不实现微信登录（一期用手机号+密码）
- 不实现 Token 刷新/黑名单机制
- 不实现短信验证码

## Architecture

### System Context

```
浏览器 → React SPA → HTTP/JSON → FastAPI Backend → SQLite
                        ↑
                  Authorization: Bearer <JWT>
```

### Component Design

| 组件 | 路径 | 职责 |
|------|------|------|
| `routers/auth.py` | API 路由 | 注册、登录端点 |
| `routers/users.py` | API 路由 | 获取用户信息、修改密码 |
| `dependencies.py` | 依赖注入 | `get_current_user`、`require_role` |
| `utils/jwt.py` | 工具 | Token 生成与验证 |
| `utils/security.py` | 工具 | 密码哈希与校验（BCrypt） |
| `models/user.py` | 数据模型 | User SQLAlchemy 模型 |
| `schemas/user.py` | Schema | Pydantic 请求/响应模型 |

## Data Models

```python
class User(Base):
    id: int              # 自增主键
    phone: str           # 手机号（唯一）
    name: str            # 姓名
    password_hash: str   # BCrypt 哈希
    role: str            # 'admin' | 'user'
    created_at: datetime
    updated_at: datetime
```

验证规则：
- phone: 唯一约束，非空
- role: 枚举值 admin/user
- password_hash: 由 BCrypt 生成，禁止明文存储

## API Design

| Method | Path | Description | Auth |
|--------|------|-------------|------|
| POST | `/api/v1/auth/register` | 用户注册 | 公开 |
| POST | `/api/v1/auth/login` | 用户登录，返回 JWT | 公开 |
| GET | `/api/v1/auth/me` | 获取当前用户信息 | 已登录 |
| PUT | `/api/v1/auth/password` | 修改密码 | 已登录 |

### 请求/响应示例

**POST /api/v1/auth/register**
```json
// Request
{ "phone": "13800138000", "name": "张老师", "password": "abc123", "role": "admin" }
// Response 201
{ "id": 1, "phone": "13800138000", "name": "张老师", "role": "admin" }
```

**POST /api/v1/auth/login**
```json
// Request
{ "phone": "13800138000", "password": "abc123" }
// Response 200
{ "access_token": "eyJ...", "token_type": "bearer" }
```

## Security Considerations

- 密码使用 `passlib[bcrypt]` 哈希存储
- JWT 使用 `python-jose[cryptography]`，HS256 算法
- Token 有效期 7 天（可通过环境变量 `ACCESS_TOKEN_EXPIRE_MINUTES` 配置）
- 请求通过 `Authorization: Bearer <token>` 传递
- 一期 HTTP 开发环境，生产必须 HTTPS

## Error Handling

| Category | HTTP Status | Description |
|----------|-------------|-------------|
| Duplicate Phone | 409 | 手机号已注册 |
| Invalid Input | 422 | 手机号格式无效等 |
| Wrong Password | 401 | 密码错误 |
| Not Authenticated | 401 | Token 缺失或无效 |
| Wrong Current Password | 400 | 修改密码时当前密码错误 |

## Testing Strategy

- **Unit**: 密码哈希/验证、JWT 生成/解析、Schema 验证
- **Integration**: 注册→登录→获取用户→修改密码完整流程
- **E2E**: curl 脚本验证完整认证链路

## Decisions & Trade-offs

| Decision | Rationale | Trade-off |
|----------|-----------|-----------|
| JWT 无状态认证 | 简单，适合 SPA | 无法主动失效 Token |
| HS256 算法 | 实现简单，一期够用 | 不如 RS256 安全 |
| 7 天过期 | 平衡安全性和体验 | 一期不做 Token 刷新 |
| BCrypt 哈希 | 行业标准 | 无 |
