# 方法论：规约驱动开发（Spec-Driven Development）

本方案以 Spec-Driven Development（SDD，规约驱动开发） 为核心方法论。其要点是：

1. **以 Spec 文档驱动研发**。每个功能需求 / 技术设计 / Bug 修复对应一组 Spec 文档，AI 基于 Spec 逐步推进编码，人类负责关键节点的审查。
2. **渐进式披露**。工程规范不是一次性全量灌入 AI 上下文，而是通过 AGENTS.md 作为"地图"，引导 AI 在需要时按需加载详细文档。控制上下文窗口占用，提高生成质量。
3. **代码是唯一真理源**。Spec 文档作为一次性产物服务于开发过程，不强制归档维护。所有设计决策最终沉淀在代码和工程结构中，而非文档。
4. **三种 Spec 类型覆盖全场景**。参考 Kiro 的 Spec-Driven Development 理念，支持 Requirements-first（需求驱动）、Design-first（设计驱动）、Bugfix（Bug 防回归）三种 Spec 类型，由 AI 根据意图自动识别。
5. **LeanSpec + Qoder 工具链**。采用 LeanSpec 作为 Spec 框架（轻量级、自定义模板、CLI 管理），通过 Qoder Skills / Subagent / Hooks 实现端到端自动化。

---

# 三种 Spec 类型

SDD 的核心创新：根据任务性质选择不同的 Spec 结构，而非一刀切。

## Requirements-first（需求驱动）

**适用场景**：知道「要做什么」但不确定「怎么做」。新功能开发、用户故事实现。

**文档结构**（三文件）：
```
specs/NNN-feature-name/
├── requirements.md   ← EARS 格式需求（User Story + GIVEN/WHEN/THEN SHALL 验收条件）
├── design.md         ← 技术设计（架构、数据模型、API、安全、测试策略）
└── tasks.md          ← 分 Phase 实施任务，每个 task 引用 REQ-N
```

**流程**：需求 → 设计 → 任务 → 编码

## Design-first（设计驱动）

**适用场景**：知道「怎么做」（技术方案已定）。迁移、重构、基于已知架构的实现。

**文档结构**（三文件）：
```
specs/NNN-feature-name/
├── design.md         ← 先写技术设计（架构、数据模型、API、安全、测试策略）
├── requirements.md   ← 再反推需求（Derived Requirements，REQ-N + EARS 验收条件）
└── tasks.md          ← 最后拆任务，每个 task 引用 REQ-N
```

**流程**：设计 → 反推需求 → 任务 → 编码

## Bugfix（Bug 防回归）

**适用场景**：修复 Bug，需要防止回归。

**文档结构**（单文件，Kiro 三段式）：
```
specs/NNN-bug-name/
└── README.md         ← 当前行为 / 期望行为 / 不变行为 / 根因 / 修复任务
```

**流程**：定义行为 → 根因分析 → 修复设计 → 编码（先写复现测试 → 修复 → 验证回归）

**关键创新**：Unchanged Behavior 段 — 明确列出「不应被修改影响的行为」，强制生成回归测试，防止修 A 坏 B。

---

# Spec 生命周期（Skill 驱动）

Spec 的创建、实施、归档通过 Qoder Skills 端到端驱动，开发者无需手动管理文件结构。

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Explore     │     │   Propose     │     │    Apply      │     │   Archive     │
│ /leanspec-    │ ──→ │ /leanspec-    │ ──→ │ /leanspec-    │ ──→ │ /leanspec-    │
│  explore      │     │  propose      │     │  apply        │     │  archive      │
│ 思考，不编码   │     │ 创建 Spec     │     │ 逐任务实施    │     │ 归档完成      │
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
        ↑                                         │
        └─────── 发现设计问题时回退 ────────────────┘
