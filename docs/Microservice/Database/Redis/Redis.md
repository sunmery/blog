[文档](https://github.com/fangdevelop/note/blob/main/db/redis%E5%85%A5%E9%97%A8%E8%AE%B0.pdf)
type 查看类型

## 哈希/散列
哈希名 - 字段 - 值 

### 设置
- 直接设置,如果有原来有这个key就覆盖
```
hset hash key1 value1 [key2 value2 ...]
```
- 不存在则添加一对键值对
```
hsetnx hash key value
```

### 获取
- 获取单个value值
```
hget hash field1
```

- 获取多个value值
```
hmget hash field1 [field2]
```

- 获取全部key
```
hkeys hash
```

- 获取全部values
```
hvals hash
```

- 获取全部(key与value
```
hgetall hash
```

### 查找

检查一个哈希表的字段是否存在
```
hexists hash field
```

检查一个哈希表的长度
```
hlen hash
```

检查一个字段值的长度
```
hstrlen hash field
```

例子:
```
hset hash1 k1 abc
hstrlen hash k1 
-> 3
```

### 增加
- 自增自定义数
	- 数字
	```
	hincrby hash field number
	```
	
	 - 浮点数
	```
	hincybyfloat hash field number
	```

### 删除
- 全部删除
```
del hash
```
- 删除哈希键值对
```
hdel hash field1 [field2]
```

## 生存时间
expire: 单位`s`
pexpire: 单位`ms`
语法
```
expire `<key>` `<time>`
pexpire` <key>` `<time>`
```

检查生存时间剩余时间
返回值:
- number 剩余时间
- -1 非生存时间/永久键值对
- -2 key不存在
```
ttl key
```

## 字符串String 

设置键值对与生存时间

设置秒: setex / set `<key>` `<value>` ex `<time>` 
```
setex key time value
ste key value ex time 
```

设置毫秒: psetex / set `<key>` `<value>` px `<time>`
```
psetex key time value 
set key value px time
```

getset/set `<key>` `<value>` get: 修改已有的值并返回原来的值
```
set k7 k7
getset k7 k71 / set k7 k71 get
-> k7
```

nx/setnx: key不存在时添加
语法
```
set key value nx
setnx ket value 
```
xx: key存在时修改
```
set key value xx
```

重新设置时不重置生存时间
set key value keepttl
示例:
```
set k1 v1 ex 30
set k1 v11
ttl k1
-> 去除生存时间, 返回 -1

set k1 v1 ex 30
set k1 v11 keepttl
ttl k1
-> 剩余时间
```

截取
语法
```
getrange key satrtIndex endIndex
```
示例
```
set key1 a1b2c3
getrange key 1 -2
-> 1b2c
```

设置单个键值对
语法
```
set <key> <value>
```
获取单个键值对
语法
```
get <key1> <value1> [key2 value2 keyN valueN]
```

设置多个键值对
语法
```
mset <key1> <value1> [key2 value2 keyN valueN]
```

获取多个键值对
语法
```
mget <key1> <value1> [key2 value2 keyN valueN]
```

检索一个键是否存在
语法
```
exists <key>
```
返回值
1: 存在
0: 不存在

删除
```
del <key>
```

### 整数字符串
### 增加
- 自增
```
incr <key>
```

- 添加自定义
	- 整数 incyby

		```
		incyby key value
		```

	- 浮点数 incybyfloat
		```
		incyby key value
		```

示例:
```
set n1 1
incrby n1 100
get n1
-> 101
```

### 减少
- 自减
```
decr key
```

- 减去自定义数字
```
decyby key value
```

## 队列List
一个key跟着多个value
`队列名`-`value1`-`[valueN]`

### 添加
lpushx: 如果列表存在, 向列表左侧添加新的value
```
rpush l1 1 2 3 4 5
lpushx l1 0 1
-> 0 1 1 2 3 4 5
```

rpushx: 如果列表存在, 向列表右侧添加新的value
```
rpush l1 1 2 3 4 5
rpushx l1 0 1
-> 1 2 3 4 5 0 1
```

lpush: 左侧value先进, 获取时是队列末尾value先出
```
lpush l1 1 2 3 4 5
lrang l1
-> 5 4 3 2 1
```

rpush: 右侧value先进, 获取时是队列首位value先出
```
lpush l1 1 2 3 4 5
lrang l1
-> 1 2 3 4 5
```

### 查询
- 根据索引查找值
```
lindex list index
```

示例: 
```
lpush l1 1 2 3 4 5
lindex l1 1
-> 2
```

- 查询队列长度
```
llen list
```

### 修改

- 截取
```
ltrim list startIndex endIndex
```

示例: 从第2位`1`截取到倒数第二位`3`
```
rpush l6  0 1 2 3 4
ltrim l6 1 -2
lrange l6 0 -1

-> 1 2 3
```

- 替换
语法
```
lset list index value
```

示例: 修改第1个的值为11
```
lpush l1 1 2 3 4 5
lset l1 0 11
lrange l1
-> 11 2 3 4 5
```

- 插入
语法:
- before 之前
- after 之后
- value 列表值, 作为`after`/`before`插入的相对位置
- newValue 插入的值
```
linsert list after/before value newValue
```

示例: 在`l4`列表的`2`之前插入`1`
```
rpush l4 0 2 3 4
linsert l4 before 2 1
lrange l4 0 -1
-> 0 1 2 3 4
```

### 弹出
- 删除首位
lpop: 左侧value先进, 删除时是队列末尾value先出
```
rpush l1 1 2 3 4 5
lpop l1
-> 1
```

- 删除末位
rpop: 左侧value先进, 删除时是队列首位value先出
```
rpush l1 1 2 3 4 5
rpop l1
-> 5
```

- 删除指定值
```
lrem list number value
```

示例: 删除 `l5`的value值为`1`的`1`个值
```
rpush l5  0 1 2 3 4
lrem l5 1 1
lrange l5 0 -1
-> 0 2 3 4
```

## 集合Set


### 查询
- 是否存在指定成员
如果是多个value, 返回值为0或1,0不存在,1存在
```
smismember set value [value N]
```

随机查询
```
srandmember s1 [number]
```

- 获取集合成员数
```
scard set
```

### 添加
```
sadd set value1 ...
```

### 修改

#### 移动
```
somve set1 set2 value
```

示例: 向`s2`移动
```
sadd s1 0 1 2
smove s1 s2 1
smismember s2 1

-> true
```

返回给定所有集合的差集
```
SDIFF key1 [key2]
``` 

返回给定所有集合的差集并存储在 destination 中
```
SDIFFSTORE destination key1 [key2]
```

返回给定所有集合的交集
```
SINTER key1 [key2]
```

返回给定所有集合的交集并存储在 destination 中
```
SINTERSTORE destination key1 [key2]
```

返回所有给定集合的并集
```
SUNION key1 [key2]
```

所有给定集合的并集存储在 destination 集合中
```
SUNIONSTORE destination key1 [key2]
```

### 删除
```
srem set value1 ...
```

- 随机删除
```
spop set [number]
```


## 数据库操作
flushdb