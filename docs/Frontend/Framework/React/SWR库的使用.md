## 引言:

Q: 为什么需要此库?
A: React 给我们带来了`useEffect`这个函数钩子,为了处理`副作用`,然而在`nextjs`中,
有时候我们不需要通过`getStaticProps`函数来通过浏览器发送获取数据库的数据,而是直接在服务端中直接请求数据库的数据来达到减少调用与性能优化的效果,`SWR`(
客户端与服务端混合渲染),那么就必然要使用副作用函数`useEffect`, 而`useEffect`却缺少了一些状态,例如`错误时的处理`与`加载中的`状态,那么,`SWR`
这个库就是为了解决这种情况产生的

Q: 此库可以给我们带来什么?
A: 请求时发送的任何情况的明确的状态:

> TIP
> 三种状态同时存在一种状态,不存在有两种状态同时存在

1. 未加载完成(加载数据中)
2. 加载错误
3. 加载成功

## 下载

```
pnpm i swr
```

## 使用

1. 导入

    ```ts
    import useSWR from 'swr'
    ```

2. 封装

    封装网络请求API,在任何地方都可以重复使用的
    fetch示例

    ```tsx
    const fetcher = async(...args: [uri: string, fetchOptions: RequestInit]) => {
        return await fetch(...args).then((res)=>{
            return res.json()
        })
    }
    ```

    `axios`与`apollo`的封装访问[这里](https://swr.vercel.app/docs/data-fetching)

3. 使用

语法:

```ts
const { data, error } = useSWR(uri,fetcher)
```

`data`: 你获取到的数据
`error` : 错误时的状态

`uri`: 完整的URI+接口地址
`fetcher`: 封装的网络请求API,也可以在这里写

示例:

```tsx
interface IProfile {  
  _id?: string  
  name: string  
  age: number  
}

const fetcher = (...args: [uri: string, fetchOptions: RequestInit]) => {  
  return fetch(...args).then((res) => {  
    return res.json()  
  })  
}  

// 请求user接口的数据,该接口包含IProfile接口的数据
const {  data,  error } = useSWR('http://localhost:4000/user', fetcher)  

// 错误的状态
if (error) return <p>{ error }</p> 
// 数据未加载完成的状态
if (!data) return <p>Loading...</p>  

// 数据加载完成时的状态
return <>  
  <article key={ data._id }>  
    <strong>name: { data.name }</strong>  
    <p>age: { data.age }</p>  
  </article>  
</>
```

## 封装SWR

1. 封装

    ```tsx
    const fetcher = (...args: [uri: string, fetchOptions: RequestInit]) => {  
      return fetch(...args).then((res) => {  
        return res.json()  
      })  
    }  
      
    const useFetch = (uri: string, fetch = fetcher) => {  
      const {  
        data,  
        error,  
      } = useSWR(uri, fetch)  
      
      return {  
        data,  
        loading: !data&&!error,  
        error  
      }  
    }
    ```

2. 使用

    ```tsx
    const {  
      data,  
      loading,  
      error,  
    } = useFetch('http://localhost:4000/user', fetcher)  
      
    if (error) return <p>{ error }</p>  
    if (loading) return <p>Loading...</p>  
      
    return <>  
      <article key={ data._id }>  
        <strong>name: { data.name }</strong>  
        <p>age: { data.age }</p>  
      </article>  
    </>
    ```