```

### Step 0 — 探索（可选）`/leanspec-explore`

当需求模糊、需要方案对比、架构讨论时进入。纯思考模式，不写应用代码。
- 探索问题空间、调查代码库、用 ASCII 图可视化
- 当洞察成熟时，建议切到 `/leanspec-propose`

### Step 1 — 创建 Spec `/leanspec-propose`

AI 根据用户描述**自动识别 Spec 类型**：
- 关键词 "add feature"、"I want users to..." → Requirements-first
- 关键词 "migrate to..."、"refactor using..." → Design-first
- 关键词 "fix"、"bug"、"broken"、"error" → Bugfix
- 不确定时，主动询问用户

自动读取对应模板（`.lean-spec/templates/`），生成结构化 Spec 文档。
开发者审查确认，有问题通过对话调整。

### Step 2 — 逐任务实施 `/leanspec-apply`

- 读取 Spec 上下文，展示进度："N/M tasks complete"
- 逐个任务编码，完成后更新 checkbox `- [ ]` → `- [x]`
- **Bugfix 特殊顺序**：写复现测试 → 修复 → 验证 Expected → 验证 Unchanged
- 遇到阻塞时暂停并报告，不猜测

**每个任务完成后必须自验证，通过后才能标记完成：**

后端改动：
```bash
# 1. 单元测试（必须通过）
./harness/test-backend.sh -v

# 2. 端到端 API 验证（针对运行中的后端服务）
./harness/verify-api.sh auth       # 脚手架内置 auth，后续模块按需扩展
```

前端改动：
```bash
# 1. TypeScript 类型检查 + 页面可访问性
./harness/verify-frontend.sh

# 2. 交互验证：通过 Browser Agent 打开页面、操作、截图自检
```

发现问题自行修复，重复验证直到通过。

### Step 3 — 归档 `/leanspec-archive`

- 检查任务完成度和 Verification Checklist
- 更新状态并归档：`lean-spec update --status complete && lean-spec archive`

### 会话管理原则

一个 Spec 对应一个会话，完成后关闭。不同需求之间不共享会话——两个需求的上下文本来就没有关联，混在一起只会污染上下文。

---

# 工具链架构

## LeanSpec — Spec 框架

轻量级 Spec 管理框架，提供 CLI + 自定义模板 + 可选 MCP Server。

```
.lean-spec/
├── config.json                    # 配置：模板注册、aiAgents: true、验证阈值
└── templates/
    ├── requirements-template.md   # Requirements-first 需求模板
    ├── design-template.md         # Requirements-first 设计模板
    ├── tasks-template.md          # 通用任务模板（Requirements-first 和 Design-first 共用）
    ├── design-first-template.md   # Design-first README 入口模板
    ├── design-first-design-template.md   # Design-first 设计模板
    ├── design-first-requirements-template.md # Design-first 派生需求模板
    └── bugfix-template.md         # Bugfix 单文件模板（Kiro 三段式）
