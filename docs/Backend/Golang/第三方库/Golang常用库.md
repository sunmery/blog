## Gin
```shell
go get -u github.com/gin-gonic/gin
```

## Gin-CORS

```shell
go get github.com/gin-contrib/cors
```

### Slog 日志库
```shell
go get github.com/gookit/slog
```

GORM
```shell
go get -u gorm.io/gorm
go get -u gorm.io/driver/postgres
```

测试,mock,断言库
[Github](https://github.com/stretchr/testify)
```shell
go get -u github.com/stretchr/testify
```
## ORM-Postgres
[Github](https://github.com/go-pg/pg)
```shell
go get github.com/uptrace/bun@latest
```

## SQL迁移
[github](https://github.com/golang-migrate/migrate)
1. github.com/golang-migrate/migrate/v4 迁移库
2. github.com/golang-migrate/migrate/v4/database/postgres PG 数据库
3. github.com/golang-migrate/migrate/v4/source/file sql 文件读取
```
go get github.com/golang-migrate/migrate/v4
go get github.com/golang-migrate/migrate/v4/database/postgres
go get github.com/golang-migrate/migrate/v4/source/file
```

GO-PG-migrations Go 操作 sql
[github](https://github.com/go-pg/migrations)
```shell
go get github.com/go-pg/migrations/v8
```

## godotenv 环境变量
```shell
go get github.com/joho/godotenv
```

GORM:
本体
```shell
go get -u gorm.io/gorm
```
驱动:
mysql: 
```shell
go get -u gorm.io/driver/mysql
```
postgres:
```shell
go get -u gorm.io/driver/postgres
```

## AIR
开发热重启
### Go1.16之后
```shell
go install github.com/cosmtrek/air@latest
```

### Go1.16之前
```shell
go get -u github.com/darjun/go-daily-lib/air
```

## gin-swagger
https://github.com/swaggo/gin-swagger
与 Gin 结合的swagger
1. 
```shell
go install github.com/swaggo/swag/cmd/swag@latest
go get -u github.com/swaggo/gin-swagger
go get -u github.com/swaggo/files
```
2.
```shell
swag init
```

3.
```go
package main

import (
   "github.com/gin-gonic/gin"
   docs "github.com/go-project-name/docs"
   swaggerfiles "github.com/swaggo/files"
   ginSwagger "github.com/swaggo/gin-swagger"
   "net/http"
)
// @BasePath /api/v1

// PingExample godoc
// @Summary ping example
// @Schemes
// @Description do ping
// @Tags example
// @Accept json
// @Produce json
// @Success 200 {string} Helloworld
// @Router /example/helloworld [get]
func Helloworld(g *gin.Context)  {
   g.JSON(http.StatusOK,"helloworld")
}

func main()  {
   r := gin.Default()
   docs.SwaggerInfo.BasePath = "/api/v1"
   v1 := r.Group("/api/v1")
   {
      eg := v1.Group("/example")
      {
         eg.GET("/helloworld",Helloworld)
      }
   }
   r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))
   r.Run(":8080")
}
```


## swagger
```shell
go get -u github.com/go-swagger/go-swagger/cmd/swagger
```

### Mac
1. 利用`go env GOPATH`查看并复制go安装路径
```shell
go env GOPATH
```

2. 添加`air`别名与`air`的安装路径
```shell
vi ~/.zshrc
alias air='/Users/art/go/bin/air'
```

3. 重新读取`zsh`配置
```shell
source ~/.zshrc
```

## MongoDB
```shell
go get -u go.mongodb.org/mongo-driver/bson
```

## viper
读取配置文件

```shell
go get github.com/spf13/viper
```


## JWT

```shell
go get -u github.com/golang-jwt/jwt/v5
```