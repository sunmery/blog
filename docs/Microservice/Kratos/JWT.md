## RSA + SHA256
编写实际配置:
`configs/auth.yml`
```yml
jwt:
  service_key: service_key
  api_key: |
    -----BEGIN CERTIFICATE-----
    MIIE2TCCAsGgAwIBAgIDAeJAMA0GCSqGSIb3DQEBCwUAMCYxDjAMBgNVBAoTBWFk
    bWluMRQwEgYDVQQDDAtjZXJ0X3B6bXY1czAeFw0yNDExMjMwMzQ1MjBaFw00NDEx
    MjMwMzQ1MjBaMCYxDjAMBgNVBAoTBWFkbWluMRQwEgYDVQQDDAtjZXJ0X3B6bXY1
    czCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMw4OGyd7JP/PcEVyiPM
    LvZIigvUPuhbk0vDhgsmQjHHXDR8NA6qRHRtaQ3HCZ1QTNmMg9oYY3w/5cK3KsLG
    wObm3IqSckWP5c/tl9KOo1PYyMWtQUi3B6fwnYVczy80puWKumT1WS5RehR9EnXT
    SO0AgjEzhCanBFCn56h9s6sCK4BADNCmKSUsIudxZ83G4PPAWxsVejVEDs0uUZdS
    OBOoxa3ChuxOajmuDt/Lr9BLH16LT+t0d9vPOYUNWfJGZxLRDbfEhoF7pB+xcr6o
    sve/66NXE9empbvT9ePx/j26/9uNNqPVboC//Or5biSF2Gg7zdUGgxNFoOjX/WPp
    0IBlvZgI6PHO1IIt97ndIrMNEO5C2qLrXXxHNEKT01ioa8Em6P1UBQGnFusKmsdd
    0TnMDpTs3CLeQjok3sQ+HTUVrJCDaxBWskWTluDdMEf8Oe8vOrFFO3GIFjokqfHm
    g/fA+vDQ5nImgKIwGfQ0nVup+z0B/1GDuO53HAI2Y+73Cu1qdBRqz8pg0q/hBJpu
    hihZz/dInrPBkqH1QelXskOeey8KKXQnrYN+nJBazBedhzySED+hY7P1Bzn6Ueos
    /5OJYzM41bvUbOXfSIhh1JeC8SldCl/Ek7xW/ZT1Ky5d2pH2+BinlUSo+88Vm2cI
    pII56m6IGVX7Yy2SnexNSuI1AgMBAAGjEDAOMAwGA1UdEwEB/wQCMAAwDQYJKoZI
    hvcNAQELBQADggIBABDeIo7mgOxE+yJT+WfI8AuxroZY9hPf8xukAuMgpGc4cyGN
    +Mbv4rK4c04gC2pGUFCeIEsgX7yhAJTTpDxWLDxhrSFGcLWkozJ0aycKoOUYbBx+
    MO65WXPeI2YaSuyZ+4OllDJo2MJynbeyk/nc8bnQHcESi+9zSgAQxBvng9cXokDf
    eKzAaES5a7ZJYqv+vg9brPNA6K5FV7DN54FEHu4RvkwWueQHLjqDySg0LWdgOQjR
    ugIYfHTiLADUPx6gBEUWtFzioUSt5Uo7qlhKBPo4lvJua3pmWIt6yrcXRYa04uRQ
    KN1vttz2Ysyi2UeLwzhyg6aD3CyGzuUla+2ObMRiYsLE38k2sqrmJdBsIAqLyblm
    j1BxSYn6+Jf6WmuMKVAgKFJ1Tcg3GeDMXrYluMDbOeEF28fYA1I3AzRInrwW63C1
    Nm/x5hR97Y+IaQ2sQAziHEpaIg+9WAwpojkVw5BFJxkn6kC7/rHr87NwHbHG7we9
    sRjKeJlgyOsmF84FdjIJgphIqyHx4lxxYBBGUcrlbJbyoAlh2LCTb+UWBu40jpCi
    84PoxOMXs8NEugVQifzRi+8snxhAkKJyvYu8XByViNER2IwT1d3bKLEF1sw2lAdN
    NWMsDqDQbcauDIqiAX0BHJERWEOZVQkV6WjHmvhqzUxkSWLj+0CxA0lomPTj
    -----END CERTIFICATE-----

```

添加配置:
`conf/conf.proto`
```proto
message Auth {
  message JWT {
    string service_key = 1;
    string api_key = 2;
  }
  JWT jwt = 1;
}
```

