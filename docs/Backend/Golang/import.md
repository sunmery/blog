1. 在项目的`go.mod`文件定义项目的名称,例如`server`
```go
module server
```
2. `main.go`主文件导入其他目录的包
语法: `import` + 其他包的名称 + 大写函数名
例子:
`mongodb/conn.go`
```go
package mongodb

func MongoServer() {}
```

`main.go`
```go
import "server/mongodb" // 导入mongodb包

func main() {
	mongodb.MongoServer() // 使用mongodb包下的函数
}
```

## 参考
[知乎](https://zhuanlan.zhihu.com/p/109828249)