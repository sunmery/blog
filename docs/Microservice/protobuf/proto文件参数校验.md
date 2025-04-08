## [文档](https://github.com/bufbuild/protovalidate-go)

1. 安装
   `go 版本`

```shell
go get github.com/bufbuild/protovalidate-go
```

2. 使用

```protobuf
syntax = "proto3";

package my.package;

import "validate/validate.proto";

message Person {
  uint64 id = 1 [(validate.rules).uint64.gt = 999];

  string email = 2 [(validate.rules).string.email = true];

  string name = 3 [(validate.rules).string = {
    pattern:   "^[A-Za-z]+( [A-Za-z]+)*$",
    max_bytes: 256,
  }];

  Location home = 4 [(validate.rules).message.required = true];

  message Location {
    double lat = 1 [(validate.rules).double = {gte: -90,  lte: 90}];
    double lng = 2 [(validate.rules).double = {gte: -180, lte: 180}];
  }
}
```
