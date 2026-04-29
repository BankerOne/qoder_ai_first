---
name: leanspec-propose
description: Create a new Spec for feature development or bug fixing. Automatically detects the appropriate spec type (Requirements-first, Design-first, or Bugfix) based on user intent. Use when the user wants to plan a new feature, implement a known technical design, or fix a bug with regression protection.
---

创建新 Spec —— 先规划，再编码。

**输入**：用户对要构建或修复内容的描述。可以是功能需求、技术设计或缺陷报告。

**流程**

1. **判断 Spec 类型**

   分析用户请求，确定最合适的类型：

   - **需求驱动**：用户描述“要什么”（新功能、用户可见行为），技术方案待定。关键词：“添加功能”、“我希望用户能…”、“实现…”
   - **设计驱动**：用户描述“怎么做”（技术栈、架构、迁移），技术方案已定。关键词：“迁移到…”、“重构为…”、“用 Redis 做…”
   - **缺陷修复**：用户描述需要修复的 bug 或异常行为。关键词：“修复”、“bug”、“报错”、“不工作”

   如果无法判断，使用 **AskUserQuestion 工具** 询问：
   > “应该创建哪种类型的 Spec？”
   > - 需求驱动：你知道要做什么，需要帮助确定怎么做
   > - 设计驱动：你已经确定了技术方案
   > - 缺陷修复：修复 bug，并防止回归

2. **创建 Spec 目录**

   从用户描述中提取 kebab-case 名称。

   ```bash
   lean-spec create <name> --tags <relevant-tags> --priority <high|medium|low>
   ```

   如果 `lean-spec create` 不可用或失败，手动创建：
   ```bash
   mkdir -p specs/NNN-<name>
   ```
   其中 NNN 为下一个序号。

3. **根据类型生成 Spec 文档**

   **需求驱动型**（三个文件）：

   a. 读取模板：`.lean-spec/templates/requirements-template.md`
   b. 创建 `specs/NNN-<name>/requirements.md`：
      - 概述：解决什么问题
      - REQ-N 条目，含用户故事和 EARS 验收标准
      - 非功能需求、约束
   c. 读取模板：`.lean-spec/templates/design-template.md`
   d. 创建 `specs/NNN-<name>/design.md`（从需求派生）：
      - 架构、数据模型、API 设计
      - 安全、错误处理、测试策略
   e. 读取模板：`.lean-spec/templates/tasks-template.md`
   f. 创建 `specs/NNN-<name>/tasks.md`（按阶段拆分）：
      - 每个任务引用 REQ-N
      - 每个任务有验证方法
   g. 创建 `specs/NNN-<name>/README.md`：入口文件，含 frontmatter 和导航链接

   **设计驱动型**（三个文件，顺序：设计 → 需求 → 任务）：

   a. 读取模板：`.lean-spec/templates/design-first-design-template.md`
   b. 创建 `specs/NNN-<name>/design.md`：
      - 技术愿景、架构、数据模型、API 设计
      - 安全、错误处理、测试策略、决策权衡
   c. 读取模板：`.lean-spec/templates/design-first-requirements-template.md`
   d. 创建 `specs/NNN-<name>/requirements.md`（从设计反推）：
      - 从技术设计反推出的功能需求（Derived Requirements）
      - REQ-N + EARS 验收标准
      - 非功能需求
   e. 读取模板：`.lean-spec/templates/tasks-template.md`
   f. 创建 `specs/NNN-<name>/tasks.md`（按阶段拆分）：
      - 每个任务引用 REQ-N
      - 每个任务有验证方法
   g. 创建 `specs/NNN-<name>/README.md`：入口文件，含 frontmatter（type: design-first）和导航链接

   **缺陷修复型**（单文件）：

   a. 读取模板：`.lean-spec/templates/bugfix-template.md`
   b. 调查缺陷：阅读相关代码文件理解问题
   c. 创建 `specs/NNN-<name>/README.md`：
      - 缺陷描述
      - 当前行为（精确的 WHEN/THEN）
      - 预期行为（WHEN/THEN SHALL）
      - 不变行为（WHEN/THEN SHALL CONTINUE TO）—— 回归防护的关键
      - 根因分析（含影响文件）
      - 修复设计（最小变更）
      - 修复任务（含三类测试）

4. **显示摘要**

   展示：
   - Spec 名称和位置
   - 选择的 Spec 类型
   - 关键需求/设计决策
   - 生成的任务数
   - 提示：“执行 `/leanspec-apply` 开始实现任务。”

**输出**

```
## Spec 已创建

**名称：** NNN-<name>
**类型：** [需求驱动 | 设计驱动 | 缺陷修复]
**位置：** specs/NNN-<name>/
**任务：** N 个任务，分 M 个阶段

### 摘要
[简要描述规约内容]

准备实现！执行 `/leanspec-apply` 开始工作。
```

**护栏**
- 生成前必须先读取对应模板
- 需求驱动型：需求 → 设计 → 任务，顺序不可颠倒
- 设计驱动型：设计 → 派生需求 → 任务，顺序不可颠倒
- 缺陷修复型：不变行为章节为**必选项**，不可跳过
- 每个文件不超过 300 行（上下文经济原则）
- 每个任务必须有测试/验证方法
- 需求驱动型的每个任务必须引用至少一个 REQ-N
- 所有验收标准使用 EARS 语法（GIVEN/WHEN/THEN SHALL）
- 读取 AGENTS.md 获取项目上下文（技术栈、命名约定）
- 用户在创建过程中提供的额外上下文应纳入其中
