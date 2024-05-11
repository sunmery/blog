[文档](https://github.com/bufbuild/protovalidate-go)
 1. 安装
`go 版本`
```shell
go get github.com/bufbuild/protovalidate-go
```
2. 使用
```protobuf
syntax = "proto3";

package my.package;

import "buf/validate/validate.proto";
```