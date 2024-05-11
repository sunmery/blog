1. 使用oneof关键字处理可选字段
定义了一个可选的name字段
```protobuf
message User {
	oneof user_info {
		string name = 1;
	}
}
```

2. 使用包装类型
例如`google.protobuf.Int32Value`, `google.protobuf.StringValue`等, 将这些可选字段定义为包装类型, 如果字段为空, 那么保证类型的实例也是空

```protobuf
message User {
	oneof user_info {
		google.protobuf.StringValue name = 1;
	}
}
```

3. 使用默认值处理Null值
```protobuf
message User {
	oneof user_info {
		google.protobuf.StringValue name = 1 [default = ""];
	}
}
```