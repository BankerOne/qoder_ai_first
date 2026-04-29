import { describe, it, expect } from 'vitest'
import { render } from '@testing-library/react'
import App from '@/App'

describe('App', () => {
  it('渲染不崩溃', () => {
    const { container } = render(<App />)
    expect(container).toBeTruthy()
  })
})
