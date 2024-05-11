
## Tag

`swaggerignore:"true"`:忽略某个结构体

例如: 嵌套结构体
```go
// User 映射数据库的结构
type User struct {
	gorm.Model `swaggerignore:"true"`
	Id         int64  `binding:"-" json:"id" gorm:"primaryKey;index" json:"id,omitempty"`
	Username   string `binding:"required,max=32" json:"username" gorm:"column:name;not null" json:"username,omitempty"`
	Password   string `binding:"required,max=32" json:"password" gorm:"column:password;not null" json:"password,omitempty"`
}
```

或者普通结构体:
`swaggo` 的特定注释标签 `swagg:ignore` 或 `swagg:noresponse`。
```go
// swagg:ignore
type User struct {
	gorm.Model
	Id         int64  `binding:"-" json:"id" gorm:"primaryKey;index" json:"id,omitempty"`
	Username   string `binding:"required,max=32" json:"username" gorm:"column:name;not null" json:"username,omitempty"`
	Password   string `binding:"required,max=32" json:"password" gorm:"column:password;not null" json:"password,omitempty"`
}
```
则`gorm.Model`不会再` sawagger` 文档显示