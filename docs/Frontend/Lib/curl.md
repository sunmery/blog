## 发送Form表单与参数
```curl
curl -X POST http://127.0.0.1/register -d'account=student2＆password=123456' -F 'avatar=@../example/images/avatar.svg'
```

对应的http测试文件
```http
### 注册
PUT {{url}}/register
Content-Type: multipart/form-data; boundary=boundary
Content-Type: application/json

--boundary
Content-Disposition: form-data; name="avatar"; filename="avatar.svg"

// 发送文件
< ../example/images/avatar.svg
--boundary
Content-Disposition: form-data; name="account";

student2

--boundary
Content-Disposition: form-data; name="password";

123456

--boundary--
```

## **-H**

`-H`参数添加 HTTP 请求的标头。
```shell
curl -H 'Content-Type': 'application/json; charset=utf-8' -H 'Secret-Message: xyzzy' https://google.com
```

## **-X**
`-X`参数指定 HTTP 请求的方法。

## **-d**
`-d`参数用于发送 POST 请求的数据体。

 ```bash
curl -d'login=emma＆password=123'-X POST https://google.com/login
或
curl -d 'login=emma' -d 'password=123' -X POST  https://google.com/login
```

## **-u**
`-u`参数用来设置服务器认证的用户名和密码

## **-G**
`-G`参数用来构造 URL 的查询字符串。

```bash
curl -G -d 'q=kitties' -d 'count=20' https://google.com/search
```

## **-b**
`-b`参数用来向服务器发送 Cookie。

```shell
curl -b 'foo=bar' https://google.com
```

## **-i**
`-i`参数打印出服务器回应的 HTTP 标头

## **-I**
`-I`参数向服务器发出 HEAD 请求，然会将服务器返回的 HTTP 标头打印出来

## **-L**
`-L`参数会让 HTTP 请求跟随服务器的重定向。curl 默认不跟随重定向。

## 参考

[阮一峰](https://www.ruanyifeng.com/blog/2019/09/curl-reference.html)