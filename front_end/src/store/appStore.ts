/**
 * 轻量 UI 状态 store。
 *
 * Phase 1 重构：移除所有业务 mock（Course/Student/Homework），
 * 业务数据统一通过 services/* 从后端实时拉取。
 *
 * 本 store 仅保留跨页面的纯 UI 状态（如侧边栏折叠、全局 toast）。
 * 后续若需要更多 UI 状态，可继续扩展此文件。
 */
import { create } from 'zustand'

interface AppState {
  sidebarCollapsed: boolean
  toggleSidebar: () => void
  setSidebarCollapsed: (v: boolean) => void
}

export const useAppStore = create<AppState>((set) => ({
  sidebarCollapsed: false,
  toggleSidebar: () => set((s) => ({ sidebarCollapsed: !s.sidebarCollapsed })),
  setSidebarCollapsed: (v) => set({ sidebarCollapsed: v }),
}))
