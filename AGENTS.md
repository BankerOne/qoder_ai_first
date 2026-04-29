# AGENTS.md

> AI Agent 的**唯一入口文件**。渐进式披露：核心规则在此，详细规范通过路径索引获取。

---

## 项目概述

**AI-First Scaffold** — 面向 AI 端到端交付的全栈脚手架。

- 核心理念：SDD（规约驱动开发）+ 渐进式披露 + harness 自验证
- 开箱能力：JWT 认证、Alembic 迁移、Tailwind + Zustand + React Router 守卫、pytest + vitest
- 当前阶段：脚手架 MVP，业务代码仅保留最小样例（认证 + 健康检查）

## 技术栈

| 层 | 技术 | 版本约束 |
|---|---|---|
| 前端框架 | React + TypeScript + Vite | React 18, Vite 6 |
| UI 方案 | TailwindCSS + CVA + lucide-react | Tailwind 3 |
| 状态管理 | Zustand | v4 |
| 路由 | React Router DOM | v7 |
| 后端框架 | Python + FastAPI | Python 3.13 |
| ORM / 迁移 | SQLAlchemy + Alembic | — |
| 数据库 | SQLite（开发） | 生产待项目按需选择 |
| 认证 | JWT (python-jose) + bcrypt (passlib) | — |
| 测试 | pytest + FastAPI TestClient + vitest | — |

## 目录结构

```
ai-first-scaffold/
├── AGENTS.md                 ← 你在这里
├── README.md                 ← 脚手架使用说明
├── init.sh                   ← 一键派生新项目
├── front_end/                ← React 前端（最小样例：登录 + Dashboard）
│   ├── src/
│   │   ├── components/       # 可复用组件（Layout, RequireAuth, RootRedirect, ui/）
│   │   ├── pages/            # 页面组件（LoginPage, Dashboard）
│   │   ├── store/            # Zustand store（authStore）
│   │   ├── services/         # API Service 层（auth）
│   │   ├── lib/              # 工具（apiClient.ts, utils.ts）
│   │   └── App.tsx           # 路由入口
│   ├── package.json
│   ├── vite.config.ts        # 路径别名 @ → src/
│   └── tailwind.config.ts
├── back_end/                 ← FastAPI 后端（最小样例：auth + users + health）
│   ├── app/
│   │   ├── main.py           # 应用入口，路由注册
│   │   ├── config.py         # pydantic-settings 配置
│   │   ├── database.py       # SQLAlchemy 引擎 & session
│   │   ├── dependencies.py   # 依赖注入（认证、权限）
│   │   ├── models/           # SQLAlchemy 模型（user）
│   │   ├── routers/          # API 路由（auth, users, health）
│   │   ├── schemas/          # Pydantic 请求/响应 schema
│   │   └── utils/            # 工具（jwt.py, security.py）
│   ├── tests/                # pytest 测试
│   ├── alembic/              # 数据库迁移
│   └── requirements.txt
├── specs/                    ← Spec 文档（LeanSpec + Kiro 风格）
│   └── 001-user-auth/        # 教学样例（Requirements-first）
├── .lean-spec/               ← LeanSpec 配置和模板
├── .qoder/                   ← Qoder Skills / Subagent / Hooks
├── docs/                     ← 详细规范文档（见「信息索引」）
└── harness/                  ← 辅助工具脚本（见「信息索引」）
```

## 编码约束

> 角色权限详见 `docs/architecture.md`「认证流程」，Git 规范详见 `docs/dev-guide.md`「Git 工作流」

### 命名约定

| 范围 | 规则 | 示例 |
|---|---|---|
| Python 文件/模块 | snake_case | `user.py` |
| Python 类 | PascalCase | `UserRole`, `User` |
| Python 函数/变量 | snake_case | `create_access_token` |
| API 路由前缀 | `/api/v1/` + 复数名词 | `/api/v1/users` |
| TS/TSX 组件文件 | PascalCase | `Dashboard.tsx` |
| TS 工具/store 文件 | camelCase | `authStore.ts`, `utils.ts` |
| React 组件导出 | PascalCase | `Dashboard` |
| CSS | TailwindCSS utility-first | 禁止自定义 CSS 文件 |

### 后端规则

