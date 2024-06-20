## 各自优点
选择使用 `Kratos` 的 HTTP 服务还是使用 `Gin` 作为 HTTP 服务取决于项目需求和偏好。这两种方法都有各自的优势和适用场景。

使用 `Kratos` 官方的 HTTP 服务：

1. **一体化**: Kratos 提供了完整的微服务开发框架，它的 HTTP 服务与其他组件（如RPC服务、数据存储等）紧密集成，可以更轻松地构建整体功能。
2. **内置特性**: Kratos 的 HTTP 服务内置了一些特性，如链路追踪、健康检查、中间件等，可以更方便地管理和监控服务。
3. **标准化**: Kratos 是一个遵循标准化设计原则的框架，有一定的最佳实践指导，可以帮助编写更一致、可维护的代码。

使用 `Gin` 作为 HTTP 服务：

1. **灵活性**: 轻量级的框架，可以根据需求自由选择中间件和插件，以满足特定的业务需求。
2. **生态系统**: 拥有丰富的第三方插件和库，可以方便地扩展功能，例如验证、API文档生成等。
3. **开发速度**: Gin 通常被认为是一个开发速度较快的框架，适用于快速构建原型和小规模项目。

**如何选择?** 

考虑团队熟悉度、项目规模、性能要求、扩展性等。如果已经使用了 Kratos 的其他组件，使用它的官方HTTP服务可能会更加方便。

如果更倾向于手动控制和定制，或者需要使用其他Gin提供的特性，那么使用Gin是一个不错的选择。
## 用法

> 由于使用了 gin 作为路由处理,那么就不需要在`protobuf`定义`google.api.http`这个`option`了

1. 在不影响现有的架构情况下添加 HTTP Server时, 添加一个用户接口层`interfaces`目录(DDD 思想)
2. 通过`gin`写路由与处理请求和响应
3. 与`kratos`集成
4. 注入`gin`路由用例到`wire`中

### 规范分层, 编写服务
1. 在`internal`添加`interfaces`目录, 编写`gin`服务
2. 定义 `gin` 服务
3. 定义路由
4. 返回 `gin` 服务
routes.go
```go
package interfaces

func RegisterHTTPServer () *gin.Engine{
	r := gin.Default()
	r.Any("/", us.SayHi)

	return r
}
```

###  编写路由用例, 响应与处理

1. 定义一个路由用例的结构体,与`Service`层交互
2. 编写该路由的用例, 实现该路由用例的结构体
3. 编写路由

`interfaces/sayhi.go`
```go
package interfaces

type SayHiUseCase struct {
	sayHiService *service.SayHiService
	log *log.Helper
}

func NewSayHiUseCase(sh *service.SayHiService, logger log.Logger) *SayHiUseCase{
	return &SayHiUseCase{
		sayHiService: sh,
		log: logger.NewHelper(logger)
	}
}

func SayHi (c *gin.Context){
	c.JSON(200,gin.H{
		"msg":"OK",
	})
}
```

### 与 Kratos 集成
1. 在`service/http.go`中注册路由
2. 在函数`NewHTTPServer`中添加在`interfaces`用户接口层编写的路由用例参数
3. 调用`interfaces`用户接口层的注册方法`RegisterHTTPServer`注入到 `srv`中

```go
package server

import (
	"github.com/go-kratos/kratos/v2/middleware/logging"
	"tiktok/internal/conf"
	"tiktok/internal/interfaces"
	"tiktok/internal/service"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/http"
)

// NewHTTPServer new an HTTP server.
func NewHTTPServer(c *conf.Server, userRouter *interfaces.UserUseCase, user *service.UserService, logger log.Logger) *http.Server {
	// http server

	var opts = []http.ServerOption{
		http.Middleware(
			recovery.Recovery(),
			logging.Server(logger),
		),
	}
	if c.Http.Network != "" {
		opts = append(opts, http.Network(c.Http.Network))
	}
	if c.Http.Addr != "" {
		opts = append(opts, http.Address(c.Http.Addr))
	}
	if c.Http.Timeout != nil {
		opts = append(opts, http.Timeout(c.Http.Timeout.AsDuration()))
	}
	srv := http.NewServer(opts...)
	srv.HandlePrefix("/v1/user", interfaces.RegisterHTTPServer(userRouter))
	// user.RegisterUserHTTPServer(srv, user)
	return srv
}
```

### 编写ProviderSet
在`interfaces`用户接口层编写`ProviderSet`

`interfaces/interface.go`
```go
package interfaces

import "github.com/google/wire"

var ProviderSet = wire.NewSet(NewUserUseCase)

```

### 注入到 wire 中

`cmd/<project>/wire.go`
```go
//go:build wireinject
// +build wireinject

// The build tag makes sure the stub is not built in the final build.

package main

import (
	"tiktok/internal/biz"
	"tiktok/internal/conf"
	"tiktok/internal/data"
	"tiktok/internal/server"
	"tiktok/internal/service"

	"github.com/go-kratos/kratos/v2"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/google/wire"
)

// wireApp init kratos application.
func wireApp(*conf.Server, *conf.Database, log.Logger) (*kratos.App, func(), error) {
	panic(wire.Build(server.ProviderSet, data.ProviderSet, biz.ProviderSet, service.ProviderSet, interfaces.ProviderSet, newApp))
}

```
### 测试
1. 进入到`cmd/<project>`目录
2. 在该目录使用终端执行`wire`
3. 启动项目, 测试接口是否正常

https://blog.csdn.net/m0_47404181/article/details/118339724