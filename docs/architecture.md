# 系统架构设计

> 本文档为 AI 按需加载的详细架构文档，AGENTS.md 中通过路径索引引导加载。

---

## 架构概览

采用**前后端分离**架构，Mono-repo 管理。默认单机开发模式，生产部署待项目按需选择。

```
┌─────────────────────────────────────────────┐
│                   客户端                      │
│          React SPA (localhost:5173)           │
└───────────────────┬─────────────────────────┘
                    │ HTTP / JSON
                    ▼
┌─────────────────────────────────────────────┐
│              FastAPI 后端                     │
│           (localhost:8000)                    │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Routers  │  │  Schemas  │  │  Utils   │   │
│  │ (API 层)  │  │ (验证层)  │  │ (JWT等)  │   │
│  └────┬─────┘  └──────────┘  └──────────┘   │
│       │                                      │
│  ┌────▼─────┐  ┌──────────┐                 │
│  │  Models   │  │  Deps    │                 │
│  │ (ORM 层)  │  │ (依赖注入)│                 │
│  └────┬─────┘  └──────────┘                 │
│       │                                      │
│  ┌────▼──────────────────────────────────┐   │
│  │       SQLAlchemy + SQLite              │   │
│  │          (app.db / test.db)            │   │
│  └───────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## 后端分层

```
back_end/app/
├── main.py           # 应用入口：创建 FastAPI 实例、注册中间件、挂载路由
├── config.py         # 配置层：pydantic-settings，从环境变量/.env 读取
├── database.py       # 数据层：Engine、SessionLocal、Base、get_db()
├── dependencies.py   # 依赖注入：认证(get_current_user)、权限(require_role)
├── routers/          # API 层：每个业务模块一个文件
│   ├── auth.py       #   注册、登录
│   ├── users.py      #   用户管理（/me、改密）
│   └── health.py     #   健康检查（进程 + 数据库）
├── schemas/          # 验证层：Pydantic 请求/响应模型
│   └── user.py
├── models/           # ORM 层：SQLAlchemy 模型
│   └── user.py       #   User, UserRole (admin/user)
└── utils/            # 工具层
    ├── jwt.py        #   JWT 签发/验证
    └── security.py   #   bcrypt 密码哈希
```

### 请求处理流程

```
HTTP Request
  → CORS Middleware
    → Router (路由匹配)
      → Depends(bearer_scheme) → get_current_user → require_role (认证链)
      → Depends(get_db) (数据库会话)
        → Schema 验证（Pydantic）
          → 业务逻辑 + ORM 操作
            → Schema 序列化响应
```

### 认证流程

**角色**：`admin`、`user`（枚举 `UserRole`，位于 `back_end/app/models/user.py`）。新项目可按需扩展或替换。

**登录链路**：

```
POST /api/v1/auth/login  { phone, password }
   → 验证密码哈希 (bcrypt)
   → 签发 JWT（payload: sub=user_id, role）
   → 返回 { access_token, token_type: "bearer" }

后续请求 Header: Authorization: Bearer <token>
   → HTTPBearer 提取
   → decode_access_token 验证
   → get_current_user 查库加载 User
   → require_role(UserRole.ADMIN) 做角色守卫
```

## 前端分层

```
front_end/src/
├── App.tsx                  # 路由定义
├── main.tsx                 # 入口，hydrateAuth() 注入 token
├── components/
│   ├── Layout.tsx           # 已登录区布局（顶栏 + Outlet）
│   ├── RequireAuth.tsx      # 路由守卫
│   ├── RootRedirect.tsx     # 根路径分发
│   └── ui/                  # CVA 变体组件（Button, Card）
├── pages/
│   ├── LoginPage.tsx
│   └── Dashboard.tsx
├── services/
│   └── auth.ts              # API Service 层
├── store/
│   └── authStore.ts         # Zustand + persist 持久化
├── lib/
│   ├── apiClient.ts         # Axios 封装 + 拦截器
│   └── utils.ts             # cn() 等工具
├── types/
│   └── api.ts               # 与后端 Schema 对齐的 TS 类型
└── test/
    ├── setup.ts             # vitest 全局配置
    └── App.test.tsx         # 冒烟测试
```

### 数据流

```
UI (Page/Component)
  → services/* (业务封装)
    → lib/apiClient (axios 拦截器注入 token、处理 401/5xx toast)
      → 后端
    ← 返回 Promise<T>
  ← 页面 setState 或 store.setX()
```

### 状态管理

- **全局**：Zustand（`authStore` 为示例），`persist` 中间件持久化到 localStorage
- **局部**：React `useState` / `useReducer`
- **跨组件通讯**：props > context > zustand，按需递进

## 部署

默认提供本地开发模式（`harness/start-*.sh`）。生产部署策略建议：

- 后端：uvicorn / gunicorn + Nginx，数据库切换为 PostgreSQL
- 前端：`npm run build` 产物托管于 CDN 或 Nginx 静态目录
- 环境变量：通过 `.env` 或云厂商 Secret Manager 注入 `JWT_SECRET_KEY`、`DATABASE_URL`、`CORS_ORIGINS`
