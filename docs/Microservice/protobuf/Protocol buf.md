## 介绍
将数据存储为字节的二进制文件,并在支持的语言中进行解析

适应场景:
1. 频繁的接发, 例如游戏
2. 对高性能有要求的
3. 无关语言的

缺点:
1. 如果需要对两个文件比较, 必须全部读取完文件
2. 消息不会压缩
3. 几兆以上的数据文件解析性能很差
## 导入

从其他 `protoc` 导入
```proto
import "xx.proto"
```
## 数据类型

枚举:
[FOO_UNSPECIFIED](https://protobuf.dev/programming-guides/dos-donts/)
```protobuf
enum Gender {
	FOO_UNSPECIFIED = 0; 默认值, 最佳实践是使用FOO_UNSPECIFIED作为第一个值. 旧客户端将看到该字段未设置
}
```

### 标量类型
| protobuf类型        | 对应的go类型                | 说明                     | 备注                                                     |
|-------------------|------------------------|------------------------|--------------------------------------------------------|
| string            | string                 | 字符串                    | 必须始终包含 UTF-8 编码或 7 位 ASCII 文本，并且不能超过 232               |
| double            | float64                | 双精度浮点数                 |                                                        |                               
| float             | float32                | 单精度浮点数                 |                                                        |                                    
| int32             | int32                  | 可变长度的编码。               | 对负数的编码效率低下如果字段可能包含负值，改用 sint32                         |            
| int64             | int64                  | 可变长度                   |                                                        ||
| bool              | bool                   |                        |                                                        |
| uint32            | uint32                 |                        |                                                        |
| uint64            | uint64                 |                        |                                                        |
| sint32            | uint32                 | 可变长度编码, 有符号整数          | 比常规int32更有效编码负数                                        |
| sint64            | uint64                 | 变长度编码, 有符号整数           | 比常规int64更有效编码负数                                        |
| fixed32           | uint32                 | 4 字节存储, 值大于 2          | 如果值通常大于 2^28，则比 uint32 更有效 .对应go 的 uint32              |
| fixed64           | uint64                 | 8 字节存储, 值大于 2          | 如果值通常大于 2^28，则比 uint64 更有效 .对应go 的 uint64              |
| sfixed32          | 始终为4个字节              | |                                                        |                                         
| sfixed64          | 始终为8个字节                |                        |                                                        |                                               
| bytes             | byte                   | 可以包含任何不超过2的32次方的任意字节序列 |                                                        |                               
| Color             | 颜色值                    |                        |                                                        |                                             
| repeated          | 切片/数组                  |                        |                                             
| Timestamp         | 2017-01-15T01:30:15.01Z. | 时间点                    |
| Interval          | 时间差                    |                        | 示例: 2017-01-15T01:30:15.01Z - 2017-01-16T02:30:15.01Z. |
| Date              |                        | 日期                     |
| DayOfWeek         |                        | 一周某一天                  | 示例:Monday                                              |
| TimeOfDay|                        | 一天的某时分秒                |                                                        |10:20:30|

### 复合类型
1. Message
	1. optional
	2. repeated: 重复
	3. map KV 字段

2. enum 从 0 开始, 第一个枚举值必须是 0 值, 做数字默认值, 为了兼容 protoc2
```proto
enmu Lists {
	ALL_DEFAULT = 0;
	
}
```

### 字段类型

reserved: 删除字段时的编号存储在此字段
`9 to 11`: 即 9 到 11,. 9, 10, 11 这三个编号 
```proto
message Foo {
	reserved 2, 9 to 11;
	reserved "foo", "bar";
}
```

## 定义服务

使用关键字`service`定义一个服务
`rpc`: RPC 服务
格式:
```proto
service SearchService {
	rpc Search(SearchRequest) returns (SearchResponse)
}
```

