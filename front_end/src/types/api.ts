/**
 * 与后端 Pydantic schema 严格对齐的类型定义。
 *
 * 来源权威：back_end/app/schemas/*.py
 * 字段变更必须同步修改双方。
 */

export type UserRole = 'admin' | 'user'

export interface User {
  id: string
  phone: string
  name: string
  role: UserRole
}

export interface UserFull extends User {
  created_at: string
}

export interface LoginRequest {
  phone: string
  password: string
}

export interface RegisterRequest {
  phone: string
  password: string
  name: string
  role: UserRole
}

export interface TokenResponse {
  access_token: string
  token_type: 'bearer'
}

export interface ApiErrorDetail {
  detail: string | Record<string, unknown>
}
