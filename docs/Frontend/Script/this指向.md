# this指向

#Script #教程

## call, 函数改变this方法

> 更改函数下的指向, 传入该方法时会立即执行

语法:
`fn.call(this,[n1,n2)`

参数: 1-n

1. this指向的位置
2. 实参, 对应函数的形参输入

例子:

```js
function fn(arg1,arg2){
	console.log(arg1, grg2) // 12, 213
	console.log(this) // body
}

fn.call(document.body,12,213)
```

## apply, 函数改变this方法

> 更改函数的this指向, 与call唯一不同点就是第2参数是数组(call是多个参数)

语法:
`fn.apply(this,[Array[n1,n2])`

参数1:thi指向的位置
参数2: 数组列表

例子:

```js
function fn(){
	console.log(arguments)
	console.log(this)
}

fn.apply(this,[1,2,3,4,5])
```

## bind, 函数改变this方法

> 与call/apply不同, bind在调用时才改变this

语法:
`fn.bind(this)`

参数:

1. this 指向新的函数指向

例子:

```js
function fn(...args){
	consple.log(arguments)
	console.log(...args)
}

const newFn = fn.bind(document.body) // 调用时:newFn 的this指向document, 原来的fn仍然是window
newFn(1,2,4)

# 单行写法, 同以上两行
// fn.bind(document.body)(1,2,4)
```

## 使用call/apply模拟bind函数方法

```js

// 当作对象
function obj(name,age){
	this.name = name
	this.age = age
}

# fn函数的this指向obj函数, 验证this是否指向obj
function fn(){
	console.log(this.name)
	console.log(this.age)
}

# 使用call/apply模拟bind函数方法
function bindFn(fn,obj){
	return fn.call(obj,...arguments)
	// return fn.apply(obj,...arguemnts)
}

# 达到bind函数方法的同等效果 调用时this指向第一个参数, 第二个参数是:绑定的对象
bindFn(fn,obj('小明',20))

```