import { useState, type FormEvent } from 'react'
import { useNavigate, useLocation, Navigate } from 'react-router-dom'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { useAuthStore } from '@/store/authStore'
import { extractErrorMessage } from '@/lib/apiClient'
import { LayoutDashboard } from 'lucide-react'

/**
 * 登录页。已登录用户访问 /login 时直接跳 /app。
 */
export default function LoginPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const user = useAuthStore((s) => s.user)
  const login = useAuthStore((s) => s.login)

  const [phone, setPhone] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [errorMsg, setErrorMsg] = useState('')

  if (user) {
    return <Navigate to="/app" replace />
  }

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setErrorMsg('')
    if (!/^1\d{10}$/.test(phone)) {
      setErrorMsg('请输入 11 位手机号')
      return
    }
    if (password.length < 6) {
      setErrorMsg('密码至少 6 位')
      return
    }
    setLoading(true)
    try {
      await login(phone, password)
      const fromState = (location.state as { from?: string } | null)?.from
      navigate(fromState ?? '/app', { replace: true })
    } catch (err) {
      setErrorMsg(extractErrorMessage(err, '登录失败'))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-slate-50 to-slate-200 p-4">
      <Card className="w-full max-w-md shadow-lg">
        <CardHeader className="text-center">
          <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-primary/10">
            <LayoutDashboard className="h-6 w-6 text-primary" />
          </div>
          <CardTitle>AI-First Scaffold</CardTitle>
          <CardDescription>登录以进入控制台</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="mb-1 block text-sm font-medium">手机号</label>
              <input
                type="tel"
                autoComplete="username"
                value={phone}
                onChange={(e) => setPhone(e.target.value.trim())}
                placeholder="11 位手机号"
                className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                maxLength={11}
                required
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium">密码</label>
              <input
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="至少 6 位"
                className="w-full rounded-md border border-input bg-background px-3 py-2 text-sm outline-none focus:border-primary focus:ring-1 focus:ring-primary"
                required
              />
            </div>

            {errorMsg && (
              <div
                role="alert"
                className="rounded-md border border-destructive/40 bg-destructive/10 px-3 py-2 text-sm text-destructive"
              >
                {errorMsg}
              </div>
            )}

            <Button type="submit" className="w-full" disabled={loading}>
              {loading ? '登录中…' : '登录'}
            </Button>

            <p className="text-center text-xs text-muted-foreground">
              开发模式可通过 <code>/api/v1/auth/register</code> 创建账号
            </p>
          </form>
        </CardContent>
      </Card>
    </div>
  )
}