```

**核心配置**（`.lean-spec/config.json`）：
- `aiAgents: true` — 启用 AI 集成
- `templates` — 注册七种模板（default / design / tasks / bugfix / design-first / design-first-design / design-first-requirements）
- `validation.maxLines: 400` — 单文件不超过 400 行（Context Economy）
- `features.dependencyGraph: true` — 启用 Spec 依赖图

## Qoder Skills — 工作流自动化

四个 LeanSpec Skills 封装完整的 Spec 生命周期：

| Skill | 触发命令 | 职责 |
|---|---|---|
| leanspec-explore | `/leanspec-explore` | 纯思考模式：探索问题、对比方案、不写代码 |
| leanspec-propose | `/leanspec-propose` | 自动识别 Spec 类型，创建结构化 Spec 文档 |
| leanspec-apply | `/leanspec-apply` | 逐任务实施，更新进度，运行验证 |
| leanspec-archive | `/leanspec-archive` | 检查完成度，归档已完成的 Spec |

## spec-test-generator — 测试生成 Subagent

从 Spec 验收条件自动生成 pytest 测试用例（`.qoder/agents/spec-test-generator.md`）：
- Requirements-first：每个 REQ-N 验收条件 → `test_req{N}_ac{M}_{description}`
- Bugfix：生成三类测试 — Bug 复现 / 修复验证 / 回归测试
- Design-first：从 Derived Requirements 生成测试

## Hooks — 自动质量门禁

Spec 文件修改后自动触发 `lean-spec validate`（`.qoder/hooks/validate-spec.sh`）：
- 触发条件：PostToolUse（Write | Edit）
- 检查范围：`specs/` 目录下的文件
- 行为：验证失败时发出警告，不阻止操作

### AGENTS.md — 意图路由 + 仓库地图

AGENTS.md 承担双重职责：
1. **意图路由**：根据用户请求特征自动推荐工作模式（Spec / Apply / Explore / 直接执行）
2. **仓库地图**：项目概述、技术栈、目录结构、核心规则、命名约定、常用命令、文档导航

具体内容要求参见上方「工程规范体系」章节。

---

# 工程规范体系

## AGENTS.md — 仓库使用说明（地图，非手册）

在工程根目录放置 AGENTS.md，控制在 200 行以内。它是每个 AI 会话启动时自动加载的唯一文件，为 agent 提供仓库的全局认知。

内容包括：
- **项目启动脚本**：后端启动、前端启动、构建命令、架构约束分层检查脚本
- **关键开发约定**：编码规范摘要、建表约束、SQL 规范、接口契约等行内技术规范的精要版本
- **本地验证流程**：如何启动项目、如何登录获取 token、如何通过 curl / 浏览器完成自测
- **文档导航**：引导 AI 在需要详细信息时按需加载 docs/ 目录下的具体文档

设计思想：AGENTS.md 是"地图"——告诉 AI 这个仓库有什么、在哪里、什么时候该去看什么。详细内容通过文档引用按需加载（渐进式披露），避免一次性灌满上下文窗口。

## docs/ — 详细规范目录

存放 AI 按需加载的详细文档，AGENTS.md 中通过路径索引引导 AI 在需要时加载：

| 路径 | 内容 |
|------|------|
| `docs/architecture.md` | 完整系统架构设计 |
| `docs/dev-guide.md` | 详细开发规范（前端架构规范、后端分层约束、异常处理、幂等规范等） |
| `docs/api-contracts/` | 对接接口文档、报文规范 |
| `docs/db-schema/` | 数据库表结构、数据字典、元数据 |
| `docs/references/` | 参考项目源码说明、何时参考、如何参考 |

## 行内技术规范转化

如果项目有已有的技术规范（架构分层、模块目录结构、前端路由设计、数据库访问规范、SQL 写法、建表约束、字段约束等），需要梳理并转化为 AI 可执行的工程约束，落入 AGENTS.md（精要版）和 docs/（详细版）体系。这是项目启动前的关键准备工作。

---

# 仓库结构

采用 Mono-repo 模式，前后端、Spec、工具链配置放在同一仓库：

```
ai-first-scaffold/
├── AGENTS.md                    # AI 入口：意图路由 + 仓库地图
├── front_end/                   # React + TypeScript + Vite 前端
│   └── src/
├── back_end/                    # Python + FastAPI 后端
│   ├── app/
│   └── tests/
├── specs/                       # Spec 文档（LeanSpec 管理）
│   ├── 001-user-auth/
│   ├── 002-<feature-b>/
│   ├── 003-<feature-c>/
│   └── 004-<feature-d>/
├── .lean-spec/                  # LeanSpec 配置 + 模板
│   ├── config.json
│   └── templates/
├── .qoder/                      # Qoder 扩展
│   ├── skills/                  # 4 个 LeanSpec Skills
│   ├── agents/                  # spec-test-generator Subagent
│   ├── hooks/                   # 自动验证 Hook
│   └── settings.local.json      # Hook 配置
├── docs/                        # 详细规范文档（按需加载）
└── harness/                     # 辅助脚本
```

Mono-repo 的好处：一个开发者负责一个完整功能模块时，前后端上下文不中断，AI 可以在同一个会话中完成全栈开发。Spec、模板、Skills 统一管理。

---

# Spec 管理策略

Spec 文档作为一次性产物，服务于当次开发过程，不强制长期归档维护。

**理由**：
1. 代码是唯一真理源——设计决策最终体现在代码结构和注释中
2. Spec 的核心价值在于开发过程中的需求澄清和设计约束引导，而非文档资产
3. 维护 Spec 与代码的同步成本高，收益不成比例

**归档策略**：
- 功能完成后通过 `/leanspec-archive` 归档，Spec 保留在 `specs/` 目录作为历史记录
- 归档的 Spec 不要求与最新代码保持同步
- 如需了解某功能的设计决策，优先看代码和注释，Spec 作为辅助参考

**模板定制**：
- LeanSpec 支持自定义模板（`.lean-spec/templates/`），可针对不同项目场景定制
- 当前已配置七种模板覆盖三种 Spec 类型
- 所有模板遵循 Context Economy 原则：单文件不超过 400 行

---