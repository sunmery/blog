## Install
```shell
go get github.com/spf13/viper
```

## Use

### 初始化
1. 文件类型, viper支持多种文件类型
```go
viper.SetConfigType("yaml")
```
2. 文件路径
```go
viper.SetConfigFile("./config.yaml")
```

3. 读取
```go
err := viper.ReadInConfig() // Find and read the config file
if err != nil { // Handle errors reading the config file
	panic(fmt.Errorf("fatal error config file: %w", err))
}
```
### 获取

1. GetString: 获取字段并转成字符串
```go
httpAddr := viper.GetString("server.http.addr")
```

### 设置
更新与添加是一样的方法, 区别在于, 
如果源文件没有的字段会自动添加, 
源文件有的字段会更新它的值
1. 添加新字段与新值
```go
viper.Set("new_field", "new_value")
```
2. 更新新值
```go
viper.Set("server.http.addr", "new_http_addr")
```

示例1: 
```go
func main() {
	// 初始化Viper
	viper.SetConfigFile("config.yaml") // 配置文件的文件名
	viper.SetConfigType("yaml")        // 配置文件的类型（YAML）

	// 读取配置文件
	if err := viper.ReadInConfig(); err != nil {
		fmt.Printf("Error reading config file: %v\n", err)
		return
	}

	// 读取字段值
	httpAddr := viper.GetString("server.http.addr")
	grpcAddr := viper.GetString("server.grpc.addr")

	fmt.Printf("HTTP Addr: %s\n", httpAddr)
	fmt.Printf("GRPC Addr: %s\n", grpcAddr)

	// 修改字段值
	viper.Set("server.http.addr", "new_http_addr")
	viper.Set("server.grpc.addr", "new_grpc_addr")

	// 添加新字段
	viper.Set("new_field", "new_value")

	// 写入配置文件（保存修改后的配置）
	if err := viper.WriteConfig(); err != nil {
		fmt.Printf("Error writing config file: %v\n", err)
		return
	}

	fmt.Println("Config file updated successfully.")
}
```

示例2: 解析配置文件
```go

func GetPath(file, dir string) string {
	if dir == "" {
		dir = "/config/"
	}
	_, filename, _, _ := runtime.Caller(0)
	root := path.Dir(path.Dir(filename)) //获取当前工作目录
	dirPath := path.Dir(root + dir)      // 获取配置文件的目录
	filePath := path.Join(dirPath, file) // 获取配置文
	return filePath
}

filePath := utils.GetPath("db.yaml", "")
fmt.Println("filePath:", filePath)

viper.SetConfigFile(filePath) // 给viper读取文件的路径
readErr := viper.ReadInConfig()
if readErr != nil {
	log.Fatalln("读取配置文件失败")
}
username := viper.GetString("mongodb.username") // 解析mongodb配置的用户名(如果对数据库设置了密码)
password := viper.GetString("mongodb.password") // 解析mongodb配置的密码(如果对数据库设置了密码)
uri := viper.GetString("mongodb.uri")           // 解析mongodb配置的链接
```