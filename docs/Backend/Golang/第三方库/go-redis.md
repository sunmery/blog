## 语法

## 错误处理

redis.Nil 空值
```go

val, err := rdb.Get(ctx, "key").Result()
switch err{
	case redis.Nil
}
```


### 有序列表/有序集合
添加
```go
redis.ZAdd()
```

```

## Install
```shell
go get github.com/go-redis/redis
```

## Test
```go
package test

import (
	"fmt"
	"github.com/go-redis/redis"
	"testing"
	"time"
)

func TestRedisDB(t *testing.T) {
	client := redis.NewClient(&redis.Options{
		Addr:        "192.168.0.158:6379",
		Password:    "msdnmm",
		DB:          0,
		DialTimeout: 30 * time.Second,
	})
	pong, err := client.Ping().Result()
	if err != nil {
		t.Fatal("Ping Redis Error:" + err.Error())
	}
	defer func(client *redis.Client) {
		err := client.Close()
		if err != nil {
			t.Fatal(err)
		}
	}(client)

	fmt.Println("Successfully connected redis and pinged." + pong)
}

```

## 工具类
[参考](https://blog.csdn.net/qq_44237719/article/details/128920821)