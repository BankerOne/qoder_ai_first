# API 契约

> 记录所有对外 API 的请求/响应契约。新增模块时按同样结构追加。

---

## 总览

所有 API 统一前缀 `/api/v1`，请求/响应体为 JSON（文件上传除外）。

| 模块 | 路径前缀 | 状态 |
|---|---|---|
| 认证 | `/api/v1/auth` | 已实现 |
| 用户 | `/api/v1/users` | 已实现 |
| 健康检查 | `/api/v1/health` | 已实现 |

## 错误响应统一格式

```json
{ "detail": "错误描述" }
```

Pydantic 校验错误（422）：

```json
{ "detail": [{ "loc": ["body", "phone"], "msg": "手机号格式不正确", "type": "value_error" }] }
```

## 认证模块

### POST /api/v1/auth/register

注册新用户。

Request:
```json
{ "phone": "13800000001", "name": "Alice", "password": "123456", "role": "admin" }
```

Response 201:
```json
{ "id": "uuid", "phone": "13800000001", "name": "Alice", "role": "admin", "created_at": "2026-..." }
```

错误：409 手机号已注册；422 字段校验失败。

### POST /api/v1/auth/login

密码登录。

Request:
```json
{ "phone": "13800000001", "password": "123456" }
```

Response 200:
```json
{ "access_token": "eyJ...", "token_type": "bearer" }
```

错误：401 密码错误或用户不存在。

## 用户模块

### GET /api/v1/users/me

获取当前用户信息。需 `Authorization: Bearer <token>`。

Response 200:
```json
{ "id": "uuid", "phone": "...", "name": "...", "role": "admin", "created_at": "..." }
```

### PUT /api/v1/users/me/password

修改当前用户密码。

Request:
```json
{ "old_password": "123456", "new_password": "newpass" }
```

Response 200: `{ "message": "密码修改成功" }`；400 当前密码错误。

## 健康检查

### GET /api/v1/health

Response 200:
```json
{ "status": "ok", "database": "up" }
```

数据库不可用时返回 `{ "status": "degraded", "database": "down" }`。
