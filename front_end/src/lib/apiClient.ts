/**
 * Axios 客户端单例。
 *
 * - baseURL 来自 VITE_API_BASE（默认 http://localhost:8000）
 * - 请求拦截：注入 Authorization: Bearer <token>（若 authStore 有 token）
 * - 响应拦截：统一错误透传 + 401 触发登出（由 authStore 订阅处理）
 *
 * 响应处理原则：
 * - 成功（2xx）→ 返回 response.data
 * - 失败 → reject AxiosError，由调用方或全局 toast 处理
 */
import axios, { AxiosError, type AxiosInstance, type InternalAxiosRequestConfig } from 'axios'
import { toast } from 'sonner'

const baseURL = import.meta.env.VITE_API_BASE || 'http://localhost:8000'

// token getter 由 authStore 在启动时注入，避免循环依赖
let tokenGetter: () => string | null = () => null
let onUnauthorized: () => void = () => {}

export function registerTokenGetter(getter: () => string | null) {
  tokenGetter = getter
}

export function registerUnauthorizedHandler(handler: () => void) {
  onUnauthorized = handler
}

export const apiClient: AxiosInstance = axios.create({
  baseURL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

apiClient.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const token = tokenGetter()
  if (token) {
    config.headers.set('Authorization', `Bearer ${token}`)
  }
  return config
})

/**
 * 全局错误 toast 规则（REQ-9）：
 * - 401 → toast + 清 token 跳 /login
 * - 403 → toast “无权执行该操作”
 * - 5xx / 502 / 504 → toast 分别文案
 * - 网络异常（无 response）→ toast “网络异常，请检查连接”
 * - 其他 4xx（400/404/409/422等）→ 不弹全局 toast，由调用方页面内处理，避免双重提示
 */
function fireGlobalToast(error: AxiosError) {
  // 登录接口的错误由 LoginPage 自己展示（避免 “登录已过期” 文案与密码错误混淆）
  const url = error.config?.url ?? ''
  if (url.includes('/auth/login')) return

  // 网络层问题（超时也计在内）
  if (!error.response) {
    toast.error('网络异常，请检查连接或稍后重试')
    return
  }
  const status = error.response.status
  switch (status) {
    case 401:
      toast.error('登录已过期，请重新登录')
      break
    case 403:
      toast.error('无权执行该操作')
      break
    case 500:
      toast.error('服务器异常，请稍后重试')
      break
    case 502:
      toast.error('上游服务暂不可用')
      break
    case 503:
      toast.error('服务暂不可用，请稍后重试')
      break
    case 504:
      toast.error('请求超时，请稍后重试')
      break
    // 其他状态码（400/404/409/422等）：由调用方自行用 extractErrorMessage 处理
    default:
      break
  }
}

apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    fireGlobalToast(error)
    if (error.response?.status === 401) {
      onUnauthorized()
    }
    return Promise.reject(error)
  },
)

/**
 * 便捷类型化包装：直接返回 data，去掉 AxiosResponse 壳。
 */
export async function get<T>(url: string, params?: Record<string, unknown>): Promise<T> {
  const res = await apiClient.get<T>(url, { params })
  return res.data
}

export async function post<T, B = unknown>(url: string, body?: B): Promise<T> {
  const res = await apiClient.post<T>(url, body)
  return res.data
}

export async function put<T, B = unknown>(url: string, body?: B): Promise<T> {
  const res = await apiClient.put<T>(url, body)
  return res.data
}

export async function del<T>(url: string): Promise<T> {
  const res = await apiClient.delete<T>(url)
  return res.data
}

/**
 * 从 AxiosError 提取后端 detail 文案，供 UI 展示。
 */
export function extractErrorMessage(error: unknown, fallback = '请求失败'): string {
  if (axios.isAxiosError(error)) {
    const detail = error.response?.data?.detail
    if (typeof detail === 'string') return detail
    if (Array.isArray(detail) && detail.length > 0) {
      const first = detail[0]
      if (typeof first === 'string') return first
      if (first && typeof first === 'object' && 'msg' in first) return String(first.msg)
    }
    if (!error.response) return '网络异常，请重试'
    return `${fallback}（${error.response.status}）`
  }
  return fallback
}
