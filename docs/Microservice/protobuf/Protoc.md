
## 简介

`protoc` 是 `google` 官方的编译器,将 `protobuf` 协议转成对应语言可识别的语法. 支持多种后端语言, 官方支持 Java, C/C++,Go等等

## 使用
以`Go`为例, 官方支持的 Go语言的编译器为`protoc-gen-go`将 protobuf 生成为 go 语言可识别的协议

> 目录必须提前创建

语法:
```shell
protoc -I=<input_dir> --go_out=<out_dir> <input_file> [--go_opt=<options>]
```

-I : 要导入的目录, `.`为当前目录
paths: 路径选项
	- import: 根据 package 作为路径,默认值
- --go_out:
	- `<out_dir>: 将生成的 `proto.pb` 文件保存的目录路径
	- `<input_file>` : 需要生成的文件

示例1: 
将当前目录所有的`.proto`文件生成到当前的目录下
```shell
protoc -I=. --go_out=. */*.proto
```

示例 2:
将生成的`proto`文件保存到`proto`文件所在的文件夹
```shell
protoc -I=. --go_out=. --go_opt=paths=source_relative */*.proto
```

示例1完整示例:

1. init go 项目
```shell
go init example.com/project
```

2. 编写`proto`文件,其中定义了生成之后的目录是`user`, 由`go_package`控制, 格式为`项目路径+包路径`
```protobuf
syntax = "proto3";

package users;
option go_package = "proto/user";

message Request {
  string username = 1;
  string password = 2;
}

message Response {
  int32 state_code =1;
  string state_msg = 2;
}

enum Gender {
  SEX = 0;
  MAN =1;
  WOMEN = 2;
}

message User {
  string name = 1;
  int32 age = 2;
  Gender gender = 3;
}
```

3. 生成文件
```shell
protoc -I=. --go_out=. */*.proto
```

执行以上的代码之后的项目目录结构为:
```
.
├── go.mod
├── go.sum
├── main.go
├── proto
│   └── user
│       └── user.pb.go
└── protobuf
    └── user.proto
```