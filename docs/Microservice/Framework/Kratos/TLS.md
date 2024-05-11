### HTTP
server的http和grpc文件:
```go
package server

import (
	"crypto/tls"
	v1 "etcd_example/api/helloworld/v1"
	"etcd_example/internal/conf"
	"etcd_example/internal/service"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/http"
)

// NewHTTPServer new an HTTP server.
func NewHTTPServer(c *conf.Server, greeter *service.GreeterService, logger log.Logger) *http.Server {
	// TLS文件
	cert, err := tls.LoadX509KeyPair("../cert/server.crt", "../cert/server.key")
	if err != nil {
		panic(err)
	}
	tlsConf := &tls.Config{Certificates: []tls.Certificate{cert}}
	var opts = []http.ServerOption{
		http.Middleware(
			recovery.Recovery(),
		),
		http.TLSConfig(tlsConf), // 添加TLS
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
	v1.RegisterGreeterHTTPServer(srv, greeter)
	return srv
}
```