注入配置:
cmd/server.go:
```go
...
    var ac conf.Auth
	if err := c.Scan(&ac); err != nil {
		panic(err)
	}

	app, cleanup, err := wireApp(bc.Server, bc.Data, &ac, logger)
...
```

注入依赖:
`wire.go`
```go
// wireApp init kratos application.
func wireApp(*conf.Server, *conf.Data, *conf.Auth, log.Logger) (*kratos.App, func(), error) {
	panic(wire.Build(server.ProviderSet, data.ProviderSet, biz.ProviderSet, service.ProviderSet, newApp))
}

```

HTTP中间件: `server/http.go`
```go
package server

import (
	"context"
	v1 "credit_cards/api/credit_cards/v1"
	"credit_cards/internal/conf"
	"credit_cards/internal/service"
	"crypto/rsa"
	"fmt"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/go-kratos/kratos/v2/middleware/auth/jwt"
	"github.com/go-kratos/kratos/v2/middleware/recovery"
	"github.com/go-kratos/kratos/v2/middleware/selector"
	"github.com/go-kratos/kratos/v2/transport/http"
	jwtV5 "github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/handlers"
)

// NewWhiteListMatcher 创建jwt白名单
func NewWhiteListMatcher() selector.MatchFunc {
	whiteList := make(map[string]struct{})
	// whiteList["/admin.v1.AdminService/Login"] = struct{}{}
	return func(ctx context.Context, operation string) bool {
		if _, ok := whiteList[operation]; ok {
			return false
		}
		return true
	}
}

// parseRSAPublicKeyFromPEM 解析 RSA 公钥
func parseRSAPublicKeyFromPEM(pemBytes []byte) (*rsa.PublicKey, error) {
	publicKey, err := jwtV5.ParseRSAPublicKeyFromPEM(pemBytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse RSA public key: %w", err)
	}
	return publicKey, nil
}

// NewHTTPServer new an HTTP server.
func NewHTTPServer(c *conf.Server, ac *conf.Auth, creditCards *service.CreditCardsServiceService, logger log.Logger) *http.Server {
	publicKey, err := parseRSAPublicKeyFromPEM([]byte(ac.Jwt.ApiKey))
	if err != nil {
		panic("failed to parse public key")
	}
	var opts = []http.ServerOption{
		http.Middleware(
			recovery.Recovery(),
			selector.Server(
				jwt.Server(
					func(token *jwtV5.Token) (interface{}, error) {
						// 检查是否使用了正确的签名方法
						if _, ok := token.Method.(*jwtV5.SigningMethodRSA); !ok {
							return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
						}
						return publicKey, nil
					},
					jwt.WithSigningMethod(jwtV5.SigningMethodRS256),
				),
			).
				Match(NewWhiteListMatcher()).Build(),
		),
		http.Filter(handlers.CORS(
			handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type", "Authorization", "Cookie"}),
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
	v1.RegisterCreditCardsServiceHTTPServer(srv, creditCards)
	return srv
}

```


将jwt负载转换成业务字段, 例如`Payload`结构:
```go
type Payload struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Owner string `json:"owner"`
	Type  string `json:"type"`

	jwtV5.Claims `json:"claims"`
}

func ExtractPayload(ctx context.Context) (*Payload, error) {
	user, ok := jwt.FromContext(ctx)
	if !ok {
		return nil, errors.New("invalid token")
	}

	// 检查是否是 Payload 类型
	if payload, ok := user.(*Payload); ok {
		return payload, nil
	}

	// 如果是 MapClaims，尝试转换
	claims, ok := user.(jwtV5.MapClaims)
	if !ok {
		return nil, errors.New("invalid claims type")
	}

	payload := &Payload{
		ID:    fmt.Sprintf("%v", claims["id"]),
		Name:  fmt.Sprintf("%v", claims["name"]),
		Owner: fmt.Sprintf("%v", claims["owner"]),
		Type:  fmt.Sprintf("%v", claims["type"]),
	}

	return payload, nil
}

```

使用jwt的payload:
data/example.go:
```go
func (c *creditCardsRepo) GetCreditCard(ctx context.Context, req *biz.GetCreditCardsRequest) ([]*biz.CreditCards, error) {
    // 通过jwt.FromContext(ctx)获取token的payload内容
	payload, err := token.ExtractPayload(ctx)
	if err != nil {
		return nil, err
	}

	if req.Owner != payload.Owner || req.Name != payload.Name {
		return nil, errors.New("invalid token")
	}
	
	fmt.Printf("token %v", token)
}
```
