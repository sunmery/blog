https://github.com/spf13/viper
## Install
```shell
go get github.com/spf13/viper
```

## Use

### ENV文件
编写env文件的规范:
1. 全大写的下划线命名法, 例如`DB_SOURCE`
2. Key与Value使用`=`赋值, 中间没有任何空格
3. Value值内容无需引号
```env
DB_SOURCE=postgresql://postgres:postgres@localhost:5432/simple_bank?sslmode=disable
SEVER_ADDRESS=localhost:8080
```

go代码:
```go
// 将struct的字段与env配置文件的Key通过mapstructure这个tag对应起来
type Config struct {
	DBSource      string `mapstructure:"DB_SOURCE"`
	ServerAddress string `mapstructure:"SEVER_ADDRESS"`
}

func LoadConfig(path string) (cfg *Config, err error) {
    // 传入配置文件的文件名
	viper.SetConfigName("app") // name of config file (without extension)
	// 传入配置文件的后缀
	viper.SetConfigType("env") // REQUIRED if the config file does not have the extension in the name
	// 传入配置文件与运行的go文件的相对路径
	viper.AddConfigPath(path)  // optionally look for config in the working directory
	// 读取配置文件
	err = viper.ReadInConfig() // Find and read the config file
	if err != nil {            // Handle errors reading the config file
		panic(fmt.Errorf("fatal error config file: %w", err))
	}

	// 自动从环境变量替换配置文件的值
	viper.AutomaticEnv()

    // 将得到的配置文件进行解构
	err = viper.Unmarshal(&cfg)
	if err != nil {
		return
	}

	return
}

func main() {
	cfg, err := config.LoadConfig(".")
	if err != nil {
		panic(err)
	}
	conn, err := pgxpool.New(context.Background(), cfg.DBSource)
	if err != nil {
		panic(fmt.Sprintf("Unable to connect to database: %v", err))
	}

	store := db.NewStore(conn)
	server := api.NewServer(store)

	err = server.Start(cfg.ServerAddress)
}
```

环境变量的优先级是大于配置文件的. 测试环境变量是否可以覆盖env文件的值, 如果运行的结果是环境变量的值, 则viper正常工作
```bash
SEVER_ADDRESS=localhost:8081 go run main
```
### Yaml
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