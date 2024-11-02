在 `server` 的`http.go`编写如下代码:

```go
import ("github.com/gorilla/handlers")

var opts = []http.ServerOption{
		/// 中间件
		http.Middleware(
			recovery.Recovery(),
		),
		// CORS
		http.Filter(
			handlers.CORS(
				handlers.AllowedMethods([]string{"GET", "POST", "PUT", "PATCH", "DELETE"}),
				handlers.AllowedHeaders([]string{"X-Requested-with", "Content-Type"}),
				handlers.AllowedOrigins([]string{"localhost:3000", "localhost:80", "localhost:443"}),
			),
		),
	}
```