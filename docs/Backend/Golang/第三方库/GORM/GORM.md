
接收postgres的json数组:
```shell
go get github.com/lib/pq
```
1. 定义
```go
type Video struct { 
	LikeList pq.StringArray `gorm:"type:varchar[]" json:"like_list"`
}
```
- `varchar[]`类型: pg.StringArray

字段一致：
```shell
Code  string `gorm:"column:product_code"`
```

表名一致：
```shell
type Product{}

func (p Product) TableName() string {
    return "product"
}

```

Create
```shell
if err := db.Create(&struct).Error; err !=nil{
	
} 
```
FirstOrCreate:
如果存在, 条件由`Where`控制条件, 如果满足`Where`的条件:表示数据库已存在相关条目, `RowsAffected`此时为0,反之不存在则创建, 由`FirstOrCreate`的第一个参数控制创建的结构
```go
// 查询或创建用户
	// 当name不存在时创建用户
	// 当name存在时返回被创建
	findOrCreateUser := u.data.db.Where("name = ?", newUser.Name).FirstOrCreate(&newUser)
	// RowsAffected为0表示用户已存在数据库
	if findOrCreateUser.RowsAffected == 0 {
		return &biz.UserResponse{
			StatusCode: 400,
			StatusMsg:  fmt.Sprintf("用户名: %s 已被注册", newUser.Name),
			UserID:     int64(newUser.ID),
		}, nil
	}
	if findOrCreateUser.Error != nil {
		slog.Errorf("创建用户失败:", findOrCreateUser.Error)
		return &biz.UserResponse{
			StatusCode: 500,
			StatusMsg:  fmt.Sprintf("创建用户失败:%s", findOrCreateUser.Error),
			UserID:     int64(newUser.ID),
		}, nil
	}
```