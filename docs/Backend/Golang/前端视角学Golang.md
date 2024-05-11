## 类型
TS的组合(联合类型): 利用`&`与符号
```ts
type TypeA { name: string }
type TypeB { age: number }
Type TytpeC = TypeA & TypeB
```

GO的组合: 利用`*`指向这个结构体的地址, 并使用`&`符号取到该结构体的指针
```go
type DatabasePerson struct {
	UserID   string `bson:"id"`
	Password string `bson:"password"`
	Role     string `json:"role" bson:"role"`
	Avatar   string `bson:"avatar"`
	Username string `bson:"name"`
}
// 在原有基础上添加新的结构
type UserInfo {
	*DatabasePerson
	Token string
}

// 使用
{
	DatabasePerson: &DatabasePerson{
		UserID:   databasePerson.UserID,
		Role:     databasePerson.Role,
		Avatar:   databasePerson.Avatar,
		Username: databasePerson.Username,
	},
	Token: token,
}
```

## 函数

### 参数
#### 剩余参数
对应Go的可变参数, 不一样的点是, go使用剩余参数时参数只能为一个
```go
func GetPath(args ...any) string {
	var dir string
	if len(args) < 2 || args[1] == "" {
		dir = "/config/"
	}
	_, filename, _, _ := runtime.Caller(0)
	root := path.Dir(path.Dir(filename))             //获取当前工作目录
	dirPath := path.Dir(root + dir)                  // 获取配置文件的目录
	filePath := path.Join(dirPath, args[0].(string)) // 获取配置文件
	return filePath
}

```