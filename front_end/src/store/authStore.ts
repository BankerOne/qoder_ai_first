/**
 * 认证状态管理：当前登录用户 + JWT token。
 *
 * 持久化策略：zustand persist 写入 localStorage。
 * 启动时调用 `hydrateAuth()` 向 apiClient 注入 token getter 与 401 处理器。
 */
import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { authService } from '@/services/auth'
import { registerTokenGetter, registerUnauthorizedHandler } from '@/lib/apiClient'
import type { User } from '@/types/api'

interface AuthState {
  user: User | null
  token: string | null
  login: (phone: string, password: string) => Promise<User>
  logout: () => void
  setUser: (user: User | null) => void
  refreshMe: () => Promise<User | null>
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      async login(phone, password) {
        const tokenRes = await authService.login({ phone, password })
        set({ token: tokenRes.access_token, user: null })
        try {
          const user = await authService.me()
          set({ user })
          return user
        } catch (err) {
          set({ user: null, token: null })
          throw err
        }
      },
      logout() {
        set({ user: null, token: null })
      },
      setUser(user) {
        set({ user })
      },
      async refreshMe() {
        if (!get().token) return null
        try {
          const user = await authService.me()
          set({ user })
          return user
        } catch {
          set({ user: null, token: null })
          return null
        }
      },
    }),
    {
      name: 'ai-first-scaffold-auth',
      partialize: (state) => ({ user: state.user, token: state.token }),
    },
  ),
)

/**
 * 在应用启动时调用一次：
 * 1. 把 token getter 注入 apiClient（避免循环依赖）
 * 2. 把 401 处理器注入：自动登出并跳 /login
 */
export function hydrateAuth() {
  registerTokenGetter(() => useAuthStore.getState().token)
  registerUnauthorizedHandler(() => {
    useAuthStore.getState().logout()
    if (window.location.pathname !== '/login') {
      window.location.href = '/login'
    }
  })
}
