# Node.js 总体学习(按需了解)(偏底层原理)

#Node

## 运行时结构

### 上层:

- acron
- node-inspect
- npm
- 用户代码

### 中上层:

- Node.js Core (JavaScript)
- N-API

### 中下层

Node.js Core(C++)

### 底层

- V8 JavaScript Runtimne, 诊断调试工具(inspection)
- libnv 各个操作系统API
    + eventloop 事件循环
    + syscall 系统调用
    +
    +

- nghttp2 HTTP协议2
- zlib 解压缩算法
- c-ares
- llhttp
    + 序列化
    + 反序列化
    + 得到数据返回给libuv
- OpenSSL

**例子: 使用 node-fetch 请求调用时会怎么做?**

1. 通`npm`安装`node-inspect`,到达`用户代码`,在用户代码里调用 `node-inspect`
2. 因为`用户代码` 都是`JavaScript`代码,所以会到达`V8`引擎去执行
3. `V8`在底层调用`Node.js Core(JavaScript)` 的`HTTP`模块, `HTTP`的模块再去调用`Node.js Core (C++)`的底层模块
4. `Node.js Core (C++)`调用 `llhttp`,`llhttp`对HTTP协议的==序列化==,==反序列化==,得到数据通过`libuv`
5. `libuv`创建`TCP`连接,再把数据发给`远端`

反过来:

1. `远端`传回数据以后,通过`libuv`进行事件循环得到消息
2. 把数据给 `llhttp` 进行解析
3. 在把数据给 `node.js Core(JavaScript)`
4. 在传回给`用户代码`,`用户代码`收到整个数据