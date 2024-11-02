```shell
go get github.com/daveagh/go-spew/spew
```
使用
```shell
package middleware

import (
	"context"
	"github.com/davecgh/go-spew/spew"
	"github.com/go-kratos/kratos/v2/middleware"
	"github.com/go-kratos/kratos/v2/transport"
	"github.com/gookit/slog"
	"tiktok/internal/conf"
)

func Auth(handler middleware.Handler) middleware.Handler {
	return func(ctx context.Context, req interface{}) (reply interface{}, err error) {
		if tr, ok := transport.FromServerContext(ctx); ok {
			// Do something on entering
			Authorization := tr.RequestHeader().Get("Authorization")
			spew.Dump(Authorization)
			slog.Debugf("Authorization:", Authorization)
			// token, err := helper.JWTToken{}.GenerateJWTToken(conf.Auth{}.SigningKey, helper.Claim{Username: req.username})
			// if err != nil {
			// 	return nil, err
			// }
			defer func() {
				// Do something on exiting
			}()
		}
		return handler(ctx, req)
	}
}

```