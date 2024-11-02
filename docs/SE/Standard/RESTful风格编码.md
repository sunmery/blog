# REST API

#规范

参考
[微软](https://github.com/Microsoft/api-guidelines/blob/master/Guidelines.md)
[IBM](https://www.ibm.com/cn-zh/cloud/learn/rest-apis)
[相关](https://restfulapi.cn/)

> 提供了一种灵活,轻量级的应用程序集成方式
>
> 也被称为RESTful API

---

## REST 设计原则

### 统一接口

不同地方的请求对同一个资源的发出的请求都是相同的.既一个资源对应一个URI

### 服务器/客户端解耦

客户端与服务器应该独立运行,客户端只需要知道发送对应的

## 无状态

不需要任何服务器会话,不允许服务器应用程序存储与客户端请求相关的任何数据

### 可缓存性

提高性能

### 分层系统架构

通过多个中间件,客服端服务器不要直接通信

### 按需编码

通常是静态资源,某些情况可以包含Java小程序,应该按需运行

---

## REST API 工作原理

通过HTTP进行请求通信
应用:
使用GET请求检索记录

## CRUD

### C Create缩写

POST : 创建

### R Read的缩写

GET: 读取

## U Update缩写

PATCH : 更新部分内容
PUT : 更新全部内容

## D Delete缩写

DELETE: 删除

---

## 响应设计

1. 1xx 相关信息 API不需要

2. 2xx 操作成功

3. 3xx重定向

4. 4xx 客户端错误
   错误（或更具体地说是服务错误）定义为客户端将无效数据传递给服务，并且服务_正确_拒绝了该数据。示例包括凭据无效、参数不正确、版本 ID
   未知或类似内容。这些通常是"4xx"HTTP错误代码，是客户端传递不正确或无效数据的结果。 错误_不会影响_整体 API 可用性。

5. 5xx 服务端错误
   故障，或者更具体地说，服务故障被定义为服务未能正确返回以响应有效的客户端请求。这些通常是"5xx"HTTP错误代码。

错误_确实_会影响整体 API 可用性。

由于速率限制或配额失败而失败的调用不得计为错误。由于服务快速失败请求（通常是为了保护其自身）而失败的调用确实算作错误。

---

## URL结构

正确示范:
`https://api.contoso.com/v1.0/people/jdoe@contoso.com/inbox`

特别示范: url当作值
`https://api.contoso.com/v1.0/items?url=https://resources.contoso.com/shoes/fancy`

错误示范:
`https://api.contoso.com/EWS/OData/Users('jdoe@microsoft.com')/Folders('AAMkADdiYzI1MjUzLTk4MjQtNDQ1Yy05YjJkLWNlMzMzYmIzNTY0MwAuAAAAAACzMsPHYH6HQoSwfdpDx-2bAQCXhUk6PC1dS7AERFluCgBfAAABo58UAAA=')`

---

## 扩展

URI (Uniform Resource Identifier) 统一资源标识符
URL (Uniform Resource Locator) 统一资源定位符
URN (Uniform Resource Name) 统一资源名称

---

### 三者关系:

URL, URN 是URI的子集
URL 是一个具体的地址, 直接通过URL直接找到网络上的地址
URN 是一个地址的名称,可以搜索该名称找到对应的URL