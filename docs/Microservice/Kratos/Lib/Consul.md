## 注册

1. 定义Consul配置
   `configs/register.yaml`

```yml
consul:
  address: 192.168.0.158
  schema: http
  health_check: false

```

2. conf层添加consul配置之后重新生成conf配置:`make config`
   `conf/conf.proto`

```proto
message Server {
  message HTTP {
    string network = 1;
    string addr = 2;
    google.protobuf.Duration timeout = 3;
  }
  message GRPC {
    string network = 1;
    string addr = 2;
    google.protobuf.Duration timeout = 3;
  }
  
  message Consul {
    string addr = 1;
    string schema = 2;
    bool healthChech = 3;
  }

  HTTP http = 1;
  GRPC grpc = 2;
  Consul consul = 3;
}
```

3. server层定义:
   `server/register.go`

```go
package server

import (
	"github.com/go-kratos/kratos/contrib/registry/consul/v2"
	"github.com/go-kratos/kratos/v2/registry"
	consulAPI "github.com/hashicorp/consul/api"
	"kratos-casbin/app/admin/internal/conf"
)

func NewRegistrar(conf *conf.Registry) registry.Registrar {
	c := consulAPI.DefaultConfig()
	c.Address = conf.Consul.Address
	c.Scheme = conf.Consul.Scheme
	cli, err := consulAPI.NewClient(c)
	if err != nil {
		panic(err)
	}
	r := consul.New(cli, consul.WithHealthCheck(conf.Consul.HealthCheck))
	return r
}

```

4. 注入依赖之后重新生成wire: `make generate`
   `server/server.go`

```go
package server

import (
	"github.com/google/wire"
)

// ProviderSet is server providers.
var ProviderSet = wire.NewSet(NewHTTPServer, NewRegistrar)

```

5. 注入口添加配置, 添加Name为微服务名称, Version, id 为唯一的, 用于标识该服务
   `cmd/xxx/main.go`

```go
var (
	// Name is the name of the compiled software.
	Name = "tiktok-e_commence-products"
	// Version is the version of the compiled software.
	Version = "1.0.0"
	// flagconf is the config flag.
	flagconf = "configs"

	id = "tiktok-e_commence-products"
)

func newApp(
	logger log.Logger,
	gs *grpc.Server,
	hs *http.Server,
	reg registry.Registrar, // 从server层作为依赖注入
) *kratos.App {
	return kratos.New(
		kratos.ID(id),
		kratos.Name(Name),
		kratos.Version(Version),
		kratos.Metadata(map[string]string{}),
		kratos.Logger(logger),
		kratos.Server(
			gs,
			hs,
		),
		kratos.Registrar(reg), // 注册到Consul
	)
}

func main(){
    // 添加配置信息
	var rc conf.Registry
	if err := c.Scan(&rc); err != nil {
		panic(err)
	}
	
	// 注入到wire
	app, cleanup, err := wireApp(bc.Server,&rc, bc.Data, logger)
}
```

6. wire

```go
func wireApp(*conf.Server, *conf.Registry, *conf.Data, log.Logger) (*kratos.App, func(), error) {
	panic(wire.Build(server.ProviderSet, data.ProviderSet, biz.ProviderSet, service.ProviderSet, newApp))
}
```

## 发现

data.go

```go
// NewDiscovery 配置服务发现功能
func NewDiscovery(conf *conf.Registry) (registry.Discovery, error) {
	c := consulAPI.DefaultConfig()
	c.Address = conf.Consul.Address
	c.Scheme = conf.Consul.Scheme
	cli, err := consulAPI.NewClient(c)
	if err != nil {
		return nil, err
	}
	r := consul.New(cli, consul.WithHealthCheck(false))
	return r, nil
}
```

使用
data.go

```go
// NewProductServiceClient 购物车
func NewProductServiceClient(d registry.Discovery, logger log.Logger) (protuctsV1.ProductCatalogServiceClient, error) {
	conn, err := grpc.DialInsecure(
		context.Background(),
		// 服务名称, 前面加上 discovery:/// 前缀和微服务项目的Name名
		grpc.WithEndpoint("discovery:///tiktok-e_commence-products"),
		grpc.WithDiscovery(d),
		grpc.WithMiddleware(
			recovery.Recovery(),
			logging.Client(logger),
		),
	)
	if err != nil {
		return nil, err
	}
	return protuctsV1.NewProductCatalogServiceClient(conn), nil
}

```

wire:
data.go

```go
var ProviderSet = wire.NewSet(NewData, NewDB, NewCache, NewOrderRepo, NewDiscovery, NewCartServiceClient, NewProductServiceClient)

```

开始调用
order.go

```go
func (o *orderRepo) PlaceOrder(ctx context.Context, req *biz.PlaceOrderReq) (*biz.PlaceOrderResp, error) {
product, err := o.data.productClient.GetProduct(ctx, &productV1.GetProductReq{
		Id: req.UserId,
	})
	if err != nil {
		return nil, err
	}
	fmt.Printf("product: '%+v'", product)
}
```

## 参考

1. https://github.com/lisa-sum/kratos-consul
2. https://go-kratos.dev/docs/component/registry/