1. API 路由放 `app/routers/`，通过 `main.py` 的 `include_router()` 注册
2. 数据模型放 `app/models/`，请求/响应 schema 放 `app/schemas/`
3. 新增/修改表结构必须通过 Alembic 迁移，禁止手动改库
4. 配置从环境变量 / `.env` 读取（`pydantic-settings`），禁止硬编码
5. 密码用 bcrypt 哈希，禁止明文存储
6. 所有 API 响应遵循统一格式，详见 `docs/dev-guide.md`「API 契约」章节

### 前端规则

1. 路由在 `App.tsx` 定义，新页面放 `pages/`
2. 可复用 UI 放 `components/ui/`，用 CVA 管理组件变体
3. 全局状态用 Zustand（`store/`），局部状态用 React hooks
4. 路径别名 `@` → `src/`
5. 类名合并用 `tailwind-merge` + `clsx`（封装在 `lib/utils.ts`）
6. 图标统一用 `lucide-react`

## 开发模式指引

根据用户请求自动选择合适的工作模式：

| 请求特征 | 推荐模式 | 操作 |
|---|---|---|
| 新功能开发（多文件/多模块） | Spec (Requirements-first) | `/leanspec-propose` |
| 技术方案已定，需要实施 | Spec (Design-first) | `/leanspec-propose` |
| Bug 修复（需防止回归） | Spec (Bugfix) | `/leanspec-propose` |
| 已有 Spec，继续实施任务 | Apply | `/leanspec-apply` |
| 简单修改（单文件/格式化/小调整） | 直接执行 | 无需 Spec |
| 代码问答 / 理解代码 | Ask | 直接回答 |
| 复杂探索 / 架构讨论 | Explore | `/leanspec-explore` |
| Spec 已完成 | Archive | `/leanspec-archive` |

## 常用命令

```bash
# 启动服务（推荐使用 harness 脚本）
./harness/start-backend.sh            # 后端: venv + 迁移 + uvicorn (localhost:8000)
./harness/start-frontend.sh           # 前端: npm install + vite (localhost:5173)

# Alembic 迁移
cd back_end && source venv/bin/activate
alembic revision --autogenerate -m "描述"
alembic upgrade head
```

## 信息索引

### docs/ — 详细规范

| 路径 | 内容 |
|---|---|
| `docs/sdd_flow.md` | **SDD 方法论**：三种 Spec 类型、生命周期、工具链架构 |
| `docs/architecture.md` | 系统架构设计（前后端分层、认证流程、数据流） |
| `docs/dev-guide.md` | 详细开发规范（API 契约、异常处理、测试规范、端到端验证规范、Git 工作流） |
| `docs/api-contracts/` | 接口文档 |
| `docs/db-schema/` | 数据库表结构 |
| `docs/references/` | 参考资料 |
| `docs/dev_plan.md` | 开发计划模板 |

### harness/ — 辅助脚本

| 脚本 | 用途 |
|---|---|
| `harness/start-backend.sh` | 激活 venv + 启动后端开发服务器 |
| `harness/start-frontend.sh` | 启动前端开发服务器 |
| `harness/test-backend.sh` | 运行后端 pytest |
| `harness/test-frontend.sh` | 运行前端 vitest |
| `harness/verify-api.sh` | **端到端 API 验证**：注册→登录→调用业务 API→断言返回值 |
| `harness/verify-frontend.sh` | 前端冒烟验证：TypeScript + 页面可访问性 |

### 本地验证流程

编码完成后，AI 应按以下顺序自验证：

```bash
# 1. 单元测试（必须通过）
./harness/test-backend.sh -v

# 2. 端到端 API 验证（需后端服务已启动）
./harness/verify-api.sh           # 全量
./harness/verify-api.sh auth      # 仅认证模块

# 3. 前端验证（需前端服务已启动）
./harness/verify-frontend.sh
```

**验证策略**：
- 后端改动 → `test-backend.sh` + `verify-api.sh <module>`
- 前端改动 → `verify-frontend.sh`（TypeScript + 页面可访问性）
- 前端交互验证 → Browser Agent 打开 `http://localhost:5173`，操作页面、截图自检
- 发现问题自行修复，重复直到通过

### specs/ — Spec 工作流

三种 Spec 类型详见 `docs/sdd_flow.md`，通过 `/leanspec-propose` 自动选择。当前 Spec 列表通过 `lean-spec list` 查看。
