## 介绍

在组件加载完成之前显示自定义的加载状态,需要搭配`lazy()`进行动态导入

## lazy()用法:

```tsx
import { lazy } from 'react'
const Component = lazy(()=> import('component/path'))
```

举例:
等待CompB组件加载完成之前显示`Loading...`

```tsx
// components/CompB.tsx
import { useCallback, useState, Suspense, useEffect } from 'react'

//import type { IPosts } from './types'
interface IPosts {
  userId: string,
  title: string,
  body: string
}

function usePosts () {
  const [data, setData] = useState([])
  const getData = useCallback(() =>
      fetch('https://jsonplaceholder.typicode.com/posts').then(async (data) => setData(await data.json()))
    , [data])

  return [data, getData]
}

export default function CompB () {
  const [data, setData] = usePosts()

  return <>
    <button onClick={ () => setData() }>getJSON</button>
      <ul>
        {
          (data as Array<{ userId: string, title: string, body: string, id: number }>).map((_) => {
            return (
              <li key={ _.userId + _.id }>
                <p>{ _.id }</p>
                <p>{ _.title }</p>
                <p>{ _.body }</p>
              </li>
            )
          })
        }
      </ul>
  </>
}
```

```tsx
// app.tsx
import { lazy } from 'react'
import CompA from './components/CompA'
// 动态加载组件
const CompB = lazy(() => import('./components/CompB'))

interface IPosts {
  userId: string,
  title: string,
  body: string
}

function App () {
  return <>
    <Suspense fallback={<h2>Loading...</h2>}>
	    <CompB />
    </Suspense>
  </>
}

export default App

```