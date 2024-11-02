在 `server` 的`http.go`编写如下代码:
```go
var opts = []http.ServerOption{
		http.Middleware(
			recovery.Recovery(),
		),
		http.Filter(
			func(h nethttp.Handler) nethttp.Handler {
				return nethttp.HandlerFunc(func(writer nethttp.ResponseWriter, request *nethttp.Request) {
					fmt.Println("router filter in")
					h.ServeHTTP(writer, request)
					fmt.Println("router filter out")
				})
			}
		),
	}
```