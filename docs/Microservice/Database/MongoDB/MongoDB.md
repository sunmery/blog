### 连接

##### options:

- retryWrites=true&w=majority 可以重写

## 连接

- 自建服务器

格式:

```shell
mongodb://[<user:password>]@<IP>:<post>/database?[oprions]
```

示例:

```shell
mongodb://root:msd@152.32.186.251:27017/?retryWrites=true&w=majority
```

- MongoDB集群

格式:

```shell
mongodb+srv://root:<password>@<分配给你的数据库>/?[options]
```

示例:

```shell
mongodb+srv://root:msdnm@cluster0.1zprm.mongodb.net/?retryWrites=true&w=majority
```

## 连接到数据库

## 数据库操作

1. 显示所有的数据库

```sql
show dbs
show databases
```

2. 查看当前所在的的数据库

```sql
db
```

3. 创建并使用数据库

```sql
use <database>
```

4. 创建root账户
[参考](https://www.mongodb.com/docs/manual/reference/method/db.createUser/)
```shell
use admin
db.createUser(
	{
		user: 'root',
		pwd: 'admin',
		roles:[ { role: 'root', db: 'admin' } ]
	}
)
```
5. 创建用户
[角色权限参考](https://www.mongodb.com/docs/manual/reference/built-in-roles/#std-label-built-in-roles)
```shell
db.createUser(
	{
		user: '<用户名>',
		pwd: '<密码>',
		roles:[ { role: '<用户名>', db: '<授予的数据库>' } ]
	}
)
```

## 修改Mongodb配置文件
```
docker exec -it <mongo_image> /bin/bash
vi /etc/mongod.conf
```

### 备份数据
语法: 
```shell
mongodump -h dbhost -d dbname -o dbdirectory
```
-   **-h：**
 MongoDB 所在服务器地址，例如：127.0.0.1，当然也可以指定端口号：127.0.0.1:27017
-   **-d：**
需要备份的数据库实例，例如：test
-   **-o：**
备份的数据存放位置，例如：c:\data\dump，当然该目录需要提前建立，在备份完成后，系统自动在dump目录下建立一个test目录，这个目里面存放该数据库实例的备份数据。

```bash
<linux host>:
mkdir -p <back_file_dir>
docker exec -it<mongo_image> /bin/bash

<docker_img>:
mongodump -h 127.0.0.1 --port 27017 -d <db_name> -o <back_dir>
```

### 数据恢复
mongorestore 命令来恢复备份的数据。

语法:
```shell
mongorestore -h <hostname><:port> -d dbname <path>
```

-   **--host:port, -h:port：**
MongoDB所在服务器地址，默认为： localhost:27017

-   **--db, -d：**
 需要恢复的数据库实例，例如：test，当然这个名称也可以和备份时候的不一样，比如test2

-  **--drop：**
 恢复的时候，先删除当前数据，然后恢复备份的数据。就是说，恢复后，备份后添加修改的数据都会被删除，慎用哦！

-   **path：**
> 不能同时指定 path 和 --dir 选项，--dir也可以设置备份目录。
> mongorestore 最后的一个参数，设置备份数据所在位置，例如：c:\data\dump\test。

-   **--dir：**
> 不能同时指定 path 和 --dir 选项

指定备份的目录


8. 删除数据库
```sql
// 进入到要删除的数据库
db.dropDatabase()
```

## 集合(表)操作

- 创建表
  语法

```sql
db.createCollection('<table>',[options])
```

选项
> [options]
> capped:布尔值 固定大小的集合
> size:数值 大小(字节)
> max:数组 最大条数

- 删除表
  语法

```sql
db.<表>.drop()
```

## 增加(插入)insert

- 插入单条数据
  语法:

```sql
db.<集合>.insert({"<key>":"<value>"})

db.<表>.insert([
{"<key1>":"<value1>"},
{"<key2>":"<value2>"}
])
```

- 插入多条数据
  语法:

```sql
db.<集合>.insertMany([ {"<key1>":"<value1>"},
{"<key2>":"<value2>"}, ...])
```

- 脚本操作数据

```sql
for(let i=0;i<10;i++){
	db.<集合>.insert({name:'user'+i })
}
```

## 查询

### 联合查询
在需要联合查询的主表中返回子表, 使用管道`aggregate
`$lookup`: 管道加入一次查找
`form`: 关联的表
`localField`: 本表的字段名
`form`

```
db.college.aggregate([  
{  
	$lookup:{  
		from:"specialty",  
		localField:"name",  
		foreignField:"college",  
		as:"college_list"  
	}  
}  
])
```

```
语法:
db.<表>.find(query,options)

- 全部查询(默认返回前20条),使用`it`查看下一组数据

```sql
db.<表>.find()
```

### 查找数组是否包含某个值
[$in](https://www.mongodb.com/docs/manual/reference/operator/query/in/#mongodb-query-op.-in)
`$in`: 查找数组是否包含某个值
语法: 
```
db.coll.find( `<Arr>`: {  $in : `[query]`  } )
```

- Arr: 数组
- query: 查询的值, 可包含多个

示例:
```sql
db.user_room.insertOne({
 "user_identity":["bc83108c977248daad2f3f815d25cfe5","d22e9e82fab041cc8f8d57d51d6b802d"]
})
db.user_room.findOne({ user_identity : { $in: ["bc83108c977248daad2f3f815d25cfe5"] }})
```

### 模糊查询
  通过JS正则表达式实现

```sql
db.<表>.find({ <字段>: /<模糊查询值>/ })
```

示例:

```sql
--测试数据
db.users.insert({ "_id" : ObjectId("62de51a37c9c74a632447881"), "name" : "n1_6", "age" : 32 },{ "_id" : 6, "name" : "n2_6", "age" : 31 },{ "_id" : 2, "name" : "n2_1", "age" : 18 })

> db.users.find({name:/6/})

-- 返回结果
-> { "_id" : ObjectId("62de51a37c9c74a632447881"), "name" : "n1_6", "age" : 32 }
-> { "_id" : 6, "name" : "n2_6", "age" : 31 }
```

- 返回指定字段
  `1` : 返回该字段
  `0`: 不返回该字段
  语法:

```sql
find({}, {<key1>: <1 | 0>, <key2>: <1 | 0>})
```

> TIP
> `0`与`1`不能同时使用!

示例:
只返回`list`集合的`age`字段,不返回`name`字段

```sql
db.list.find({},{name: 0})
```

### 分页查询
  语法:
  `skip(start)`: 起始位置, 数值
  `limit(pageNum)`: 每页要显示的数据, 数值

示例:
返回排序好的id与name值,并且从第1条数据开始显示10条数据

```sql
dn.list.find().sort({_id:1,name:1}).skip(0).limit(10)
```

### 文档总条数count()
  示例:
  查询`list`文档字段的总条数
[[API设计]]
```sql
db.list.find().count()
db.list.count().find()
```

### 条件查询:

| 条件 | 代码     | 符号表示 |
| ---------------- |--------|------|
| 小于 | \$lt   | \<   |
| 小于或等于 | \$lte  | \<=  |
| 大于 | \$gt   | \>   |
| 大于或等于 | \$gte  | \>=  |
| 不等于 | \$ne   | !=   |
| 等于 | :      | =    |
| 数组长度大于等于 | \$size |      |

### 与查询
  使用`,`分割要查询的条件

```sql
db.<集合>.find(
	{<字段1>: {<条件>: 值1}},
	{<字段2>: {<条件>: 值2}},
	...
)
```

示例:

```sql
db.<集合>.find(
	{age: {$gt: 20}},
	{_id: {$lte: 10}}
)
```

> TIP
> 如果两个字段相同,只会取最后的字段的结果

### 或查询

```
db.<集合>.find(
$or: [
{<字段1>: {<条件>: 值1}},
{<字段2>: {<条件>: 值2}},
\]
...
)
```

示例:

```sql
db.users.find(
	$or: [
		{age: {$gt: 20}},
		{_id: {$lte: 10}}
	\]
	...
)
```

> TIP
> 如果两个字段相同,只会取最后的字段的结果

- 与或条件结合

 ```sql
 db.<集合>.find(
	 {
		 { <字段1>: {<条件>: 值1}, ... },
		 {
			 $or: [
				{<字段1>: {<条件>: 值1}},
				{<字段2>: {<条件>: 值2}},
				...
			\]
		 }
	 }
)
 ```

### 排序sort()
  语法:
  `1`: 升序
  `-1` 降序

```sql
db.<集合>.sort({ <字段1>: 1 | -1,[<字段2>: 1 | -1 ] }).find()
```

### $type
  类型图:
  类型|数字|备注
  Doble|1|数字与浮点数都属于Double
  String|2|字符串
  Object|3|对象
  Array|4|数组
  Binary data|5|二进制数据
  Undefined|6|废弃
  Object id|7|MongoDB自动生成的ID
  Boolean|8|布尔
  Date|9|日期
  Null|10|空
  Regular Expression|11|正则表达式
  Javascript|13|脚本
  Symbol|14|
  Binary data|5
  ---|---|---

![[Pasted image 20220725231633.png]]

语法:

```sql
find(<字段>: {$type: '1'})

find(<字段>: {$type:'double'})
```

### 去重distinct()
  语法:

```sql
db.<集合>.distinct(<字段>)
```

返回值: 数组形式的不重复项

显示user集合的age重复的项

```sql
db.users.distinct('age')
```

### 数据过长时格式化

```sql
db.<集合>.find().pretty()
```

## 更新update()

### 更新

**语法**:
```sql
db.<表>.update(
	<query>,
	<update>,
	{
		multi: 多个匹配.默认flase,只匹配第一个数据
		upsert: 查询条件不匹配时是否插入,默认flase
	}
)
```

### 更新数组某个字段的值
参数:
1. coll: 文档名(表名)
2. Array: 数组名
3. Item: 数组的字段(属性)
4. Query:  数组的字段值(属性值)
5. Value: 新的值
6. options: 可选
7. $set(): 保留原格式
语法: 
```sql
db.<coll>.update({'<Array>.<Item>':<Query>},{[options]:{'<Array>.$.<Item>':<Value>}})
```

示例: 更新单个`routes`表的`items`数组中的`label`字段的值`教室管理`为`教师管理`,并保留原格式
```sql
db.routes.updateOne({'items.label':'教室管理'},{$set:{'items.$.label':'教师管理'}})
```

### 更新某个字段值
例子1:将所有年龄为21的字段更新为23

```sql
db.users.update(
	{age:21},
	{$set:{age:23}},
	{ multi:true }
)
```

**例子2**: 批量更新字段名
```sql
db.course.updateMany(
	{},
	{ $rename: { schedule: 'schedule1'} }
)
```

### 对原有数据插入新字段与值

**关键字**:`$set:{key:value}` 保持原有数据进行插入或更新

例子1:

对`user`文档字段`user`为`lookeke`的字段进行新增字段`thumbUp`值为`17`

```sql
db.pins.updateOne({user:'lookeke'},{$set:{thumbUp:17}})
```

例子2:

对所有文档字段进行新增字段`thumbUp`值为`17`

```sql
db.pins.updateMany({},{$set:{thumbUp:17}})
```

### 对数据添加新数据
`$push`向数组末尾添加新数据
语法:
```sql
db.coll.update({ <query> }, { $push: { <arrayName>: { foild1: value1,foildN: valueN } } })
```

示例: 对`routes`文档`role`为`teacher`的`items`数组末尾添加新数据:`path: "\/ws/chat", label: "即时通讯"`
```sql
db.routes.updateOne(
	{ role: 'teacher'},
	{ $push: {
		items:{
		  path: "\/ws/chat", // /为特殊字符, 需要使用\符号转义
		  label: "即时通讯"
		}
	}
})
```

### 如果查询的值没有, 则插入
upsert
true: 如果查询的值没有, 则插入
false: 不插入, 默认值

语法:
```sql
db.users.updateOne({query},{update},{upsert:true})
```

### 修改字段名

**关键字**: `$rename`
**语法**:
```sql
db.<集合>.update({},{
	$rename:{'<旧字段名>':'<新字段名>'}
})
```

例子:
```sql
db.course.update({},{
	$rename:{'className':'class_name'}
})
```

## 删除
1. deleteMany() 删除所有符合查询条件的数据
2. deleteOne() 删除第一个符合查询条件的数据

#### 删除数组某个字段与字段的值
**$pull** [从文档数组中删除元素](https://www.delftstack.com/zh/howto/mongodb/mongodb-remove-element-from-array/#%25E4%25BD%25BF%25E7%2594%25A8-mongodb-pull-%25E4%25BB%258E%25E6%2596%2587%25E6%25A1%25A3%25E6%2595%25B0%25E7%25BB%2584%25E4%25B8%25AD%25E5%2588%25A0%25E9%2599%25A4%25E5%2585%2583%25E7%25B4%25A0)
语法:
1. Query： 查询条件
2. key： 数组的字段（属性）
3. value： 数组的字段（属性）值
```sql
db.coll.update(<Query>,{$pull:{ <key>: <value> }})
```

例1: 从`routes`文档中删除所有`items`数组中的`label`字段为`登录`的字段值（属性值）
```sql
db.routes.updateMany({},{$pull:{'items':{"label":'登录'}}})
```

例2：搜索`_id`等于`ObjectId("62aae796f27219958a489b89")`的文档。一旦文档符合指定条件，我们就从现有数组中删除实例，其中`contact.phone.number`等于`987546321`
```sql
db.collection.update(
    { _id : ObjectId("62aae796f27219958a489b89") },
    { $pull : { "contact.phone": { "number": "987546321" } } }
)
```

```sql
db.<集合>.remove(
<删除条件>,
	{
		justOne:默认为false,删除匹配的文档,反则只删除一个文档,
		writeConcern: 异常级别
	}
)
```

### 删除数据库
dropDatabase()
```sql
db.dropDatabase()
```

### 删除表:
drop()
```shell
db.<表>.drop()
```

### 删除字段重复数据:
参考: [CSDN](https://blog.csdn.net/weixin_41501074/article/details/105234814?utm_medium=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param&depth_1-utm_source=distribute.pc_relevant.none-task-blog-BlogCommendFromMachineLearnPai2-1.channel_param)
- [$group](https://www.mongodb.com/docs/manual/reference/operator/aggregation/group/#mongodb-pipeline-pipe.-group) 查询条件.阶段根据“组键”将文档分为组。每个唯一组键对应一个文档。 组键通常是一个字段或一组字段。组键也可以是表达式的结果。
```sql
{
  $group:
    {
      _id: <expression>, // Group key
      <field1>: { <accumulator1> : <expression1> },
      ...
    }
 }
```
- [$sum](https://www.mongodb.com/docs/v6.0/reference/operator/aggregation/sum/) 计算并返回数值的集合和($:忽略非数值值)
- $match 过滤
- $addToSet 将聚合的数据id放入到dups数组中方便后面使用
- shift() 剔除队列中第一条id 避免删掉所有的数据；

查询结果使用forEach进行迭代id来删除数据

```sql
db.<集合>.aggregate([
	{$group:{_id:{字段1:'$字段1',字段2:'$字段2',字段3:'$字段3'},
	count:{$sum:1},
	dups:{$addToSet:'$_id'}}},
	{$match:{count:{$gt:1}}}
],{allowDiskUse:true}).forEach(function(doc){
	doc.dups.shift()
	db.getCollection('ratings').remove({
		_id:{
			$in: doc.dups
		}
	})
})
```

### 删除字段名

**关键字**:`$unset`
语法:
```sql
db.<集合>.update(
	{ <query> },
	{ $unset: { '<要删除的字段>' :'<该字段值>' } }
)
```

例子: 删除`className`字段
1. 找到`className`
2. 删除
```sql
db.course.update({className:'计科196'},{
	$unset:{'className':'计科196'}
})
```

## 日期
Unix:
```
 Date.now()
```

## 索引

目的: 为经常访问的数据建立索引,减少访问时遍历的时候从头到尾访问
创建索引

```sql
db.<集合>.createIndex({<字段>})
```
