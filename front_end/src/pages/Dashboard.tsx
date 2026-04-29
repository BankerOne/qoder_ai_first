import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { LayoutDashboard, ShieldCheck, Rocket } from 'lucide-react'
import { useAuthStore } from '@/store/authStore'

export default function Dashboard() {
  const user = useAuthStore((s) => s.user)
  return (
    <div className="space-y-6 animate-fade-in">
      <div>
        <h1 className="text-3xl font-bold">欢迎，{user?.name}</h1>
        <p className="text-muted-foreground mt-1">
          这是 AI-First Scaffold 提供的最小示例页面。
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <LayoutDashboard className="w-5 h-5 text-primary" />
              脚手架能力
            </CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground space-y-1">
            <p>• 前端：React 18 + Vite + Tailwind + Zustand + React Router v7</p>
            <p>• 后端：FastAPI + SQLAlchemy + Alembic + JWT + bcrypt</p>
            <p>• SDD：AGENTS.md + LeanSpec + Qoder Skills + Hooks</p>
            <p>• 验证：harness/verify-api.sh 端到端 API 断言</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <ShieldCheck className="w-5 h-5 text-primary" />
              已内置的安全能力
            </CardTitle>
          </CardHeader>
          <CardContent className="text-sm text-muted-foreground space-y-1">
            <p>• 密码 bcrypt 哈希存储</p>
            <p>• JWT Bearer 鉴权 + /users/me</p>
            <p>• 角色守卫（admin / user）</p>
            <p>• 前端路由守卫 + 401 自动登出</p>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Rocket className="w-5 h-5 text-primary" />
            下一步
          </CardTitle>
        </CardHeader>
        <CardContent className="text-sm text-muted-foreground">
          <p>使用 <code>/leanspec-propose</code> 创建第一个功能 Spec，AI 会引导你走完需求 → 设计 → 任务 → 编码 → 验证的完整流程。</p>
        </CardContent>
      </Card>
    </div>
  )
}
