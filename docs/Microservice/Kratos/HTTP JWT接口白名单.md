打开生成的`_http.pb.go`文件, 下拉到最后, 找到`xxx_proto_depIdxs`的变量
它有类似的内容:

```go
var file_shop_v1_shop_proto_depIdxs = []int32{
	1, // 0: shop.v1.ShopService.Register:input_type -> shop.v1.RegisterReq
	2, // 1: shop.v1.ShopService.Login:input_type -> shop.v1.LoginReq
	5, // 2: shop.v1.ShopService.Captcha:input_type -> google.protobuf.Empty
	5, // 3: shop.v1.ShopService.Detail:input_type -> google.protobuf.Empty
	0, // 4: shop.v1.ShopService.Register:output_type -> shop.v1.RegisterReply
	0, // 5: shop.v1.ShopService.Login:output_type -> shop.v1.RegisterReply
	4, // 6: shop.v1.ShopService.Captcha:output_type -> shop.v1.CaptchaReply
	3, // 7: shop.v1.ShopService.Detail:output_type -> shop.v1.UserDetailResponse
	4, // [4:8] is the sub-list for method output_type
	0, // [0:4] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}
```

其中, `shop.v1.ShopService.Xxx`就是你需要不需要经过JWT验证的接口, 复制它, 然后再`server/http.go`添加:

把一个接口, 例如`shop.v1.ShopService.Register`, 在前面加上斜杠`/`, 然后把最后的`.接口字段`, 也就是你在proto定义的
`rpc接口名称`, 换成斜杠, 例如`shop.v1.ShopService/Register`

示例:

```
shop.v1.ShopService.Register
```

在kratos中表示为:

```
/shop.v1.ShopService/Register
```

然后编写白名单

```go
// NewWhiteListMatcher 设置白名单，不需要 token 验证的接口
func NewWhiteListMatcher() selector.MatchFunc {
	whiteList := make(map[string]struct{})
	whiteList["/shop.v1.ShopService/Captcha"] = struct{}{}
	whiteList["/shop.v1.ShopService/Login"] = struct{}{}
	whiteList["/shop.v1.ShopService/Register"] = struct{}{}
	return func(ctx context.Context, operation string) bool {
		if _, ok := whiteList[operation]; ok {
			return false
		}
		return true
	}
}
```

最后在HTTP中间件添加:

```go
http.Middleware(
			selector.Server( // jwt 验证
				jwt.Server(func(token *jwt2.Token) (interface{}, error) {
					return []byte(ac.JwtKey), nil
				}, jwt.WithSigningMethod(jwt2.SigningMethodHS256)),
			).Match(NewWhiteListMatcher()).Build(),
		),
```

完整的`http.go`

```go
package server

import (
	"context"
	"github.com/go-kratos/kratos/v2/middleware/auth/jwt"
	"github.com/go-kratos/kratos/v2/middleware/logging"
	"github.com/go-kratos/kratos/v2/middleware/selector"
	"github.com/go-kratos/kratos/v2/middleware/validate"
	jwt2 "github.com/golang-jwt/jwt/v4"
	"github.com/gorilla/handlers"
	"shop/internal/conf"
	"shop/internal/service"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/transport/http"

	v1 "shop/api/shop/v1"
)

// NewWhiteListMatcher 设置白名单，不需要 token 验证的接口
func NewWhiteListMatcher() selector.MatchFunc {
	whiteList := make(map[string]struct{})
	whiteList["/shop.v1.ShopService/Captcha"] = struct{}{}
	whiteList["/shop.v1.ShopService/Login"] = struct{}{}
	whiteList["/shop.v1.ShopService/Register"] = struct{}{}
	return func(ctx context.Context, operation string) bool {
		if _, ok := whiteList[operation]; ok {
			return false
		}
		return true
	}
}

func NewHTTPServer(
	c *conf.Server,
	ac *conf.Auth,
	s *service.ShopService,
	logger log.Logger,
) *http.Server {
	var opts = []http.ServerOption{
		http.Middleware(
			recovery.Recovery(),
			selector.Server( // jwt 验证
				jwt.Server(func(token *jwt2.Token) (interface{}, error) {
					return []byte(ac.JwtKey), nil
				}, jwt.WithSigningMethod(jwt2.SigningMethodHS256)),
			).Match(NewWhiteListMatcher()).Build(),
			validate.Validator(), // 接口访问的参数校验
			logging.Server(logger),
			// tracing.Server(), // 链路追踪
		),
		http.Filter(handlers.CORS( // 浏览器跨域
			handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type", "Authorization"}),
			handlers.AllowedMethods([]string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"}),
			handlers.AllowedOrigins([]string{"*"}),
		)),
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
	v1.RegisterShopServiceHTTPServer(srv, s)
	return srv
}

```
