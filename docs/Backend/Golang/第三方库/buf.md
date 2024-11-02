## 介绍
Buf CLI 是现代、快速和高效的 Protobuf API 管理的终极工具。Buf 具有格式化、linting、中断更改检测和代码生成等功能

## 安装
```
brew install bufbuild/buf/buf
buf --version
```

### 生成代码
```
buf generate <dir>
```

`buf.yaml`:
```yaml
version: v1
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
```

`buf.gen.yaml`:
```yaml
version: v1
managed:
  enabled: true
  go_package_prefix:
    default: github.com/bufbuild/buf-tour/gen
plugins:
  - plugin: buf.build/protocolbuffers/go
    out: gen
    opt: paths=source_relative
  - plugin: buf.build/connectrpc/go
    out: gen
    opt: paths=source_relative

```

example:
```
proto
    ├── buf.yaml
    ├── google
    │   └── type
    │       └── datetime.proto
    └── pet
        └── v1
            └── pet.proto
```

```shell
buf generate proto
```

## Lint
### 规则
全部规则: https://buf.build/docs/lint/rules

使用默认规则:
```yaml
version: v1
breaking:
  use:
    - FILE
lint:
  use:
    - DEFAULT
```

使用最小规则集:
```shell
buf lint --error-format=config-ignore-yaml
```

lint:
```shell
buf lint <dir>
```

### 忽略
要忽略的文件的路径是以`buf.gen.yaml`为根目录

`buf.gen.yaml`
```yaml
lint:
  use:
    - DEFAULT
  ignore:
	- <filepath>
```

## 类型检查
验证这是否是针对本地 `main` 分支的重大更改
```shell
buf breaking proto --against "../../.git#subdir=start/getting-started-with-buf-cli/proto"
```

## 调试RPC

server:
```go
package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	connect "connectrpc.com/connect"

	petv1 "github.com/bufbuild/buf-tour/gen/pet/v1"
	"github.com/bufbuild/buf-tour/gen/pet/v1/petv1connect"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

const address = "localhost:8080"

func main() {
	mux := http.NewServeMux()
	path, handler := petv1connect.NewPetStoreServiceHandler(&petStoreServiceServer{})
	mux.Handle(path, handler)
	fmt.Println("... Listening on", address)
	http.ListenAndServe(
		address,
		// Use h2c so we can serve HTTP/2 without TLS.
		h2c.NewHandler(mux, &http2.Server{}),
	)
}

// petStoreServiceServer implements the PetStoreService API.
type petStoreServiceServer struct {
	petv1connect.UnimplementedPetStoreServiceHandler
}

// PutPet adds the pet associated with the given request into the PetStore.
func (s *petStoreServiceServer) PutPet(
	ctx context.Context,
	req *connect.Request[petv1.PutPetRequest],
) (*connect.Response[petv1.PutPetResponse], error) {
	name := req.Msg.GetName()
	petType := req.Msg.GetPetType()
	log.Printf("Got a request to create a %v named %s", petType, name)
	return connect.NewResponse(&petv1.PutPetResponse{}), nil
}

```

访问proto:
```shell
buf curl \
  --schema proto \
  --data '{"pet_type": "PET_TYPE_SNAKE", "name": "Ekans"}' \
  http://localhost:8080/pet.v1.PetStoreService/PutPet
```