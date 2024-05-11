示例 1: 纯 Golang 项目的部署, 如果需要排除某个文件/目录, 编写`.dockerignore`文件即可, 与`.gitignore`文件格式相同
```Dockerfile
FROM golang:1.21 AS builder
MAINTAINER Lookeke
ENV VERSION 1.0

WORKDIR /app

# 拷贝当前目录下可以执行文件
COPY . .

RUN go env -w GOPROXY=https://proxy.golang.com.cn,direct
# 里要加-tags netgo进行静态编译，否则由于alipne基础镜像缺少必要的动态库，可能会出现类似“no such file or directory"的报错
# 或者直接禁用gcc，然后进行编译
RUN go mod download
RUN go env -w CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -o myapp .

FROM alpine:latest

WORKDIR /app

# 从 builder 镜像中复制 Go 二进制文件到当前镜像中
COPY --from=builder /app/myapp .

# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

# 设置编码
ENV LANG C.UTF-8

# 暴露端口
EXPOSE 4000

# 定义容器启动时运行的命令
ENTRYPOINT ["/app/myapp"]
```


`docker-compose.yml`
```yml
version: '3'

services:
  tiktok:
    image: <image>
    container_name: <container_name>
    restart: always
    ports:
      - "8080:8080"
      - "4000:4000"
    volumes:
      - ./configs:/data/conf
    environment:
      - TZ=Asia/Shanghai
    command: ["/app/<image>", "-conf", "/data/conf"]

```

构建 Docker 镜像
> 将`image`: `web`  # 这里需要替换成你使用 `Docker build`的名字

语法:
```shell
docker build [--progress=plain] [--no-cache] -t <image_name> <path>
```

例: 在当前目录构建所有文件, 镜像名为`web`, 不使用`Docker`缓存, 显示构建过程的详细信息
- --progress=plain: 构建过程中显示的详细信息的格式
- --no-cache : 不使用缓存
- web : 构建的镜像名
- . : 当前目录所有文件
```shell
docker build --progress=plain --no-cache -t goapp .
```

> 如果不在当前目录, 使用选项`-f`

例:
```shell
docker-compose -f ./build/ci/frontent/docker-compose.yml up -d
```


`.dockerignore`
```shell
# Reference https://github.com/github/gitignore/blob/master/Go.gitignore
# Binaries for programs and plugins
*.exe
*.exe~
*.dll
*.dylib

# Test binary, built with `go test -c`
*.test

# Output of the go coverage tool, specifically when used with LiteIDE
*.out

# Dependency directories (remove the comment below to include it)
vendor/

# Go workspace file
go.work

# Compiled Object files, Static and Dynamic libs (Shared Objects)
*.o
*.a
*.so

# OS General
Thumbs.db
.DS_Store

# project
*.cert
*.key
*.log
bin/

# Develop tools
.vscode/
.idea/
*.swp

```

## 延伸

1. 查看镜像大小, 继续缩小容器大小
```shell
docker image history <image_id>
```

2. 尝试使用更极致大小的镜像
- `scratch`, a completely empty base image.  
    `scratch` ，则为完全空的基础映像。
- `[distroless/static-debian](https://github.com/GoogleContainerTools/distroless)`, built on top of scratch, about 2MB in size, including `CA`, `root user`, etc. It is only half the size of `alpine`, and is used by many as the Go base image.  
    `[distroless/static-debian](https://github.com/GoogleContainerTools/distroless)` ，建立在零开始之上，大小约为 2MB，包括 `CA` 、 `root user` 等。它只有 的 `alpine` 一半大小，被许多人用作 Go 基础映像。

## 参考
1. https://betterprogramming.pub/path-to-a-perfect-go-dockerfile-f7fe54b5c78c