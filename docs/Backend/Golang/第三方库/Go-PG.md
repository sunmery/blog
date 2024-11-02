## 前置
### 初始化
数据库连接选项
pg.Options有如下字段:
- `Network`: 网络类型，例如 "tcp"，"unix" 或 "udp"。如果为空，将默认使用 "tcp"。
- `Addr`: 数据库服务器地址，如 "localhost:5432"。
- `Dialer`: 自定义拨号器，如果你想对连接进行更精细的控制，可以使用此选项。
- `OnConnect`: 每当创建新的数据库连接时，`OnConnect` 中的函数都会被调用。
- `User`: 用于连接到数据库的用户名。
- `Password`: 用于连接到数据库的密码。
- `Database`: 要连接的数据库的名称。
- `ApplicationName`: 应用程序的名称，这个名称将出现在 PostgreSQL 的日志和系统表中。
- `TLSConfig`: 用于 TLS 连接的配置。如果为空，则不使用 TLS。
- `DialTimeout`: 连接到数据库的超时时间。
- `ReadTimeout`: 读操作的超时时间。
- `WriteTimeout`: 写操作的超时时间。
- `MaxRetries`: 连接失败后的最大重试次数。
- `RetryStatementTimeout`: 是否在重试时使用语句超时。
- `MinRetryBackoff`: 每次重试之间的最小退避时间。
- `MaxRetryBackoff`: 每次重试之间的最大退避时间。
- `PoolSize`: 连接池的大小，即同时保持的最大数据库连接数。
- `MinIdleConns`: 池中最小的空闲连接数。
- `MaxConnAge`: 连接可以保持打开的最长时间。
- `PoolTimeout`: 如果所有连接都在使用中，那么获取新的数据库连接的最长等待时间。
- `IdleTimeout`: 空闲连接在关闭前可以保持空闲的最长时间。
- `IdleCheckFrequency`: 检查空闲连接的频率。

处理大量并发数据库操作，增加 `PoolSize`。
长时间保持数据库连接，增加 `MaxConnAge`。
数据库服务器使用 SSL，提供 `TLSConfig`值

默认只需要四个值:
```
Addr:     "192.168.0.158:5432",
User:     "user",
Password: "password",
Database: "dbname",
```

初始化示例:
```go
package repository

import "github.com/go-pg/pg/v10"

var PG *pg.DB

func InitPostgresDB() {
	// 1. 链接
	PG = pg.Connect(&pg.Options{
		Addr:     "192.168.0.158:5432",
		User:     "root",
		Password: "pass",
		Database: "db",
	})
}
```

## 类型

### 主键
```go
type User struct {
	Id   int64 `pg:",pk"`
	Name string
}
```

## 创建

## 插入

### 单行插入
```go
book1 := &Book{ Title: "Example Book 1", Author: "Some Author", }
```


### 多行插入
```go
book2 := &Book{ 
	Title: "Example Book 2", 
	Author: "Another Author",
} 
book3 := &Book{ 
	Title: "Example Book 3", 
	Author: "Yet Another Author",
} 
_, err = db.Model(book2, book3).Insert() 
if err != nil { panic(err) }
```

## 查询
### 单行查询
```go
query = 1
book := &Book{}
err := db.Model(book).Where("id = ?", query).Select()
```

全部查询
```go
var books []Book
err := db.Model(&books).Select()
```

### 条件查询
```go
book := &Book{}
err := db.Model(book).Where("id = ?", query).Select()
err := db.Model(book).Where("id = ?", query).Order("title asc").Select()
```

## 删除

单条删除
```go
book := &Book{Id:"1"}
err := db.Model(book).WherePK().Delete()
```

删除表
```go
import (
	"github.com/go-pg/pg/v10" 
	"github.com/go-pg/pg/v10/orm" 
)

err := db.Model((*Book)(nil)).DropTable(&orm.DropTableOptions{
	ifExits: true,
	Cascade: true, // 级联删除所有依赖该表的对象
})
```

## 更新

### 单条更新:

```go
book.Name = "new name"
_,err := db.Model(&book).WherePK().Update()
```

```go
newBooks := []*Book[
	{
		Id: 123,
		Name: "123123a"
	},
	{
		Id: 1234,
		Name: "123123a1"
	}
]
result,err:= db.Model(&newBooks).Update()
```

### 删除单条数据 
```go
_, err = db.Model(&user).WherePK().Delete()
if err != nil {
	panic(err) 
} 
```

### 删除全部 
```go
_, err = db.Model((*User)(nil)).Where("TRUE").Delete() 
if err != nil {
	panic(err) 
} 
```

### 删除表 
```go
err := db.Model((*User)(nil)).DropTable(&orm.DropTableOptions{})
if err != nil {
	panic(err) 
} 
```

### 删除数据库(需要超级用户权限) 
```go
_, err = db.Exec("DROP DATABASE new_database") 
if err != nil {
	panic(err) 
}
```