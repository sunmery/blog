# fetch

#Scripts #教程

## 网络请求演变

AJAX -> AXIOS-> fetch

- AJAX-> XMLHttpRequest(XHR)

- axios -> 封装的 XMLHttpRequest,(XHR)
- fetch ->原生js

## 使用

**语法**

```
let request = fetch(url)
```

封装简单Fetch

```ts
interface IFetchError {  
  status: 'error'  
  message: string  
}  
  
const Fetch = <T> (uri: string = 'http://localhost:4000/api/newsList', options: RequestInit={}): Promise<T|IFetchError> => {  
  return new Promise(async (resolve, reject) => {  
    const response = await fetch(uri, options)  
    // 预防空对象,如果是未设置或者是空对象时候设置为默认值
    options.method = options.method ?? 'GET'  
    options.headers = options.headers ?? {}  
    ;(options.headers! as Record<string, string>)['Content-Type'] = (options.headers! as Record<string, string>)['Content-Type'] ?? 'application/json'  
  
    if (response.ok) {  
      resolve(response as unknown as T)  
    }  
    else {  
      return {
	       status: 'error',
		  message: string 
      }
    }  
  })  
}  
  
export default Fetch
```

取消Fetch请求

1. 新建取消发送网络请求的实例`AbortController`
2. 配置需要取消的fetch的属性`signal`
3. 使用方法`AbortController()`的`abort`取消发送fetch请求

示例:

```js
const controller = new AbortController()
const { singnal } = controller

if(usr===''){
	window.alert('请输入账密!')
	
	controller.abort() // 取消fetch请求

	// 订阅取消fetch请求的事件
	singnal.addEventListen('abort',()=>{
		console.log('取消fetch请求')
	})

	// 检查是否取消fetch请求
	console.log(signal.aborted); // true
}

fetch(url,{
	singnal: singnal
})

```

使用示例:

```ts
interface INewsNetData {  
  id: string | number  
  name: string  
  uri: string  
}

const response = await Fetch<Array<INewsNetData>>()  
const allNewsNetData = await response.json().then((data: { body: INewsNetData }) => data.body)
```