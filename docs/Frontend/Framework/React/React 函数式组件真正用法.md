## useState()

1. 对原有数组进行修改

> 使用ES2015的`数组扩展`语法对数据不进行修改,达到不直接修改数据的目的

```ts
const [arr,setArr] = useState<string[]>([])

useMemo(()=>{
	// 添加到队尾(push)
	setArr((arr)=>[...arr,'newItem'])
	// 添加到对头(unshift)
	setArr((arr)=>['newItem',...arr])
	// 添加数组元素
	setArr((arr)=>[...arr,...['newItem1','newItem2']])
},[arr])
```