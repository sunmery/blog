# Object

#Script

### Object.is(): 判断两个变量是否严格相等

> 解决 === 严格相等的问题
>
> === 即判断类型,也判断值

```js
console.log( Object.is(NaN,NaN) ) // ture
console.log( NaN === NaN ) //false
```

### Object.assign() : 对象合并

> Objecr.assign(target,obj1,obj2,...)
>
> target 返回obj1,obj2,...合成的对象

```js
const newObj = Object.assign({},{ a: 1 }, { b: 2}) // { a: 1,b: 2 }
```

## 对象字面量

> 在Object里可简写属性和方法

```js
// es5
const name = 1
const age = 19
const object = {
	name: name
	age: age,
	set:function(x, y){
		return x + y
	},
	get: function(){
		return { name,age }
	}
}

//es6
const name = 1
const age = 19
const object = {
	name,
	age,
	set(x, y){
		return x + y
	},
	get(){
		return { name,age }
	}
    
}
```

```js
const obj = {}
obj.[a+'bc'] = 'abc' 
obj.[say] = function() {
        console.log( 'hello world' )
}

// =>
const obj = {
	abc,
	say(){
		 console.log( 'hello world' )
	}
}
```

## Object.freeze()

> 冻结对象,不可以对该对象的属性增删改查


语法:
`Object.freeze(obj)`

参数:

1. obj 被冻结的对象

例子:

```js
const obj = {
	name:'lisa',
	age:19,
}

Object.freeze(obj)
obj.name='sum'
obj.gender='women'
delete obj.name

console.log(obj) // 原样输出,不受增删改查的影响
```

Object.create(obj)
创建一个没有原型的对象

```js
const obj = {id:3}
Object.create(obj)

console.log(obj) // {id:3}
```

Object.keys(obj)
获取对象的键

```js
Object.keys(obj)

const obj = {id:3}
Object.values(obj) //id
```

Object.entries(obj)
获取对象的值, 不会获取到对象的原型

```js
Object.keys(obj)

const obj = {id:3}
Object.values(obj) //id

```

Objcet.values(obj)
获取对象的值, 同样也会获取到对象的原型

```js
Object.values(obj)

const obj = {id:3}
Object.values(obj) //3

for(let key in Object.values(obj)){
	console.log(key) //会获取到对象原型上的key
}

// 解决方案1: 判断key是否为该对象的属性,而非对象的原型属性

// 解决方案2: 使用Object.entries()
```