# HTTP

#Node

## HTTP模块

> const http = require('http')

## 端口

> 一个正常的数据库包的传输过程是: 应用层 -> 传输层 -> 网络层 -> 数据链路层 -> 物理层

> 特殊的端口特殊的意义:

### 127.0.0.1 / localhost

> 回环地址(Loop Back Address)
> 主机发出去的包,直接被自己接收
> 应用层 -> 传输层 -> 网络层 -> 传输层 -> 应用层
> 在网络层的时候就被获取到,不会经过数据链路层与物理层

> 缺点:
> 在同一个网段下,不能通过本机IP地址访问

### 0.0.0.0

> 监听所有的IPV4上所有地址,根据端口找到不同的应用程序
> 在监听此端口时,在同一个网段下的主机中,可以通过本机IP地址访问

创建一个服务
> 语法:
>1. new http.Server(request.response=>{})
>2. createServe((request,response)=>{})

```
const server = new http.Server((req,res)=>{
	res.end('Hello WebServer')
})

or

const server = http.createServe((req,res)=>{
	res.end('Hello WebServer')
})
```

启动服务
> 语法:
> listen(post,hostname,backlog)
> post: 端口
> hostname: 主机名
> backlog: 启动成功回调,一般提示启动成功

```
server.listen(4000,'0.0.0.0',()=>{
	conse.log('create server succeed!')
})
```