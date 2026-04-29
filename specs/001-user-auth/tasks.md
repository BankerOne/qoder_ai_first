# Tasks: User Auth - 用户认证模块

> Related: [requirements.md](./requirements.md) · [design.md](./design.md)

## Implementation Strategy

- **开发方法**: API 先行，pytest 验证
- **集成策略**: 认证模块独立开发，其他模块通过 `dependencies.py` 依赖注入
- **验证方式**: Swagger UI 手动测试 + pytest 自动测试

## Phase 1: 基础设施

- [x] **Task 1.1**: 创建项目结构和配置
  - 创建 `back_end/app/` 目录结构（main.py, config.py, database.py, dependencies.py）
  - 创建 `requirements.txt`，安装 FastAPI、uvicorn、SQLAlchemy 等
  - 配置 pydantic-settings（数据库 URL、JWT 密钥、JWT 过期时间）
  - 配置 SQLAlchemy 引擎、SessionLocal、Base
  - Test: `uvicorn app.main:app --reload` 启动成功
  - Refs: REQ-1, REQ-2, REQ-3, REQ-4

- [x] **Task 1.2**: 创建 User 数据模型和 Schema
  - 创建 `models/user.py`（User: id, phone, name, password_hash, role, timestamps）
  - 创建 `schemas/user.py`（UserCreate, UserLogin, UserResponse, Token）
  - Test: 模型导入无报错
  - Refs: REQ-1

## Phase 2: 认证 API

- [x] **Task 2.1**: 实现密码和 JWT 工具
  - 创建 `utils/security.py`（passlib bcrypt 封装）
  - 创建 `utils/jwt.py`（python-jose Token 生成与验证）
  - Test: 密码哈希/验证、Token 编解码正确
  - Refs: REQ-1, REQ-2

- [x] **Task 2.2**: 实现注册和登录 API
  - 创建 `routers/auth.py`：POST `/api/v1/auth/register`
  - 创建 `routers/auth.py`：POST `/api/v1/auth/login`
  - Test: Swagger UI 测试注册→登录流程
  - Refs: REQ-1, REQ-2

- [x] **Task 2.3**: 实现用户信息和密码修改 API
  - 创建 `dependencies.py`：`get_current_user` 依赖
  - 创建 `routers/users.py`：GET `/api/v1/auth/me`
  - 创建 `routers/users.py`：PUT `/api/v1/auth/password`
  - Test: 携带 Token 获取用户信息、修改密码
  - Refs: REQ-3, REQ-4

## Phase 3: 数据库迁移

- [x] **Task 3.1**: 配置 Alembic 并生成初始迁移
  - 配置 Alembic（alembic init，修改 env.py）
  - 生成初始迁移（alembic revision --autogenerate）
  - 执行迁移（alembic upgrade head）
  - Test: 数据库文件生成，表结构正确
  - Refs: REQ-1

## Phase 4: 单元测试

- [x] **Task 4.1**: 配置 pytest 测试基础设施
  - 配置 pytest + TestClient
  - 创建测试 fixture（测试数据库、认证 token）
  - Test: `./harness/test-backend.sh -v` 可执行
  - Refs: REQ-1, REQ-2, REQ-3, REQ-4

- [x] **Task 4.2**: 用户认证测试
  - 注册成功、重复注册 409、登录成功、错误密码 401、无效手机号 422
  - Test: `./harness/test-backend.sh -v tests/test_auth.py` 全部通过（8 项）
  - Refs: REQ-1, REQ-2

- [x] **Task 4.3**: 用户信息测试
  - 获取当前用户、未认证 401、修改密码成功、错误当前密码 400
  - Test: `./harness/test-backend.sh -v tests/test_users.py` 全部通过（5 项）
  - Refs: REQ-3, REQ-4

## Verification Checklist

- [x] Phase 1-3 所有 Tasks 完成
- [x] Phase 4 单元测试完成（13/13 通过）
- [x] 所有 Acceptance Criteria (requirements.md) 通过 Swagger 手动验证
- [x] `./harness/verify-api.sh auth` 端到端验证通过（7/7）
- [ ] Code Review 通过
