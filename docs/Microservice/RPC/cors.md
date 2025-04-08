1. https://github.com/grpc-ecosystem/grpc-gateway/blob/main/examples/internal/gateway/handlers.go
2. https://gist.github.com/nedimf/47f1a4f295f46601547fde55e48203aa
3. https://github.com/heppu/simple-cors/blob/master/cors.go

示例:

```go
package middleware

import (
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"strings"
)

// GrpcCORS grpc-gateway cors
func GrpcCORS(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if origin := r.Header.Get("Origin"); origin != "" {
			w.Header().Set("Access-Control-Allow-Origin", origin)
			if r.Method == "OPTIONS" && r.Header.Get("Access-Control-Request-Method") != "" {
				preflightHandler(w, r)
				return
			}
		}
		h.ServeHTTP(w, r)
	})
}

// preflightHandler adds the necessary headers in order to serve
// CORS from any origin using the methods "GET", "HEAD", "POST", "PUT", "DELETE"
// We insist, don't do this without consideration in production systems.
func preflightHandler(w http.ResponseWriter, r *http.Request) {
	headers := []string{"Content-Type", "Accept", "Authorization"}
	w.Header().Set("Access-Control-Allow-Headers", strings.Join(headers, ","))
	methods := []string{"GET", "HEAD", "POST", "PUT", "DELETE"}
	w.Header().Set("Access-Control-Allow-Methods", strings.Join(methods, ","))
	log.Printf("preflight request for %s", r.URL.Path)
}
```

```go
mux.Handle("/", middleware.GrpcCORS(grpcMux))
```

完整:

```go
func runGatewayServer(cfg *config.Config, store db.Store) {
	// rpc服务
	server, err := gapi.NewServer(cfg, store)
	if err != nil {
		panic(fmt.Sprintf("Unable to create server: %v", err))
	}

	// 进程内翻译, 仅支持 一元rpc, 即单个请求与单个响应
	jsonOption := gwruntime.WithMarshalerOption(gwruntime.MIMEWildcard, &gwruntime.JSONPb{
		MarshalOptions: protojson.MarshalOptions{
			UseProtoNames: true,
		},
		UnmarshalOptions: protojson.UnmarshalOptions{
			DiscardUnknown: true,
		},
	})
	grpcMux := gwruntime.NewServeMux(jsonOption)

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// 调用grpc-gateway生成的注册服务
	err = pb.RegisterCreateUserServiceHandlerServer(ctx, grpcMux, server)
	if err != nil {
		panic(fmt.Sprintf("Unable to register grpc server: %v", err))
	}

	//  创建多路复用器
	mux := http.NewServeMux()
	// 路由到grpc服务
	mux.Handle("/", middleware.GrpcCORS(grpcMux))
	// mux.Handle("/", grpcMux)

	fs := http.FileServer(http.Dir("./doc/swagger"))
	mux.Handle("/swagger/", http.StripPrefix("/swagger/", fs))

	// 监听端口
	listen, lisErr := net.Listen("tcp", cfg.HTTPServerAddress)
	if lisErr != nil {
		panic(fmt.Sprintf("Unable to create server port: %v", lisErr))
	}

	log.Printf("HTTP server listening on: %s", listen.Addr().String())
	err = http.Serve(listen, mux)
	if err != nil {
		panic(fmt.Sprintf("cannot start HTTP gateway server: %v", err))
	}
}

```
