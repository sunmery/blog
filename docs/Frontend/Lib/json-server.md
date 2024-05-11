# json-server

#Lib #JSON-Server
安装

-> 终端

```
pnpm install -g json-server
```

配置

-> db.json

```
{
  "posts": [
    { "id": 1, "title": "json-server", "author": "typicode" }
  ],
  "comments": [
    { "id": 1, "body": "some comment", "postId": 1 }
  ],
  "profile": { "name": "typicode" }
}
```

(可选)更改端口号

-> 终端

> 关键参数:  –port 端口号

```
json-server --watch db.json --port 8080
```

(可选) 更改响应时间

> 关键参数: -d 延迟时间,毫秒

```
json-server --watch db.json -d 2000
```

运行

-> 终端

```
json-server --watch db.json
```
