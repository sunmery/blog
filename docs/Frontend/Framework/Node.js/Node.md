# Node.js

#Node

## 特点

### 单线程

实际:
`JS线程` + `uv线程池` + `V8任务线程池` + `V8 Inspector线程`

优点:

- 不需要关注多线程的状态同步问题,不需要锁,不需要考虑`死锁`的问题
- 比较高效的利用系统资源

缺点:

- 阻塞会产生更多负面影响

+ 解决办法:
    - 多进程
        - 例:
          fs的readFile()模块,为了不阻塞当前的JavaScript主线程,让`libuv`的`uv线程池`去进行操作. 主线程就可以做其它操作

    - 多线程

> 例: if,else块

```js
function fibnacci (num) {
  if (num > 20) {
    return num
  }
  else {
    return num - 1
  }
}
```

### 异步I/O (input/output)

当Node.js执行I/O操作时,会在响应结束后恢复操作,而不是阻塞线程并占用额外内存等待

> 例1: setTimeout

```
setTimeout(()=>{
    console.log('B')
})
console.log('A')
```

> 例2: fs模块

> 例3: 加密解密等需要比较耗时的线程,也会到`libuv`的`uv线程池`进行操作,避免对主线程进行长时间的阻塞

### 跨平台 `libuv` (大部分功能,API)

Node.js跨平台 + JS无需编译环境 (+ Web跨平台 + 诊断工具跨平台)

- (开发成本低) 大部分场景不需要担心跨平台问题

> 例: net,Socket

```
const net = require('net')
const socket = new net.Socket('/temp/socket.sock')
```

## Node 使用 ES Module

- 使用 `Node` 的 `module.exports` 导出,使用 `ES Module` 的 `import` 导入

```
原生js出错
```

- 使用 `Node` 的 `require` 导入,使用 `ES Module` 的 `export` 导出

## Node中的this指向问题

在交互模式(cmd中打开node)中,this指向global

在文件模式中,this指向module.exports / exports

文件模式中 this可以代替 exports 对象

```js
let a = 10
exports.a = a

console.log(this === module.exports) // -> true
console.log(this === exports) // -> true
console.log(exports.a) // -> 10
console.log(this.a) // -> 10
```

#### module.exports 和 exports的关系

exports对象是module.exports对象的子对象, module包含exports

在文件模式中, module.exports === exports -> true

在交互模式中. exports 不存在, exports 只存在于文件模式中

## 在Node使用ES Module语法

### 第一种方案

更改文件名为 .mjs

### 第二种方案

##### 在script标签中使用 ==type== 属性,在 ==type== 属性中 使用值为 ==module== 的值

## fs模块

> 文件操作相关的模块

**fs.readFile() ** 读取文件内容

参数:

- 第一个参数: path,文件目录地址
- 第二个参数: 编码格式
- 第三个参数: 回调处理函数

**fs.write() **重写文件内容

参数:

- 第一个参数: path,文件目录地址
- 第二个参数: 编码格式
- 第三个参数: 回调处理函数

fs.open() 打开文件
> 参数
> -

1. 要打开的文件

> -

2. 字符标识

> - 打开方式
    >

+ r 读取文件,

> + r+ 读写文件
    >

+ w 写文件,没有新建

> + w+ 读写文件,没有新建
    >
+ a 写,追加文件
>   + a+ 读写, 追加文件
      > 回调函数

`fs.rm(path,[options:{maxRetries:\<integer>},recursive:\<boolean>,retryDelay:\<integer>],[err:\<function>])`

- path: 目录
- options:
    - `<integer>`:如果遇到EBUSY、EMFILE、ENFILE、ENOTEMPTY或EPERM错误，Node.js会尝试重试，每次重试的线性回退等待时间延长毫秒。此选项表示重试次数。如果递归选项不为true，则忽略此选项。默认值0
    - `<boolean>`如果为true，执行递归目录删除。在递归模式下，如果路径不存在，则不报告错误，并在失败时重试操作。默认值:fals.retrybelay
    - `<integer>`重试之间等待的时间(毫秒)。如果递归选项不为真，则忽略此选项。默认值:100
- Err 错误回调

## 实战 编写Http Server

1. 编写Http Server + Client ,收发GET,POST请求
2. 编写静态文件服务器
3. 编写React SSR服务
4. 适用 inspector 进行调试,诊断
5. 部署简介