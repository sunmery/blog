1. 编写`Dockerfile`

```Dockerfile
FROM golang:alpine AS builder
MAINTAINER Lookeke
ENV VERSION 1.0

WORKDIR /app

# 拷贝当前目录下可以执行文件
COPY . .

RUN go env -w GOPROXY=https://proxy.golang.com.cn,direct

# 里要加-tags netgo进行静态编译，否则由于alipne基础镜像缺少必要的动态库，可能会出现类似“no such file or directory"的报错
# 或者直接禁用gcc，然后进行编译
RUN mkdir -p /app/bin
# # pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change

RUN go mod download && go mod verify
RUN go env -w CGO_ENABLED=0 GOOS=linux GOARCH=amd64 && go build -o /app/bin/ ./...

#FROM alpine:latest
FROM scratch

WORKDIR /app

# 从 builder 镜像中复制 Go 二进制文件到当前镜像中
COPY --from=builder /app/bin .

# 暴露端口
EXPOSE 30001 30002

# 定义容器启动时运行的命令
ENTRYPOINT ["/app/user", "-conf", "/data/conf"]
```

或者: alpine

```Dockerfile
#FROM golang:1.21 AS builder
FROM golang:alpine AS builder
MAINTAINER Lookeke
ENV VERSION 1.0

WORKDIR /app

# 拷贝当前目录下可以执行文件
COPY . .

RUN go env -w GOPROXY=https://proxy.golang.com.cn,direct
# 里要加-tags netgo进行静态编译，否则由于alipne基础镜像缺少必要的动态库，可能会出现类似“no such file or directory"的报错
# 或者直接禁用gcc，然后进行编译

RUN mkdir -p /app/bin

# pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
RUN go mod download && go mod verify
RUN go env -w CGO_ENABLED=0 GOOS=linux GOARCH=amd64 && go build -o /app/bin/ ./...

RUN ls /app
RUN ls /app/bin

FROM alpine:latest

WORKDIR /app

# 从 builder 镜像中复制 Go 二进制文件到当前镜像中

COPY --from=builder /app/bin .

# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

# 设置编码
ENV LANG C.UTF-8

# 暴露端口
EXPOSE 30001 30002

# 定义容器启动时运行的命令
ENTRYPOINT ["/app/user", "-conf", "/data/conf"]

```

2. 打包
   在项目的根目录执行以下脚本

> 如果项目共用一个 go.mod 模块文件, 能够得到完好支持

> `Docker build` 执行时的上下文环境是依据当前执行的目录为主目录, 并非 `Dockerfile` 的目录, 例如当前目录为`/app`,
`Dockerfile` 所在的目录是`/app/user/`,执行时是使用`/app`作为主目录, 而不是 `Dockerfile` 的目录


> Docker的新版已经删除--progress=plain, 如果遇到--progress=plain的错误, 删掉即可

```shell
docker build -f <Dockerfile-path> --progress=plain --no-cache -t <image-name> .
```

3. 编写`docker-compose.yaml`

```yaml
version: '3'

services:
  tiktok-user:
    image: docker.io/library/tiktok-user
    container_name: tiktok-user
    restart: unless-stopped
    ports:
      - "30001:30001"
      - "30002:30002"
    volumes:
      - ./configs/:/data/conf/
    command: [ "/app/user", "-conf", "/data/conf" ]

```

4. 执行

```shell
docker-compose -f <docker-compose.yml-path> up -d
```

5. 登录私有仓库或公有仓库, 这里演示私有仓库harbor

> 如果是自签名证书:
>

```shell
export user="admin"
export password="Harbor12345"
export addr="https://192.168.2.152:30003"

docker login -u $user -p $password $addr
```

7. 推送

```shell
export repo="192.168.2.152:30003/go"
export image="otel-gin"
export version="v1"

docker tag $image $repo/$image:$version
docker push $repo/$image:$version
```

## 常见问题

1. 时区: 在`alpine`很常见, 需要手动安装时区数据库
2. 文件丢失: 请确认配置文件和目录是否存在, 在使用 `scp`命令中出现文件丢失概率大, 请使用`tar`压缩上传方式或自行探索更优方式,
   减少丢失文件的可能

## 参考

1. https://betterprogramming.pub/path-to-a-perfect-go-dockerfile-f7fe54b5c78c
