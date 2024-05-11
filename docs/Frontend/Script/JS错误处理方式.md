## 引言

为什么需要错误处理?
场景1: 你封装了一个方法, 该方法的某个参数需要对象类型,而调用者传递了字符串或者数字引发的错误,但浏览器并没有很好的提示错误的类型

场景2: 你想要对某种可以预判的错误进行正确的处理,而不是由浏览器抛出异常

假设你遇到了以上的情况之一,那么你可能就需要了解一下在`ES`中的`错误`以及`错误的处理`

## ES定义的错误类型:

1. Error
2. TypeError
3. ReferenceError:
4. EvalError
5. URIError
6. SyntaxError

### Error

> 所有错误类型的基类(父类)

### TypeError

> 类型异常

抛出该异常的常见情况:

1. 使用`未定义`的`变量`
2. 变量中保存意外的类型,例如`const date = new data()`

### RangeError

> 范围异常:
> 超出或低于ES定义的最大向量与最小向量的值

抛出该异常的常见情况:

1. `const arr = new Array[-30]` 超出阵列的儲存范围

### URIError

> URI(統一資源定位符)的类型异常
> URI的格式不正确则会抛出此异常

抛出该异常的常见情况:

1. 使用`encodeURI`或`decodeURI`方法时抛出的异常

### EvalError

抛出该异常的情况:

1. 没有正确使用 `eval()`, 即没有把该函数进行正常的调用,例如`new eval()`

### SyntaxError

> eval函数异常

抛出该异常的情况:

1. 没有正确的把字符串传入`eval()`函数中
2. 错误的使用`eval()`方法,例如`eval(6--1)`

## 异常处理

> 将错误进行合适的处理

个人觉得异常处理可分为两种情况:

1. 将可以预测的错误进行合适处理,将错误变成可以正确执行的代码
2. 将错误类型进行准确的的错误类型提示

异常处理的方式:

1. 使用`try catch`捕捉异常
2. 使用`throw [new <ErrorType>]` 抛出异常, `ErrorType`可以为任意类型, 也可以是上面提到的6种类型, 使用`throw`抛出的异常类型如下所示:
    1. `throw new Error('You threw an exception!')`
    2. `throw new TypeError('You threw an exception!')`
    3. `throw 'You threw an exception!'`
    4. `throw new RangeError('You threw an exception!')`
    5. `throw new EvalError('You threw an exception!')`
    6. `throw new URIError('You threw an exception!')`
    7. `throw new SyntaxError('You threw an exception!')`
    8. `throw { message: error }`}

何时使用`try catch`?

1. 如果是明确的错误类型,那么就不应使用`try catch`
2. 遇到未知而且极有可能会抛出异常的代码段使用

使用`try catch`语句:

语法:

```js
try {
	// 可能出现错误的代码段
}catch(error){
	// 对错误的处理
}
```

示例:

```ts
import { of } from 'rxjs'

interface FetchError {
 status: 'error'
 message: string
}

export default async function Fetch<T> (
 uri: string = 'http://localhost:4000/',
 FetchOptions: RequestInit = {},
): Promise<Promise<T> | PromiseLike<void> | FetchError> {
 of(new Promise(async (resolve, reject) => {
   try {
    const response = await fetch(uri, FetchOptions as RequestInit)
    FetchOptions.method = FetchOptions.method ?? 'GET'
    FetchOptions.headers = FetchOptions.headers ?? {}
    ;(FetchOptions.headers as Record<string, string>)['Content-Type'] = (FetchOptions.headers as Record<string, string>)['Content-Type'] ?? 'application/json'
    if (response.ok) {
     resolve(response.json())
    }
    else {
     reject({
      status: 'error',
      message: 'connection error.',
     })
    }
   }
   catch (e: unknown | any) {
    throw new Error(e.message)
   }
  }),
 )
  .subscribe({
   next (val) {
    console.group(val)
    return val
   },
   error (err) {
    console.debug(`%c ${ err.message }`, 'color:yellow')
   },
   complete () {
    console.log('net fetch end!')
   },
  })
}
```

自定义抛出异常示例:

1. 要求是字符串,你写了数字

   ```js
   if (typeof str === 'number'){
       throw new TypeError('What type of variable do you take me for?!')
   }
   ```

2. 访问未定义的变量

   ```js
   try{
       c = x()
   }catch(error){
       throw new TypeError('你访问了未定义的类型')
   }
   ```

3. 将错误传递的参数转成正确的参数

   ```js
   const fn = (id) => {
     try {
      if (id !== 'number') {
       throw new TypeError('请传入数字类型的id!')
      }
     } catch (err) {
      if (err instanceof TypeError) {
       Number(id)
      }
     }
     return id
    }
    fn('2')
   ```