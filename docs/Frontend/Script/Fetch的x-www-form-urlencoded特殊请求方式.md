# Fetch的x-www-form-urlencoded特殊请求方式

不同于常见的`JSON`的格式请求, `x-www-form-urlencoded`是表单发送请求方式,其方式介于GET与POST请求发送方式,与GET的发送请求类似,
是`key1=value1&key2=value2`的方式发送的请求体,但不是直接拼接在URL上,与POST的请求类似,是在`body`体里面发送的请求,结合两者的方式, 具体代码如下

```ts
const getFormJSON = async(url: string,{ username:string | number ,password: string | number })=>{
	const response = await fetch(url,{
		method:'POST',
		headers:{'Content-Type':'x-www-form-urlencoded;charset=UTF-8'},
		body:`username=${username}&password=${password}`
	})
	
	// 对获取到的结果进行操作
	await response.json().then(({data})=>{
		console.log(data)
	})
}
```