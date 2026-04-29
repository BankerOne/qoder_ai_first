/**
 * 认证相关 API Service。
 *
 * - login:    POST /api/v1/auth/login    → TokenResponse（仅 token，需额外调 me 拿用户信息）
 * - register: POST /api/v1/auth/register  → User
 * - me:       GET  /api/v1/users/me       → User
 */
import { get, post } from '@/lib/apiClient'
import type { LoginRequest, RegisterRequest, TokenResponse, User } from '@/types/api'

export const authService = {
  login(body: LoginRequest): Promise<TokenResponse> {
    return post<TokenResponse, LoginRequest>('/api/v1/auth/login', body)
  },

  register(body: RegisterRequest): Promise<User> {
    return post<User, RegisterRequest>('/api/v1/auth/register', body)
  },

  me(): Promise<User> {
    return get<User>('/api/v1/users/me')
  },
}
