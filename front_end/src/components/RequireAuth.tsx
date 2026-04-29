import { type ReactNode } from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { useAuthStore } from '@/store/authStore'
import type { UserRole } from '@/types/api'

interface RequireAuthProps {
  children: ReactNode
  roles?: UserRole[]
}

/**
 * 路由守卫：
 * - 未登录 → /login（携带 from 供登录后回跳）
 * - 已登录但角色不符 → 跳回 /app
 */
export default function RequireAuth({ children, roles }: RequireAuthProps) {
  const user = useAuthStore((s) => s.user)
  const token = useAuthStore((s) => s.token)
  const location = useLocation()

  if (!token || !user) {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />
  }

  if (roles && roles.length > 0 && !roles.includes(user.role)) {
    return <Navigate to="/app" replace />
  }

  return <>{children}</>
}
