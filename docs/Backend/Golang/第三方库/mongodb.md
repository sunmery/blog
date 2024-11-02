## Install

```shell
go get -u go.mongodb.org/mongo-driver/bson
```

## Test
```go
package test

import (
	"context"
	"fmt"
	"github.com/spf13/viper"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
	"log"
	"path"
	"runtime"
	"testing"
)

func TestMongoDB(t *testing.T) {
	client, err := mongo.Connect(context.TODO(), options.Client().SetAuth(options.Credential{
		Username: "username",
		Password: "password",
	}).ApplyURI("uri"))
	if err != nil {
		t.Fatal(err)
	}
	defer func() {
		if err = client.Disconnect(context.TODO()); err != nil {
			t.Fatal(err)
		}
	}()

	// Ping the primary
	if err := client.Ping(context.TODO(), readpref.Primary()); err != nil {
		t.Fatal(err)
	}
	fmt.Println("Successfully connected mongodb and pinged.")
}

func GetPath(file, dir string) string {
	if dir == "" {
		dir = "/config/"
	}
	_, filename, _, _ := runtime.Caller(0)
	root := path.Dir(path.Dir(filename)) //获取当前工作目录
	dirPath := path.Dir(root + dir)      // 获取配置文件的目录
	filePath := path.Join(dirPath, file) // 获取配置文
	return filePath
}

```

## Init

1. 定义一个保存数据库的URI常量

- 自建服务器格式:
  ![[Pasted image 20230114031810.png]]
- Mongo的集群的服务器格式:

```txt
mongodb+csv://user:pass@sample.host:27017/
```

例:

```go
const URI = "mongodb://root:msdnmm@192.168.0.152:27017/"
```

