JSON数据类型: 数组嵌套对象
```json
{
	"Obj": [
	    {
	        "k11": "k11",
	        "k12": "k12"
	    },
	    {
	        "k22": "k12"
	    }
	]
}
```

Go类型定义
```go
type ObjType struct {
	Obj []map[string]string
}
```

MongoDB的ObjectID类型
```go
type Type struct {
	ID primitive.ObjectID `bson:"_id"`
}
```

初始化结构体嵌套匿名结构体
```go
type Info struct {
	Category  struct { //分组 非必须， 可能为空
	Id   string `bson:"id"`   //分组ID编号
	Name string `bson:"name"` // 分组名称
	}
}
// 初始化
var info := Info{
	Category struct { //分组 非必须， 可能为空
	Id   string `bson:"id"`   //分组ID编号
	Name string `bson:"name"` // 分组名称
	}{
		Id: "1",
		Name: "cat",
	}
}
```

标签Tag
这`omitempty` [结构标签](https://www.mongodb.com/docs/drivers/go/current/fundamentals/bson/#std-label-golang-struct-tags)省略相应的 插入文档中的字段（留空时）。
```go
type Restaurant struct {	
Name         string	
RestaurantId string        `bson:"restaurant_id,omitempty"`
Cuisine      string        `bson:"cuisine,omitempty"`
Address      interface{}   `bson:"address,omitempty"`
Borough      string        `bson:"borough,omitempty"`
Grades       []interface{} `bson:"grades,omitempty"`
}
```