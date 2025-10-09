# 定义错误
```protobuf
syntax = "proto3";

package helloworld.v1;

import "errors/errors.proto";

option go_package = "hello/api/helloworld/v1;v1";
option java_multiple_files = true;
option java_package = "helloworld.v1";
option objc_class_prefix = "APIHelloworldV1";

enum ErrorReason {
  option (errors.default_code) = 500;

  GREETER_UNSPECIFIED = 0 [(errors.code) = 400];
  USER_NOT_FOUND = 1 [(errors.code) = 404];
}
```

# 使用错误
```go
package service

import (
	v1 "hello/api/helloworld/v1"
	kerrors "github.com/go-kratos/kratos/v2/errors"
)

func (s *GreeterService) SayHello(ctx context.Context, req *v1.HelloRequest) (*v1.HelloReply, error) {
	if req.Name != "kratos" {
		return nil, kerrors.NotFound(v1.ErrorReason_USER_NOT_FOUND.String(), "用户不存在")
	}

	if req.Name == "" {
		return nil, kerrors.BadRequest(v1.ErrorReason_GREETER_UNSPECIFIED.String(), "名称不能为空")
	}

	g, err := s.uc.CreateGreeter(ctx, &biz.Greeter{Hello: req.Name})
	if err != nil {
		return nil, err
	}

	return &v1.HelloReply{Message: "Hello " + g.Hello}, nil
}
```
# 错误响应
得到了一个很好的错误信息
![[Pasted image 20250828141849.png]]