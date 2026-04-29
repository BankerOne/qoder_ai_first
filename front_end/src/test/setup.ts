import '@testing-library/jest-dom'

// jsdom 中缺少的 API polyfill
globalThis.ResizeObserver = class ResizeObserver {
  observe() {}
  unobserve() {}
  disconnect() {}
}
