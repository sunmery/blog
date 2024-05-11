## 默认值
`DefaultXXX()`设置默认值
`XXXArray("name")`对传入的多个name值存储为数组

## Number
前端可能会把数字类型的包装为字符串, 可以使用`encoding/json`的`json.Number`,
> 本质是遍历JSON的类型

## Date

`time.Time` 定义日期

前端: 将日期转为JSON格式
```js
new Date(<Date>).toJSON()
```

GO: 定义日期
```go
type Person struct {
	Name       string      `json:"username" binding:"required,min=3,max=20"`
	Nickname   string      `json:"nickname" binding:"nefield=Name"`
	Age        json.Number `json:"age"`
	CreateTime time.Time   `json:"create_time"` // 定义日期 
	Password   string      `json:"password" binding:"required,min=3"`
	RePassword string      `json:"re_password" binding:"required,eqfield=Password"`
	Tel        string      `json:"tel"`
}
```

## 动态参数
`Param()`

## POST

前端代码
```js
var myHeaders = new Headers();
myHeaders.append("User-Agent", "Apifox/1.0.0 (https://www.apifox.cn)");
myHeaders.append("Accept", "*/*");
myHeaders.append("Host", "localhost:4000");
myHeaders.append("Connection", "keep-alive");
myHeaders.append("Content-Type", "multipart/form-data; boundary=--------------------------688992984241366950538284");
var formdata = new FormData();
formdata.append("file", fileInput.files[0], "d:\Rococo\Pictures\Camera Roll\1fe8a94571046a4b8a78cb52520d92b2.jpg");
var requestOptions = {
    method: 'POST',
    headers: myHeaders,
    body: formdata,
    redirect: 'follow'
};

fetch("http://localhost:4000/pet/upload", requestOptions)
    .then(response => response.text())
    .then(result => console.log(result))
    .catch(error => console.log('error', error));
```

### multipart/form-data
接收File: `content.FormFile("key")` 
接受全部参数(key, file): `context.MultipartForm()`
示例:
```go
petGroup.POST("/upload", func(context *gin.Context) {
	file1, err := context.FormFile("file")
	if err != nil {
		panic(err)
	}
	context.JSON(http.StatusOK, gin.H{
		"file": file1,
	})
})
```