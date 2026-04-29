---
name: leanspec-archive
description: Archive a completed Spec after all tasks are done. Checks task completion, updates status to complete, and records completion date. Spec stays in its original location to preserve references. Physical move to archived/ is optional and only used when explicitly requested. Use when the user wants to finalize a completed feature or bugfix.
---

归档已完成的 Spec —— 结项并关闭。

> **设计原则**：Spec 作为永久文档，归档的本质是**状态转换**，而非物理搬运。
> `status: complete` 是唯一真理源，目录位置保持稳定可以避免破坏跨文档引用、AGENTS.md 索引、Git 历史链接。
> **默认不移动目录**；仅在用户显式要求“归档到 archived/”或 Spec 数量压力严重时才执行 `lean-spec archive`。

**输入**：可选指定 Spec 名称或编号。省略时提示选择。

**流程**

1. **选择要归档的 Spec**

   若未提供名称：
   - 执行 `lean-spec list --status in-progress` 显示候选项
   - 用 **AskUserQuestion 工具** 让用户选择（支持多选批量归档）
   - 不自动选择，始终让用户确认

2. **检查任务完成情况**

   读取 Spec 任务文件并统计：
   - `- [x]`（已完成）vs `- [ ]`（未完成）

   **若有未完成任务：**
   - 显示警告：“N 个任务仍未完成”
   - 展示未完成任务
   - 用 **AskUserQuestion 工具** 确认：
     > “有 N 个未完成任务。仍然归档吗？”
     > - 是，带未完成任务归档
     > - 不，让我先完成

3. **检查验证清单**

   需求驱动型：读取 `tasks.md` 验证清单。
   设计驱动/缺陷修复型：读取 README.md 验证章节。

   若有未勾选的验证项，警告用户。

4. **更新状态（默认不移动目录）**

   默认只执行状态更新，Spec 保留在原路径 `specs/NNN-<name>/`：

   ```bash
   lean-spec update <spec> --status complete
   ```

   同时在 README.md frontmatter 补充完成日期（如 CLI 未自动写入）：
   ```yaml
   status: complete
   completed: '<YYYY-MM-DD>'
   ```

   **物理移动到 `specs/archived/` 是可选项**，仅在以下情况才执行 `lean-spec archive <spec>`：
   - 用户明确说“移到 archived”或“归档到文件夹”
   - `specs/` 下 in-progress 以外的 Spec 数量已达高冷数据阈值，用户要求清理
   - 项目有明确的归档约定（如 AGENTS.md 写明）

   > 默认不移动的原因：保持 `specs/NNN-<name>/` 路径稳定，避免破坏以下引用：
   > - 其他 Spec 的 `Dependencies` 字段
   > - `docs/` 下的跨文档引用（api-contracts / db-schema 等）
   > - `AGENTS.md` 索引
   > - Git 历史 / PR / CodeReview 中的路径

5. **显示摘要**

   ```
   ## Spec 已归档（状态已更新）

   **Spec：** NNN-<name>
   **类型：** <spec-type>
   **任务：** N/M 已完成
   **状态：** complete（completed: <date>）
   **位置：** specs/NNN-<name>/（未移动，保持引用稳定）

   ### 构建内容
   [功能/修复的简要总结]

   ### 关键决策
   [Spec 中的架构或设计决策]
   ```

   若执行了物理移动，将位置行改为 `specs/archived/NNN-<name>/（已移动）` 并提示用户检查跨文档引用。

**护栏**
- 始终提示用户选择 Spec，不自动猜测
- 未完成任务时警告但不阻止归档
- 未勾选验证项时发出警告
- **默认不执行 `lean-spec archive`（物理移动），只在用户显式要求时执行**
- 显示清晰的完成摘要
- Spec 作为永久文档，记录构建了什么以及为什么
