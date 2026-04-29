---
status: in-progress
created: '2026-04-19'
priority: high
phase: requirements
---

# User Auth - 用户认证模块

> **Status**: in-progress · **Priority**: high · **Created**: 2026-04-19

## Overview

用户认证是AI-First Scaffold平台的基础模块，提供手机号+密码的注册/登录能力，通过 JWT Token 实现无状态认证。
Token 中携带 `role` 字段区分管理员和普通用户，后端路由通过依赖注入校验权限。
一期使用手机号+密码方式，不实现微信登录和短信验证码。

## Requirements

### REQ-1: 用户注册

**User Story**: As a 用户, I want 通过手机号和密码注册账号, so that 我可以登录AI-First Scaffold平台进行教学或学习。

**Acceptance Criteria**:
1. GIVEN 用户未注册 WHEN 提交有效的手机号、姓名、密码和角色（admin/user） THEN system SHALL 创建用户账号并返回用户信息
2. GIVEN 手机号已被注册 WHEN 再次使用该手机号注册 THEN system SHALL 返回 409 Conflict 错误
3. GIVEN 手机号格式无效 WHEN 提交注册请求 THEN system SHALL 返回 422 Unprocessable Entity 错误

**Priority**: P0
**Dependencies**: 无

### REQ-2: 用户登录

**User Story**: As a 用户, I want 通过手机号和密码登录, so that 我可以获取 JWT Token 访问平台功能。

**Acceptance Criteria**:
1. GIVEN 用户已注册 WHEN 提交正确的手机号和密码 THEN system SHALL 返回有效的 JWT Token（含 user_id、role、过期时间）
2. GIVEN 密码错误 WHEN 提交登录请求 THEN system SHALL 返回 401 Unauthorized 错误
3. GIVEN 手机号不存在 WHEN 提交登录请求 THEN system SHALL 返回 401 Unauthorized 错误

**Priority**: P0
**Dependencies**: REQ-1

### REQ-3: 获取当前用户信息

**User Story**: As a 已登录用户, I want 查看自己的个人信息, so that 我可以确认账号状态。

**Acceptance Criteria**:
1. GIVEN 用户已认证 WHEN 携带有效 JWT Token 请求 THEN system SHALL 返回用户信息（id、phone、name、role）
2. GIVEN 请求未携带 Token WHEN 访问该接口 THEN system SHALL 返回 401 Unauthorized 错误

**Priority**: P0
**Dependencies**: REQ-2

### REQ-4: 修改密码

**User Story**: As a 已登录用户, I want 修改我的密码, so that 我可以保障账号安全。

**Acceptance Criteria**:
1. GIVEN 用户已认证 WHEN 提供正确的当前密码和新密码 THEN system SHALL 更新密码哈希并返回成功
2. GIVEN 当前密码错误 WHEN 提交修改密码请求 THEN system SHALL 返回 400 Bad Request 错误

**Priority**: P1
**Dependencies**: REQ-2

## Non-Functional Requirements

- WHEN 并发登录请求达到 100 QPS THEN system SHALL 在 500ms 内响应
- WHEN JWT Token 过期 THEN system SHALL 返回 401，Token 有效期为 7 天（可配置）
- 密码 SHALL 使用 BCrypt 哈希存储，禁止明文

## Constraints & Assumptions

- 一期使用手机号+密码认证，不实现微信登录
- JWT 使用 HS256 算法，密钥从环境变量读取
- 一期不实现 Token 刷新机制和黑名单

## Success Criteria

- [x] 所有 Acceptance Criteria 通过
- [x] 单元测试覆盖所有场景（`./harness/test-backend.sh -v` 13/13 通过）
- [x] `./harness/verify-api.sh auth` 端到端链路通过（7/7）
- [x] Swagger UI 可测试所有端点

## Glossary

| 术语 | 定义 |
|------|------|
| JWT | JSON Web Token，无状态认证令牌 |
| EARS | Easy Approach to Requirements Syntax，需求语法规范 |
| BCrypt | 密码哈希算法 |
