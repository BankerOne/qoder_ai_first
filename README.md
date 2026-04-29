# AI-First Scaffold

面向 AI 端到端交付的全栈脚手架。将 SDD（规约驱动开发）方法论与最小可运行的 FastAPI + React 工程骨架固化为起步模板，让 AI Agent 从第一行代码起就具备工程化产能。

---

## 特性

- **AI 入口**：根目录 `AGENTS.md` 是 AI Agent 的唯一入口，渐进式披露详细文档
- **SDD 方法论**：内置三种 Spec 类型（Requirements-first / Design-first / Bugfix）
- **Qoder 集成**：`.qoder/` 中的 Skills / Subagent / Hooks 覆盖 Spec 全生命周期
- **LeanSpec 工具链**：`.lean-spec/` 提供模板与 CLI 管理
- **harness 自验证**：`harness/verify-api.sh` 端到端调用真实 API，发现问题立即修复
- **最小可运行样例**：注册 / 登录 / /users/me / 健康检查 + React 登录 + Dashboard

## 开箱技术栈

- **后端**：Python 3.13 + FastAPI + SQLAlchemy + Alembic + JWT + bcrypt + pytest
- **前端**：React 18 + TypeScript + Vite 6 + Tailwind 3 + Zustand + React Router v7 + vitest
- **数据库**：SQLite（开发），Alembic 管理迁移

## 快速开始

```bash
# 1. 克隆脚手架
git clone <this-scaffold> ai-first-scaffold
cd ai-first-scaffold

# 2. 派生新项目到同级目录
./init.sh my-project ../my-project

# 3. 进入新项目
cd ../my-project

# 4. 启动后端（自动创建 venv、迁移、启动 uvicorn）
./harness/start-backend.sh

# 5. 启动前端
./harness/start-frontend.sh

# 6. 访问
#    后端 API 文档：http://localhost:8000/docs
#    前端页面：http://localhost:5173
```

### init.sh 参数

```bash
./init.sh <project-name> [target-dir]

# 选项
#   --no-git              不初始化 git 仓库
#   --keep-sample-spec    保留 specs/001-user-auth 教学样例（默认保留）
#   --drop-sample-spec    派生时清空 specs/ 目录
```

## 自验证

```bash
# 单元测试
./harness/test-backend.sh -v
./harness/test-frontend.sh

# 端到端 API 验证（需后端已启动）
./harness/verify-api.sh auth

# 前端冒烟（需前端已启动）
./harness/verify-frontend.sh
```

## 目录导读

| 路径 | 内容 |
|---|---|
| `AGENTS.md` | AI Agent 入口 + 仓库地图 |
| `docs/sdd_flow.md` | SDD 方法论详解 |
| `docs/architecture.md` | 系统架构设计 |
| `docs/dev-guide.md` | 详细开发规范 |
| `specs/001-user-auth/` | Requirements-first 教学样例 |
| `.qoder/skills/` | `/leanspec-propose`、`/leanspec-apply`、`/leanspec-archive`、`/leanspec-explore` |
| `.qoder/agents/spec-test-generator.md` | 从 Spec 自动生成 pytest 的 Subagent |
| `.qoder/hooks/validate-spec.sh` | Spec 修改时自动触发 `lean-spec validate` |
| `harness/` | 启动、测试、端到端验证脚本 |

## 设计理念

1. **代码是唯一真理源**。Spec 文档服务于开发过程，不强制长期归档。
2. **渐进式披露**。AGENTS.md 200 行以内作为"地图"，详细规范按需加载。
3. **自动化优先**。AI 完成编码后自发运行 harness 脚本自验证，发现问题自行修复。
4. **可扩展**。脚手架只保留通用能力，业务模块按需追加。

## License

GNU General Public License v3.0 — 详见 [LICENSE](./LICENSE)
