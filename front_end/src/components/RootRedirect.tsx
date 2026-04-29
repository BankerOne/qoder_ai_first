import { Navigate } from 'react-router-dom'
import { useAuthStore } from '@/store/authStore'

/**
 * 根路径分发：未登录 → /login，已登录 → /app
 */
export default function RootRedirect() {
  const user = useAuthStore((s) => s.user)
  if (!user) return <Navigate to="/login" replace />
  return <Navigate to="/app" replace />
}
