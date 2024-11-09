跳过网络下载,
例如:
```yml
services:

  api:
    build:
      context: .
      dockerfile: Dockerfile
      # 环境变量: 与Dockerfile中的ARG字段相同
      args:
        VERSION: pre
        CGOENABLED: 0
        GOOS: linux
        GOARCH: arm64
        GOIMAGE: golang:1.23.3-alpine3.20
        REPOSITORY: "lisa/backend"
        HTTP_PORT: 30001
        GRPC_PORT: 30002
    # image: ccr.ccs.tencentyun.com/lisa/backend:dev2
    image: team/backend:pre1
```

docker首先会尝试从网络查找image的值, 如果查询失败, 才会从build构建, 其中超时时间默认是1分钟, 这可以从docker的配置文件配置, 但也可以命令行来跳过下载, 这建议在预发布或者测试环境使用,生产环境使用image, 而不是build

```bash
docker compose -f compose-pre.yml up --no-pull
```