# React-TS

函数组件

```ts
import {FC} from 'react'
const Comp:FC=()=>{

} 
```

**Props**
语法:
`props: 接口/类型`

```tsx
interface IProps {  
  data: number  
}  
  
const CompA = (props: IProps) => {  
  const { data } = props  
  
  return<>
    {data}  
  </>  
}
```

**动态Props**
语法:

```
<泛型 extents Props类型>(props: 泛型)
```

1. 箭头函数的类型为

```ts
<泛型 extents 类型>(props: 泛型)
```

```tsx
const CompB = <P extents {data:number}>(props: P) =>{
	return <>{props}</>
}

function App () {
  const [data] = useState(20)  
  
  return (  
    <>  
      <CompB data={ data } />  
    </>  
  )  
}
```

HTML常见事件类型:

```ts
ChangeEvent<HTMLElement>
FormEvent<HTMLElement>
```

HTML事件处理函数类型

```tsx
const changeHandler: ChangeEventHandler<HTMLELement> = (e)=>{
	e.currentTarget.value
}

<label htmlFor="">  
  <input type="text" name="" id="" onChange={ (e: ChangeEvent<HTMLInputElement>) => onChangeHandle(e) } />  
</label>
```

工具类

- Partial 可选

- Required 必选

- Pick
  语法

```ts
Pick<T,K extends keyof T>
```

从T的类型挑选部分属性作为K的类型

```ts
// 从IPerson取出age属性作为XiaoMing的类型
interface IPerson {
	name: string
	age: number
}

type XiaoMing = Pick<IPerson, 'age'>
```

组合类型 &

```ts
interface IPerson {  
  name: string  
  id: number  
  age: number  
}  
type IGender = 'women' | 'man' | 'unknown'  
type XiaoMing = { gender: IGender, adder: string }  

type XiaoHong = IPerson & XiaoMing  
  
const xiaohong: XiaoHong = {  
  id: 1,  
  age: 18,  
  name: '12',  
  gender: 'man',  
  adder: 'ad',  
}
```

Record
将一个类型为另一个类型的属性

语法

```ts
Record<属性,属性的值的类型>
```

```ts
interface IPerson {  
  name: string  
  id: number  
  age: number  
}  
  
type XiaoWang = 'adder' | 'gender' 
// xiaoWang的两个属性adder与gender的值为IPerson接口定义的类型
const xiaoWang: Record<XiaoWang, IPerson2> = {  
  gender:{  
    name:'as',  
    age:19,  
    id:1  
  },  
  adder:{  
    name: 'as',  
    age: 19,  
    id: 1  
  }  
}
```

Exclude
语法

```ts
Exclue<类型A,从类型排除的类型>
```

```ts
type Gender = 'women' | 'man' | 'unknown'  
type newGender = Exclude<Gender, 'unknown'>  
const gender1: newGender = 'women' // ok  
const gender2: newGender = 'man' // ok  
const gender3: newGender = 'unknown' // error
```

Omit
语法

```ts
Omit<类型A,从类型A去除的属性>
```

```ts
interface Person {
	age: number
	name: string
}
type Xm = Omit<Person,'age'>
const xm:Xm = {
	name:'ad'
}
```

ReturnType
返回函数返回值的类型
语法

```ts
Return<typeof 函数>
```

```ts
function foo(type): boolean {
  return type === 0
}

type FooType = ReturnType<typeof foo>

```
