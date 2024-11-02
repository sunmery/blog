#### 可选参数

用`?`关键字来表示该参数可选

可选参数必须放在后面

```ts
const fn = (x: string, y?: string): string
{
  if (y) {
    return x + y
  }
  return x //8
}
const fn1 = fn('8')
```

#### 剩余参数

`...`关键字定义一个剩余参数

剩余参数接收前面接受不完的参数(如果有)

```ts
const Fn1: (x: string, ...args: string[]) => string[] = function (x: string, ...args: string[]): string[] {
  console.log(x) // a
  args.unshift(x)
  console.table(...args) //['a', 'b', 'c', 'd', 'e']
  return args
}

const fn1 = Fn1('a', 'b', 'c', 'd', 'e')
console.log(fn1)
```

#### 函数重载

重载的必要条件:

1. 两个或以上重名函数,函数参数可能不相同(函数重载声明)

1. 函数声明
   缺点:函数重载声明过多
   解决方案:使用泛型可重构的函数重载

```ts
//函数重载声明
function add (x: string, y: string): string
function add (x: number, y: number): number

``

//函数声明
function add (x: string | number, y: string | number): string | number {
  if (typeof x === 'string' || typeof y === 'string') return `${ x } - ${ y }`
  else return x + y
}

const add1 = add(10, 20) //30
const add2 = add(20, '20') //error
const add3 = add('str', 'ing') //string
const add4 = add('30', '40') //
```

##### 使用泛型可实现少代码的函数重载

```ts
//重构以上代码

function add<T> (x: T, y: T): T {
  if (x<string> || y<string>) {
    return `${ x } - ${ y }`
  }
  else {
    return x + y
  }
}

const add1 = add<number>(10, 20) //30
const add2 = add<number | string>(20, '20') //error
const add3 = add<string>('str', 'ing') //string
const add4 = add<string>('30', '40')
```

### class

```ts
//基类/超类
class Person {

}

//派生类(通过extends继承的类就称为派生类,被继承的类就叫基类/超类,之间的关系就叫父子类)
class DerivedClass extends Person {

}

const person = new Person()
const derivedClass: Person = new DerivedClass()
```

## 泛型

应用场景: 在初始化时不确定要传入的类型,只有在传入时才确定的类型使用

### 单个泛型参数

```ts
function add<T> (x: T, y: number): Array<T> {
  const arr = string[] = []
  for (let i = 0; i < y; i++) {
    arr.unshift(x)
  }
  return arr
}

const str = add('a', 'b', 'c')
```

```ts
interface IAni {
  cont: number
}

function <T> (x: <T extends IAni>): T {}
```

## 类型

`type`定义一个类型

```ts
//定义
type Name = string
type NameResolver = () => string
type NameOrResolver = Name | NameResolver

//使用
const name: Name = 'lisa'

//n的类型可能是字符串,或者是一个函数的返回值为字符串 返回类型:字符串
function getName (n: NameOrResolver): Name {
  //类型断言 <string> 断定此时的类型为string  
  if (n<string>) {
    //返回该字符串
    return n
  }
  //执行该函数
  else {
    return n()
  }
}

const str = getName('str')
```

## 类型断言

使用类型断言来给变量明确的类型

使用 `<类型>`断定此时为一个`<>`里的类型

`<>` 尖括号形式来表示类型断言

```ts
function (x: string | number): number | undefined {
  if (x <number>) {
    return x
  }
  else if (isNaN(x <string>)) {
    return Number(x)
  }
  else {
    return 'not a number'
  }
}
```

as 关键字表示类型断言

```typescript
const arr = [1, 2, 3, 4]
arr.find(e => e > 2) //ts报错 此时ts提示arr的类型为number | undefined
const arr1 = arr as number //给arr添加类型断言 就不会报错
arr.find(e => e > 2) //3
```

## 别名

可以为`interface`接口,`class`类,`function`函数等起一个`别名`

```ts
type Name
:
string

function (n: Name) {
  return n
}
```

## 接口

定义一串来限制对象/函数/类的属性类型

```typescript
//定义一个接口明确限制对象的属性类型
interface Person {
  id: number,
  name: string,
  age: number | string,
  gender: string,
  isShow?: boolean
}

//定义一个接口来限制函数的参数类型    
interface IFn {
  //调用签名
  (str1: string, str2?: string): string
}

const obj: Person = {
  id: 1,
  name: 'lisa',
  age: '20',
  gender: 'woman',
}

const fn: IFn = (str1: string, str2?: string): string => {
  if (str2) {
    return str1 + str2
  }
  return str1
}
```

