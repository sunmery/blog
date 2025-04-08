## 示例

- 请求的处理时间函数:

```go
package middleware

import (
	"context"
	"fmt"
	"github.com/cloudwego/kitex/pkg/endpoint"
	"time"
)
// ApiRequestTimingMiddleware 请求的处理时间
func ApiRequestTimingMiddleware(next endpoint.Endpoint) endpoint.Endpoint {
	return func(ctx context.Context, req, res any) error {
		begin := time.Now()
		err := next(ctx, req, res)
		fmt.Printf("请求的处理时间: %v\n", time.Since(begin))
		return err
	}
}

```

## 使用

### server

main.go

```go
opts = append(opts, server.WithServiceAddr(addr),server.WithMiddleware(middleware.ApiRequestTimingMiddleware))
```

### Client

```go
cli, err3 := demoservice.NewClient(
		"demo",
		client.WithMiddleware(middleware.ApiRequestTimingMiddleware),
		client.WithResolver(r),
		client.WithMetaHandler(transmeta.ClientHTTP2Handler),
		client.WithTransportProtocol(transport.GRPC),
		client.WithClientBasicInfo(&rpcinfo.EndpointBasicInfo{
			ServiceName: "demo",
		}),
	)
```
