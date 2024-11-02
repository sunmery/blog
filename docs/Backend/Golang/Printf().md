格式化标准输出
- %f 完整输出浮点数
```go
var pi float32 = 3.14
fmt.Printf("$f.2f",pi) // 3.140000
```
- %.`<number>`f 保留`<number>`位小数
```go
var pi float32 = 3.141
fmt.Printf("$.2f",pi) // 3.14 保留2位小数
fmt.Printf("$.3f",pi) // 3.141 保留3位小数
```
- %d 整数
- %b 整数的二进制值
```go
var num1 int8 = 33
fmt.Printf("num1:%b\n", num1) // num1:100001
```
- %o 整数的八进制值
- %x 整数的十六进制值
- %s 字符
- %t 输出变量类型
```go
boole := false   
fmt.Printf("num1:%t\n", boole) // num1:false
```
- %T 输出变量类型
```go
var str2 string = "33"
fmt.Printf("str2:%T\n", str2) // str2:string 
```
- %v 打印对象的`value`值
```go
type Cat struct {  
   color string  
}  
cat := Cat{ color: "red" }  

fmt.Printf("%v\n", cat) // cat
```
- %+v 打印对象的`key`与`value`值
```go
fmt.Printf("%+v\n", cat) // { color:"red" }
```
- %#v 打印结构(所在的包名+方法名)与`key`和`value`值
```go
fmt.Printf("%#v\n", cat) // main.Cat{ color: "red" }
```