`[]` 关键字给动态对象类型添加接口

```typescript
例 [属性名称(任意)
:
属性类型
] :
类型

interface Person {
  [key: string]: string //限定属性类型为字符串 则对象的值必须也是字符串类型
}

const obj = {}
obj.name = 'lisa'
obj.age = 18 //报错 不是字符串
```

readonly 只读属性 限定接口类型的值不可修改,一旦赋值之后就不能修改

```typescript
interface Type {
  readonly name: string
}

const obj: Type = {
  name: 'lisa'
}
obj.name = 'sum' // err 无法分配到 "name" ，因为它是只读属性
```

## 其他

### 声明文件

- 自定义类型提示(Vanilla)

```ts
declare var xxx: (变量: 类型) => 返回类型
```

## 类

> 描述一类事物的抽象特征

### 类成员(属性)

#### 语法

> 修饰符 成员名 = 值

#### 写法

```
class 类名{
  public/private/proected name: type = value //不推荐
}
```

#### 语法

```ts
public
/proected/
private
成员名 : 类型
constructor(成员名
:
类型
)
{
  this.成员名 = 成员名
}
```

#### 写法

```ts
class ClassName {
  public name: type

  constructor (name: string) {
    this.name = name
  }
}
```

### 抽象类:

通过`adstract`关键字定义一个抽象类

1. 抽象类不能实例化

2. 抽象类的价值是被当作`基类`/`超类`来使用 主要给`派生类`定义类型和抽象的方法

3. 抽象类可以具体描述

4. 抽象类在抽象方法时不用`{}` 但需要空的返回值类型`void`

5. 抽象类不建议/不经常使用抽象属性

```ts
abstrace

class Person {
  abstract name: string = 'name' //不推荐
  abstrace

  eat (): void //空的返回值
  abstract sayHi (): void { //可以具体书写方法
    console.log("hi")
  }
}
```

### 类定义

```ts
class Person {}
```

### readonly 只读属性

```ts
class Person {
  //前缀修饰符
  readonly name: string = 'defaultName'
  //参数修饰符 使用了参数修饰符,该类中就有该只读成员变量,不用定义即可访问
  //只有类中的构造函数可以修改readonly只读属性 其他地方均不可以修改
  constructor (readonly name: string = 'defaultName') {
    this.name = name
    //可以成功修改,意义不大
    this.name = '我被修改了'
  }

}

const person: Person = new Person('lisa')
```

### public 公共的

在任何地方都可以使用 class类中默认是public修饰符

```ts
class Person {
  //定义变量 需明确赋值
  public name: string = 'lisa'

  //定义对象 
  public obj = {
    name: 'lisa summer'
    age: 19
  }

  //定义方法  
  public fullName () {

  }
}
```

### protected 受保护的

只能在本类或者是继承的派生类中使用

```ts
class Person {
  //只能在本类和派生类使用  
  protected name: string = 'lisa'
}

class Derived extends Person {
  construstor (name: string) {
    super(name)
  }
}

const person: Person = new Person()
const derived: Derived = new Derived()
console.log(deriver.name) // error
```

### private 私有的

只能在本类中使用, 派生类 其他类 和类外部都不能使用

bug: 编译是提示错误 但可以正常访问 加上 as any时也可以获取到

用 #变量代替private 在es2020中使用私有属性#时ts转成js时会将#私有属性编译成weakMap来编译成js

```ts
class Person {
  private name: string = 'summer'
  #firstName: string = 'lisa'
}

class Derived extends Person {
  construotr () {
    super()
  }
}

const person: Person = new Person()
const derived: Person = new Derived()

console.log(derive.name) //编译是提示错误 但浏览器正常输出值 summer
console.log((derive as any).name) // 编译正常且不报错
console.log(derived.firstName) // 编译报错 输出undefined
```

### static 静态成员

可直接使用 `类名` `.` `静态成员`来访问静态成员

类的`constructor`构造器不可以使用`static`静态前缀

静态成员不可以通过`constructor`构造器的`this`来访问

```ts
class Person {
  static constructor () {} //error
  static name: string = 'lisa'

  public constructor () {
    this.name = name //error
  }

  static add (num1: number, num2: number): number {
    return num1 + num2
  }
}

console.log(Person.name) //lisa
console.log(Person.add(1, 2)) // 3
```