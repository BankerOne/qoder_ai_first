import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
import './index.css'
import { hydrateAuth } from './store/authStore'

// 在应用首次渲染前向 apiClient 注入 token getter 与 401 处理器
hydrateAuth()

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