2. 创建客户端
[mongodb](https://www.mongodb.com/docs/drivers/go/current/fundamentals/connection/)
**语法**:

```go
mongo.Connect(context,options.Client().ApplyURI(uri)) (client, err)
```

**参数**

1. `context`: 上下文
2. options: 选项, 用于连接数据库的选项
3. uri: 数据库的URI

```go
const URI = "mongodb://root:msdnmm@192.168.0.152:27017/"
var Client, MongodbErr = mongo.Connect(context.TODO(), options.Client().ApplyURI(URI))
if MongodbErr != nil {
	panic(MongodbErr)
} 
```

3. 连接数据库文档

**语法**:

```go
mongo.Connect(context.TODO(), options.Client().ApplyURI(URI)).Database("database_name").Collection("collection_name")
```

**参数**:
`Database`: 数据库名
`Collection`: 文档名(表名)

例:

```go
var Client, MongodbErr = mongo.Connect(context.TODO(), options.Client().ApplyURI(URI))
if MongodbErr != nil {
	panic(MongodbErr)
} 
coll := Client.Database("golang").Collection("users")
```

## Use

### 单结果查询FindOne()
[find](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/read-operations/query-document/)
**语法:**

```go
struct.FindOne(content, filter).Decode(&strcut) err
```

**参数:**

FindOne:

1. `content`: 上下文
2. `filter`: 查询条件

Decode:

1. `strcut` 结构体, 需要传递该结构体的指针, 进行修改

**返回值**:

1. 失败信息
查询失败返回`mongo.ErrNoDocuments`

**使用**:

1. 定义结构体接收数据库返回的值, 一般与数据库的字段相对应
2. 定义查询条件
3. 查询
4. 将返回的`bson`二进制`json`结果转成所需格式

**前提:**

向数据库插入如下指令:
```mongodb
use golang_server
db.users.insertOne({
  username:"lisa",
  password:"123456"
})
```

例:

```go
// Person 用户结构
type Person struct {
	Username string `json:"username" bson:"username" binding:"required,min=1,max=20"` // 如果需要对数据传递参数, 必须使用bson 这个tag
	Password string `json:"password" binding:"required,min=1,max=20"`
}

var Client, MongodbErr = mongo.Connect(context.TODO(), options.Client().ApplyURI(URI))
if MongodbErr != nil {
	panic(MongodbErr)
} 

func main() {
    coll := Client.Database("golang_server").Collection("ratings") // 连接数据库
	var person Person
	filter := bson.D{{"username", "lisa"}} // 设置查询条件
	// 返回结果, 如果成功则将返回的bson结果绑定到结构体
	err := person.FindOne(content.TODO(), filter).Decode(&person)
	if err != nil {
		if findErr == mongo.ErrNoDocuments{
			fmt.Println("要查询的数据在数据库中不存在")
		}
		panic(result.re)
	}
	res,_ := json.Marshal(person) // 将bson二进制json转为json
	fmt.Println(string(res)) // 以字符串形式输出转换结果
}
```

### 多结果查询Find()

**语法:**

```go
result, err := struct.Find(context, filter) (result, err)
err = result.All(context, &result) (err)
```

**参数:**

**Find:**

1. `struct`: 结构体
2. `context`: 上下文
3. `filter`: 查询条件

**返回值:**

1. `result`: 查询结果
2. `err`: 错误消息

**All:**

1. context: 上下文
2. result: 返回的结果

**返回值:**

1. `err`: 错误消息

**使用:**

1. 定义结构体`Tea`接收数据库返回的值, 一般与数据库的字段相对应
2. 定义`filter`查询条件
3. 通过`Find()`查询
4. 通过`All()`获取全部返回的结果
5. 通过`for rang`遍历输出数据(可选)
6. 通过`json.Marshal()`将返回的`bson`二进制`json`结果转成所需格式

**例:**

**前提:**
向`golang_server`数据库的`ratings`文档(表)插入如下字段

```mongodb
use golang_server
db.ratings.insertMany([
  { type: "Masala", rating: 10, vendor: ["A", "C"] },
  { type: "English Breakfast", rating: 6 },
  { type: "Oolong", rating: 7, vendor: ["C"] },
  { type: "Assam", rating: 5 },
  { type: "Earl Grey", rating: 8, vendor: ["A", "B"] },
])
```

例:

```go
type Tea struct {
Type string   `json:"type" bson:"Type"`
Rating int32    `json:"rating" bson:"Rating"`
Vendor []string `json:"vendor" bson:"vendor,omitempty" json:"vendor,omitempty"`
}

var Client, MongodbErr = mongo.Connect(context.TODO(), options.Client().ApplyURI(URI))
if MongodbErr != nil {
	panic(MongodbErr)
} 

func main(){
  coll := client.Database("golang_server").Collection("ratings") // 连接数据库
  filter := bson.D{{"type", "Oolong"}} // 定义查询条件
  var results []Tea // 定义切片结构体(Find返回多个可能结果)
  result, err := coll.Find(context.TODO(), filter)                        // 查询

  // 处理错误, 如果没有错误则将result查询的结果赋值给结构体results
  if err = result.All(context.TODO(), &results); err != nil {
  	panic(err)
  } 
  // 循环获取输出获取到的值
  for _, result1 := range results {
  	res, _ := json.Marshal(result1)
  	fmt.Println("res:", string(res))
  } 
  c.JSON(http.StatusOK, gin.H{
  	"result": results,
  })
}
```

## 查询

### 返回指定字段
关键字: `SetProjection`
```go
filter := bson.D{{}}
opts := options.Find().SetProjection(bson.D{{"name", 1},{"number",1}})
cursor, err := dbBasic.Find(context.TODO(), filter, opts)
```

### 排序
语法:
key: 要排列的字段
0/1: 倒序/正序排列
```go
filter := bson.D{{<query>:<value>}}
opt := options.Find().SetSort(bson.D{{<key>:<0/1>}}) // 选项
cursor, err := db.Client.
	Database("Database").
	Collection("Collection").
	Find(context.TODO(),filter, opt)
```

示例: 查询`im`数据库的`message_basic`文档中的`created_at`, 对`created_at`进行`正序排序`
```go
import "go.mongodb.org/mongo-driver/mongo/options"
func MessageList(c *gin.Context) {
	opt := options.Find().SetSort(bson.D{{"created_at", 1}})
	cursor, err := db.Client.
		Database("im").
		Collection("message_basic").
		Find(context.TODO(), bson.D{{}}, opt)
	if err != nil {
		log.Fatalln(err)
		return
	}

	var message []schema.MessageBasic

	if err = cursor.All(context.TODO(), &message); err != nil {
		log.Fatalln(err)
		return
	}
	fmt.Println("message:", message)
	c.JSON(http.StatusOK, gin.H{
		"code":    http.StatusOK,
		"message": "获取成功",
		"body":    message,
	})
}
```

### 查询全部
[mongodb](https://raw.githubusercontent.com/mongodb/docs-golang/master/source/includes/usage-examples/code-snippets/find.go)
返回值:  `[]map(string)any`

```go
type MessageBasic struct {
	//ID           primitive.ObjectID `bson:"_id" json:"id"`
	UserIdentity string `json:"user_identity"`
	RoomIdentity string `json:"room_identity"`
	Data         string `json:"data"`
	CreatedAt    int64  `json:"created_at"`
	UpdatedAt    int64  `json:"updated_at"`
}

func MessageList(c *gin.Context) {

	cursor, err := Client.
		Database("im").
		Collection("message_basic").
		Find(context.TODO(), bson.D{{}})
	if err != nil {
		log.Fatalln(err)
		return
	}

	var message []MessageBasic // 返回结果是多对象的数组. 以切片形式存储

	if err = cursor.All(context.TODO(), &message); err != nil {
		log.Fatalln(err)
		return
	}
	fmt.Println("message:", message)
	c.JSON(http.StatusOK, gin.H{
		"data": message,
	})
}

```

### 查询数组是否包含某个值
关键语法: `$in`
```go
result := db.FindOne(context.Background(), bson.D{{"user_identity", bson.D{{"$in", userIdentity4}}}}).Decode(&user)
```

示例:
数据库插入数据
```sql
db.user_room.insertOne({
 "user_identity":["bc83108c977248daad2f3f815d25cfe5","d22e9e82fab041cc8f8d57d51d6b802d"]
})
```

golnag查询
```go
type UserRoom struct {
	RoomIdentity []string   `bson:"room_identity"`
}
var user UserRoom
userIdentity := "bc83108c977248daad2f3f815d25cfe5"
var userIdentityArr []string
userIdentityArr := append(userIdentity3, userIdentity)
//roomIdentity := "1"
result := db.FindOne(context.Background(), bson.D{{"user_identity", bson.D{{"$in", userIdentityArr}}}}).Decode(&user)
if result != nil {
	if result == mongo.ErrNoDocuments {
		log.Println("查找不到")
	}
	log.Println("err")
}
fmt.Println("user:", user)
```

## 插入
[inset](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/write-operations/upsert/)
```go
coll := client.Database("tea").Collection("ratings")
docs := []interface{}{
	Tea{Type: "Masala", Rating: 10, Vendor: []string{"A", "C"}},
	Tea{Type: "English Breakfast", Rating: 6},
	Tea{Type: "Oolong", Rating: 7, Vendor: []string{"C"}},
	Tea{Type: "Assam", Rating: 5},
	Tea{Type: "Earl Grey", Rating: 8, Vendor: []string{"A", "B"}},
}
result, err := coll.InsertMany(context.TODO(), docs)
if err != nil {
  panic(err)
}
```

## 特征

MongoDB存储是BSON(二进制的JSON),所以对数据库操作(改增删)结构体转成JSON时候必须要注意struct的`Tag`类型必须是`bson`

## 数据结构

**BSON**
MongoDB中的JSON文档存储在名为BSON(二进制编码的JSON)
的二进制表示中。与其他将JSON数据存储为简单字符串和数字的数据库不同，BSON编码扩展了JSON表示，使其包含额外的类型，如int、long、date、浮点数和decimal128。这使得应用程序更容易可靠地处理、排序和比较数据。

总结: 对数据库进行操作(改增删)的时候的结构体类型是`bson`类型, 否则操作失败

连接MongoDB的Go驱动程序中有两大类型表示BSON数据：`D`和`Raw`。

- D：一个BSON文档。这种类型应该在顺序重要的情况下使用，比如MongoDB命令。
- M：一张无序的map。它和D是一样的，只是它不保持顺序。
- A：一个BSON数组。
- E：D里面的一个元素。

## 更新
### 更新某个字段的值
```go
update := bson.D{{"$set", bson.D{{"avatar", args[1]}}}}
	db.Mongo.Database("im").
		Collection(schema.UserBasic{}.Collection()).
		InsertOne(context.TODO(), update)
```

## 删除
[delete](https://www.mongodb.com/docs/drivers/go/current/fundamentals/crud/write-operations/delete/)