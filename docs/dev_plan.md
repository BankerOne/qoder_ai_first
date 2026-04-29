# 开发计划

> 项目创建后请替换为具体的里程碑与任务。

## 里程碑

| 阶段 | 目标 | 预计时间 |
|---|---|---|
| M0 | 脚手架搭建完成，跑通登录 + 健康检查 | 已完成 |
| M1 | (待定) | - |
| M2 | (待定) | - |

## 当前 Spec

使用 `lean-spec list` 查看当前 Spec 状态。

脚手架自带的样例 Spec：
- [001-user-auth](../specs/001-user-auth/README.md) — 用户认证（Requirements-first 示例）

## 开发节奏建议

1. 新需求 → 在对话中触发 `/leanspec-propose` 创建 Spec
2. 审查 requirements.md / design.md / tasks.md
3. 触发 `/leanspec-apply` 逐任务实施
4. 每个任务完成后自验证（见 `harness/`）
5. 全部任务完成 → `/leanspec-archive` 归档
