需要重复使用服务器传递的数据的组件, 调用一个共同的数据获取组件

```tsx
import useSWR from 'swr'

function useUser () {
  const userInfo = useSWR('/api/user', fetcher)

  return {
    name: userInfo.name,
    age: userInfo.age
  }
}

function CompoentA () {
  const { data, loading } = useUser()

  return <>...</>
}

function CompoentB () {
  const { data, loading } = useUser()

  return <>...</>
}
```

需要根据某个或多个值验证是否请求： 给swr的key值传递多参数

1. 使用数组

    ```tsx
    function getTokenData () {
      const { data } = useSWR(['/api/user', token], fetcher)
    }
    ```

2. 使用对象

    ```tsx
    function getTokenData () {
      const { data } = useSWR({ uri: '/api/user', token: token }, fetcher)
    }
    ```

数据预填充

如果你想在 SWR 缓存中预填充已经存在的数据，你可以使用`fallbackData`选项，例如：

```tsx
const getData = () => {
  const date = new Date()
  const { data } = useSWR('api/user', fetcher, { fallbackData: date })
}
```

当 SWR 还没有获取此次数据的时候， 这个 hook 将返回`prefetchedData`作为 fallback