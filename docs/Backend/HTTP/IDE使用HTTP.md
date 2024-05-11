## 使用

### multipart/form-data
```http
### 注册

PUT http://127.0.0.1:4000/register
Content-Type: multipart/form-data; boundary=boundary

// 发送一个name文件为avatar的avatar.jpg文件
--boundary
Content-Disposition: form-data; name="avatar"; filename="avatar.jpg"

// 文件所在位置(相对位置,根据http文件的位置而定)
< ../example/images/avatar.svg

// 临时文件(由IDE自动创建), Text为纯文本, 对应的Content-Type为text
Text 
--boundary Content-Disposition: form-data; name="third";

< ./input.txt --boundary--
```

### POST
```http
### 登录
POST http://127.0.0.1:4000/login
Accept: application/json

// 账号1
{ "account" : "student", "password":"123456" }

// 账号2
{ "account" : "teacher", "password":"123456" }

// 账号3
{ "account" : "admin", "password":"123456" }
```

### 重定向

禁用重定向
```http
// @no-redirect 
example.com/status/301
```
## 参考
[jetbrains](https://www.jetbrains.com/help/idea/exploring-http-syntax.html)