# 参考资料

> 项目开发参考的外部资源与项目内模式。AGENTS.md 按需引导加载。

---

## 方法论参考

| 参考 | 用途 |
|---|---|
| [Kiro Spec-Driven Development](https://kiro.dev) | SDD 方法论：三种 Spec 类型灵感来源 |
| [LeanSpec](https://github.com/lean-spec) | Spec 管理框架 |
| [EARS](https://alistairmavin.com/ears/) | GIVEN/WHEN/THEN SHALL 需求格式 |

## 技术栈文档

| 技术 | 官方文档 | 何时参考 |
|---|---|---|
| FastAPI | https://fastapi.tiangolo.com | 路由、依赖注入、中间件 |
| SQLAlchemy 2.0 | https://docs.sqlalchemy.org/en/20/ | ORM 模型、查询 |
| Alembic | https://alembic.sqlalchemy.org | 数据库迁移 |
| Pydantic v2 | https://docs.pydantic.dev/latest/ | Schema 验证 |
| React 18 | https://react.dev | 组件、Hooks |
| React Router v7 | https://reactrouter.com | 路由配置 |
| Zustand v4 | https://zustand-demo.pmnd.rs | 全局状态 |
| TailwindCSS v3 | https://tailwindcss.com | 样式类名 |
| CVA | https://cva.style | 组件变体 |
| Vite | https://vite.dev | 构建配置 |

## 项目内参考模式

| 要做的事 | 参考文件 |
|---|---|
| 新增 API 路由 | `back_end/app/routers/auth.py` |
| 新增数据模型 | `back_end/app/models/user.py` |
| 新增 Pydantic Schema | `back_end/app/schemas/user.py` |
| 新增后端测试 | `back_end/tests/test_auth.py` |
| 新增页面 | `front_end/src/pages/Dashboard.tsx` |
| 新增 UI 组件 | `front_end/src/components/ui/button.tsx` |
| 新增前端 Service | `front_end/src/services/auth.ts` |
| 新增 Zustand store | `front_end/src/store/authStore.ts` |
