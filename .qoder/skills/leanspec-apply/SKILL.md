---
name: leanspec-apply
description: Implement tasks from a LeanSpec Spec. Reads the tasks file, shows progress, and implements tasks one by one, marking each complete. Use when the user wants to start implementing, continue implementation, or work through spec tasks.
---

从 Spec 实现任务 —— 执行计划。

**输入**：可选指定 Spec 名称或编号。省略时从上下文自动检测或提示选择。

**流程**

1. **选择 Spec**

   如果提供了名称/编号，直接使用。否则：
   - 检查对话上下文是否提及某个 Spec
   - 执行 `lean-spec list --status in-progress` 查找活跃 Spec
   - 若有多个，用 **AskUserQuestion 工具** 让用户选择
   - 若仅一个进行中的 Spec，自动选择

   始终宣布：“正在实现：**NNN-<name>**”

2. **读取 Spec 上下文**

   通过检查目录文件确定 Spec 类型：

   **需求驱动型**（有 requirements.md + design.md + tasks.md）：
   - 读取 `requirements.md` 获取验收标准
   - 读取 `design.md` 获取架构和 API 设计
   - 读取 `tasks.md` 获取任务列表

   **设计驱动型**（有 design.md + requirements.md + tasks.md，README.md 中 `type: design-first`）：
   - 读取 `design.md` 获取技术设计和架构
   - 读取 `requirements.md` 获取派生需求和验收标准
   - 读取 `tasks.md` 获取任务列表

   **缺陷修复型**（README.md 中 `type: bugfix`）：
   - 读取 `README.md`，任务在“Fix Tasks”章节
   - 特别关注“不变行为”章节

3. **显示当前进度**

   解析任务列表并展示：
   - Spec 类型
   - 进度：“N/M 个任务已完成”
   - 剩余任务概览

4. **实现任务（循环直到完成或阻塞）**

   对每个待办任务（标记 `- [ ]`）：
   - 宣布当前工作任务
   - 读取 AGENTS.md 获取项目约定
   - 进行代码变更
   - 保持变更最小化、聚焦于当前任务
   - 按任务的 "Test:" 字段运行相关测试
   - **自验证**（见下方验证步骤）
   - 标记完成：`- [ ]` → `- [x]`
   - 继续下一个任务

   **缺陷修复型实现顺序：**
   1. 编写缺陷复现测试（验证当前行为）
   2. 实现修复
   3. 验证预期行为测试通过
   4. 验证不变行为测试仍通过

   **暂停条件：**
   - 任务不清晰 → 要求澄清
   - 实现中发现设计问题 → 建议更新 Spec
   - 遇到错误或阻塞 → 报告并等待
   - 用户中断

5. **每个任务完成后自验证**

   实现后，验证通过才能标记完成：

   **后端变更：**
   1. 运行单元测试：`./harness/test-backend.sh -v`（必须通过）
   2. 若 API 端点变更：运行 `./harness/verify-api.sh <module>`
      - `auth` 认证相关
      - （更多模块在本项目派生后按需扩展，参考 docs/dev-guide.md「端到端验证规范」）
   3. 测试失败 → 修复 → 重跑 → 重复直到通过

   **前端变更：**
   1. 运行 `./harness/verify-frontend.sh`（TypeScript 检查 + 页面可访问性）
   2. UI/交互变更：用 **Browser Agent**：
      - 打开 `http://localhost:5173`
      - 导航到受影响页面
      - 执行用户操作
      - 截图验证结果
   3. 验证失败 → 修复 → 重新验证

   **仅在验证通过后才标记 `- [x]`。**

6. **完成或暂停时显示状态**

   展示：
   - 本次完成的任务
   - 总体进度：“N/M 个任务已完成”
   - 若全部完成：建议执行 `/leanspec-archive`
   - 若暂停：说明原因和后续步骤

**实现过程输出**

```
## 正在实现：NNN-<name>（类型：<spec-type>）

工作中 任务3/7：<任务描述>
[…实现中…]
任务完成

工作中 任务4/7：<任务描述>
[…实现中…]
任务完成
```

**完成时输出**

```
## 实现完成

**Spec：** NNN-<name>
**类型：** <spec-type>
**进度：** 7/7 个任务已完成

### 本次完成
- [x] 任务 1: ...
- [x] 任务 2: ...

所有任务已完成！执行 `/leanspec-archive` 归档此 Spec。
```

**暂停时输出**

```
## 实现已暂停

**Spec：** NNN-<name>
**进度：** 4/7 个任务已完成

### 遇到的问题
<描述>

**选项：**
1. <选项>
2. <选项>

你希望怎么处理？
```

**护栏**
- 开始实现前必须读取完整 Spec 上下文
- 保持代码变更最小化，聚焦当前任务
- 每完成一个任务立即更新 checkbox
- **每个任务必须自验证** —— 未运行验证不得标记完成
- 后端：变更后始终运行 `./harness/test-backend.sh`
- API 变更：对运行中的服务器执行 `./harness/verify-api.sh <module>`
- 前端：运行 `./harness/verify-frontend.sh` + Browser Agent 检查交互
- 缺陷修复型：必须验证不变行为未被破坏
- 实现中发现 Spec 问题时，暂停并建议更新 —— 不要猜测
- 遵循 AGENTS.md 的项目约定（命名、文件结构等）
- 尽可能运行任务 "Test:" 字段指定的测试
- 不要跳过所有任务完成后的验证清单
