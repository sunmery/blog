`middleware/cors.go`
```go
package utils

import (
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
)

func Cors() gin.HandlerFunc {
	return func(c *gin.Context) {
		method := c.Request.Method
		origin := c.Request.Header.Get("Origin") //请求头部
		if origin != "" {
			//接收客户端发送的origin （重要！）
			c.Writer.Header().Set("Access-Control-Allow-Origin", origin)
			//服务器支持的所有跨域请求的方法
			c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE,UPDATE")
			//允许跨域设置可以返回其他子段，可以自定义字段
			c.Header("Access-Control-Allow-Headers", "Authorization, Content-Length, X-CSRF-Token, Token,session,tokenString")
			// 允许浏览器（客户端）可以解析的头部 （重要）
			c.Header("Access-Control-Expose-Headers", "Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers")
			//设置缓存时间
			c.Header("Access-Control-Max-Age", "172800")
			//允许客户端传递校验信息比如 cookie (重要)
			c.Header("Access-Control-Allow-Credentials", "true")
			//
			//c.Header("Content-Type", "application/json")
		}

		//允许类型校验
		if method == "OPTIONS" {
			c.Header("Access-Control-Allow-Origin", "*")
			c.Header("Access-Control-Allow-Headers", "Authorization, Content-Length, X-CSRF-Token, Token,session,X_Requested_With,Accept, Origin, Host, Connection, Accept-Encoding, Accept-Language,DNT, X-CustomHeader, Keep-Alive, User-Agent, X-Requested-With, If-Modified-Since, Cache-Control, Content-Type, Pragma")
			c.Header("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT")
			c.Header("Access-Control-Expose-Headers", "Authorization, Content-Length, Access-Control-Allow-Origin, Access-Control-Allow-Headers, Content-Type")
			c.Header("Access-Control-Allow-Credentials", "true")
			c.AbortWithStatus(http.StatusNoContent)
		}

		defer func() {
			if err := recover(); err != nil {
				log.Printf("Panic info is: %v", err)
			}
		}()
		c.Next()
	}
}

```

**main.go**
Gin应用中间件
```go
gin.SetMode(gin.ReleaseMode) 
server := gin.Default()
server.Use(middleware.Cors()) 
```

## 参考
1. [博客园](https://www.cnblogs.com/-wenli/p/15708870.html)
2. [掘金](https://juejin.cn/post/6987205879653204004)
3. [简书](https://www.jianshu.com/p/ae260870a0ca)