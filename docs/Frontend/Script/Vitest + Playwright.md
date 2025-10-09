```bash
pnpm add -D jsdom
pnpm add -D vitest
pnpm add -D vitest-browser-react
pnpm add -D @vitest/browser
pnpm add -D @vitest/browser-playwright
```

vite.config.ts：
```ts
/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import viteReact from '@vitejs/plugin-react'
import { playwright } from '@vitest/browser-playwright'
import { tanstackRouter } from '@tanstack/router-plugin/vite'
import { resolve } from 'node:path'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        tanstackRouter({
            target: 'react',
            autoCodeSplitting: true
        }),
        viteReact(),
    ],
    test: {
        // 浏览器测试配置
        browser: {
            enabled: true,
            provider: playwright(),
            instances: [
                { browser: 'chromium' },
            ],
            headless: false, // 设置为 false 以显示浏览器窗口
            ui: true, // 启用 UI 模式，测试完成后不自动关闭浏览器
        },
        // 常规测试配置
        environment: 'jsdom',
    },
    resolve: {
        alias: {
            '@': resolve(__dirname, './src'),
        },
    },
})

```

package.json:
- test：运行常规测试和浏览器测试（仅打开浏览器测试，测试完成自动关闭）
- test:ui： 运行测试并保持浏览器打开
```json
{
  "scripts": {
    "test": "vitest run",
    "test:ui": "vitest --browser --browser.ui",
  },
}
```

src/HW.tsx
```tsx
import { useState } from 'react'

export default function HelloWorld({ name }: { name: string }) {
	const [count, setCount] = useState(1)
	return (
		<div>
			<h1>
				Hello {name} x{count}!
			</h1>
			<button onClick={() => setCount((c) => c + 1)}>Increment</button>
		</div>
	)
}
```

tests/HW.spec.tsx:
```tsx
import { expect, test } from 'vitest'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import HelloWorld from '@/components/HelloWorld'

test('renders name', async () => {
    render(<HelloWorld name="Vitest" />)

    // 使用 Vitest 的原生断言
    expect(screen.getByText('Hello Vitest x1!')).toBeDefined()
    
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Increment' }))

    expect(screen.getByText('Hello Vitest x2!')).toBeDefined()
})

```

test-browser/HW.spec.tsx:
```tsx
import { expect, test, afterEach } from 'vitest'
import { render, screen, cleanup } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import HelloWorld from '@/components/HelloWorld'

// 在每个测试后清理 DOM
afterEach(() => {
    cleanup()
})

test('renders name in browser', async () => {
    // 在浏览器环境中渲染组件
    render(<HelloWorld name="Playwright" />)

    // 验证初始渲染
    expect(screen.getByText('Hello Playwright x1!')).toBeDefined()
    
    // 模拟用户交互
    const user = userEvent.setup()
    await user.click(screen.getByRole('button', { name: 'Increment' }))

    // 验证交互后的状态
    expect(screen.getByText('Hello Playwright x2!')).toBeDefined()
})

test('multiple increments work correctly', async () => {
    render(<HelloWorld name="Browser" />)
    
    const user = userEvent.setup()
    
    // 点击按钮多次
    await user.click(screen.getByRole('button', { name: 'Increment' }))
    await user.click(screen.getByRole('button', { name: 'Increment' }))
    await user.click(screen.getByRole('button', { name: 'Increment' }))
    
    expect(screen.getByText('Hello Browser x4!')).toBeDefined()
})
```

官方在线演示demo：
https://stackblitz.com/edit/vitest-tests-browser-examples-d8kteiex?file=vitest.config.ts&initialPath=__vitest__/