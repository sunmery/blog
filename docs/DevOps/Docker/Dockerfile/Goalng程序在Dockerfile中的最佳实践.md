# 最佳实践

1. 下载依赖项作为一个单独的步骤来利用Docker的缓存。
2. 利用缓存挂载到/go/pkg/mod/来加快后续构建。
3. 利用绑定挂载（bind mounts）来引入go.sum和go.mod文件，而不是将这些文件复制到容器中。
4. 这样做可以减少构建时的数据复制操作，加快构建速度，并确保容器中的文件总是与宿主机上的文件同步
5. 这意味着在这个目录下的所有文件都会被缓存，即使在多次构建容器会被销毁。
6. 缓存Go模块，避免在每次构建时都需要重新下载，从而加速构建过程
7. 多阶段构建：首先使用一个包含 Golang 编译环境的较大镜像进行构建，然后在第二个阶段使用轻量级的 Alpine Linux
   镜像运行应用。这样做可以显著减小最终镜像的体积，提高运行时效率
8. 跨平台构建, 一次部署即可编译构建多个平台架构的软件包

## Docker 层缓存机制原理

docker的每个指令 都是一个分层 如果有任何一层的的代码有改动, 那么往下执行的代码也会重建, 即不会保留缓存

## 定义Dockerfile解析器的版本

用于AST的解析器规则, 实验版本包含未经过长期验证, 但包含新的特性

### 稳定版本

1. `syntax=docker/dockerfile:1`, 表示使用最新的 1.x.x和补丁版本进行更新
3. `docker/dockerfile:1.2`: 使用最新的 1.2.x 补丁版本保持更新，并在版本 1.3.0 发布后停止接收更新。
5. `docker/dockerfile:1.2.1`; 固定版本

### 实验版本

1. docker/dockerfile:labs - 频道上的 labs 最新版本。
2. docker/dockerfile:1-labs - 与 dockerfile:1 相同，并启用了实验性功能。
3. docker/dockerfile:1.2-labs - 与 dockerfile:1.2 相同，并启用了实验性功能。
4. docker/dockerfile:1.2.1-labs - 不可变：从不更新。与 dockerfile:1.2.1 相同，并启用了实验性功能。

## 打包应用

- 单个包打包:

```Dockerfile
go build -o /bin/main .
```

- 带版本的二进制文件:

```Dockerfile
go build -ldflags="-X main.Version=${VERSION}" -o /bin/main .
```

- 多个二进制文件的形式:

```Dockerfile
go build -ldflags="-X main.Version=${VERSION}" -o /bin/ ./...
```

## 环境变量:

### 注意事项

设置ARG变量只能在当前的层使用

例如:

```Dockerfile
# 当前层
ARG GO_IMAGE=golang:1.23.1-alpine3.20
ARG GO_PROXY=https://proxy.golang.com.cn,direct

FROM --platform=$BUILDPLATFORM ${GO_IMAGE} AS build

# 非GO_PROXY所在的层, 无法获取`GOPROXY`环境变量
RUN go env -w GOPROXY="$GO_PROXY"
```

docker运行时会无法获取`GOPROXY`环境变量:

```
#10 [build 4/7] RUN go env -w GOPROXY="$GO_PROXY"
#10 CACHED

#11 [build 5/7] RUN --mount=type=cache,target=/go/pkg/mod/     --mount=type=bind,source=go.sum,target=go.sum     --mount=type=bind,source=go.mod,target=go.mod     go mod download -x
#11 0.093 go: GOPROXY list is not the empty string, but contains no entries
```

正确的方法:

```Dockerfile
# 定义基础镜像的 Golang 版本
ARG GO_IMAGE=golang:1.23.1-alpine3.20

FROM --platform=$BUILDPLATFORM ${GO_IMAGE} AS build
WORKDIR /src

# Go的环境变量, 例如alpine镜像不内置gcc,则关闭CGO很有效
ARG GO_PROXY=https://proxy.golang.com.cn,direct

# 设置环境变量
# RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go env -w GOPROXY="$GO_PROXY"
```

## 使用

定义默认值

```Dockerfile
# 定义基础镜像的 Golang 版本
ARG GO_IMAGE=golang:1.23.1-alpine3.20

FROM --platform=$BUILDPLATFORM ${GO_IMAGE} AS build
WORKDIR /src

# Go的环境变量, 例如alpine镜像不内置gcc,则关闭CGO很有效
ARG GO_PROXY=https://proxy.golang.com.cn,direct

# 设置环境变量
# RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go env -w GOPROXY="$GO_PROXY"
```

传递环境变量, 替换Dockerfile的内置变量:
使用`--build-arg`属性

```Dockerfile
export version=v2.0.0
export repository="lisa/backend"
docker build \
  --progress=plain \
  -t $repository:$version . \
  --build-arg CGO_ENABLED=0 \
  --build-arg GO_IMAGE=golang:1.23.1-alpine3.20 \
  --build-arg version=$version \
  --build-arg PORT=8080
```

## 利用 Docker 层缓存机制

利用 Docker 层缓存机制，单独下载依赖项，提高后续构建速度。
使用缓存挂载和绑定挂载技术，避免不必要的文件复制到容器中。

```Dockerfile
RUN VERSION=$(git describe --tags --always) || true
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=. \
    CGO_ENABLED=$CGO_ENABLED \
```

## 依赖项选择

当你选择一个依赖时, 如果没有特别的要求, 最佳的选择就是选择该依赖的带有`alpine`的`tag`
alpine即: Alpine Linux

主要优点：

1. **轻量级**：

    - **体积小**：Alpine Linux 的基础镜像非常小，通常只有几兆字节。这使得它非常适合用于构建小型的 Docker 镜像，减少了存储和传输的成本。
    - **启动快**：由于体积小，启动速度非常快，适合快速启动和停止的 CI/CD 环境。
2. **安全性**：

    - **面向安全**：Alpine Linux 使用了一些安全特性，如 grsec/PaX 内核补丁和堆栈保护，提供了额外的安全保障。
    - **少代码**：由于其精简的设计，Alpine Linux 的攻击面较小，减少了潜在的安全漏洞。
3. **资源利用效率高**：

    - **低内存占用**：Alpine Linux 的内存占用非常低，适合在资源受限的环境中运行。
    - **低 CPU 占用**：启动和运行时的 CPU 占用率低，有助于提高 CI/CD 管道的整体效率。
4. **易于管理和维护**：

    - **简单的包管理系统**：Alpine Linux 使用`apk`包管理系统，简单且高效，易于管理和维护。
    - **文档丰富**：社区活跃，文档丰富，遇到问题时容易找到解决方案。
5. **兼容性好**：

    - **广泛支持**：许多开源项目和工具都有针对 Alpine Linux 的支持和优化。
    - **跨平台**：可以用于多种架构，如 x86、ARM 等

### 示例

1. 使用`alpine`操作系统,不到5Mb的大小的操作系统, 大幅缩减操作系统镜像带来的额外存储空间:

```Dockerfile
FROM alpine:latest AS final

# 用户进程ID
ARG UID=10001

# 后端程序的HTTP/gRPC端口
ARG PORT=8080

# 修改镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# 安装应用运行必需的系统证书和时区数据包
# RUN --mount=type=cache,target=/var/cache/apk \
#    apk --update add ca-certificates tzdata && update-ca-certificates

# 创建一个非特权用户来运行应用，增强容器安全性
RUN adduser --disabled-password --gecos "" --home "/nonexistent" --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser

# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

USER appuser

# 从构建阶段复制编译好的 Go 应用程序到运行阶段
COPY --from=build /bin/main /bin/

# 复制配置文件
COPY app.env .

# 指定容器对外暴露的端口号
EXPOSE $PORT

# 设置容器启动时执行的命令
CMD ["/bin/main"]
```

2. 还可以继续进一步缩减镜像大小, 如果应用程序没有其它额外的操作:

- 使用`scratch`特殊变量, 仅包含应用的二进制文件, 极致的空间利用率

```
FROM scratch AS final

# 后端程序的HTTP/gRPC端口
ARG PORT=8080

COPY --from=build /bin/main /bin/

# 复制配置文件
COPY app.env .

# 指定容器对外暴露的端口号
EXPOSE $PORT

# 设置容器启动时执行的命令
CMD ["/bin/main"]
```

## 多架构多平台构建二进制文件

### 先决条件

要使用多架构多平台构建二进制文件, 你需要启用`containerd 镜像存储`

- 如果使用的是Docker Desktop:
  默认情况下，containerd 镜像存储在 Docker Desktop 版本 4.34 及更高版本中处于启用状态，但仅用于全新安装或执行出厂重置。如果您从早期版本的
  Docker Desktop 升级，或者使用旧版本的 Docker Desktop，则必须手动切换到 containerd 镜像存储, 更多细节参考https:
  //docs.docker.com/desktop/containerd/#enable-the-containerd-image-store

要在 Docker Desktop 中手动启用此功能，请执行以下操作：

1. 导航到 Docker Desktop 中的**设置**。
2. 在**General**选项卡中，选中**Use containerd for pull and store images**。
3. 选择**应用并重新启动**。

要禁用 containerd 镜像存储，请清除**Use containerd for pull and storage images （使用 containerd 提取和存储映像**） 复选框。

- 如果您使用的是 Docker Engine，并且需要使用仿真构建多平台镜像，则还需要安装
  QEMU，请参阅[手动安装 QEMU](https://docs.docker.com/build/building/multi-platform/#install-qemu-manually)。

通过`docker buildx build`构建`多架构` `多平台`的二进制文件, 例如`linux/amd64`,`linux/arm64`,`darwin/arm64`:

### 可以选择的平台与架构

> 注意, 构建多个平台时, 你依赖的镜像也需要支持该平台和架构

golang的Docker容器支持:

1. linux/amd64
2. linux/arm64/v8
3. linux/arm64/v7
4. linux/arm64/v6
5. linux/386
6. linux/ppc64le
7. linux/s390x

> 注意, 多架构构建并不代表应用也支持多架构, 还需要单独打包为对应的平台和架构

- 方式1: 构建并直接推送

```shell
export version=v2.0.0
export repository="user/repo"
export GOOS=linux
export GOARCH=amd64
docker buildx build \
  --progress=plain \
  -t $repository:$version . \
  --build-arg CGO_ENABLED=0 \
  --build-arg GO_IMAGE=golang:1.23.1-alpine3.20 \
  --build-arg version=$version \
  --build-arg PORT=8080 \
  --build-arg GOOS=$GOOS \
  --build-arg GOARCH=$GOARCH \
  --platform $GOOS/$GOARCH --push
```

- 方式2: 分步骤推送

```bash
export version=v2.0.0
export repository="user/repo"
export GOOS=linux
export GOARCH=amd64
docker buildx build \
  --progress=plain \
  -t $repository:$version . \
  --build-arg CGO_ENABLED=0 \
  --build-arg GO_IMAGE=golang:1.23.1-alpine3.20 \
  --build-arg version=$version \
  --build-arg PORT=8080 \
  --build-arg GOOS=$GOOS \
  --build-arg GOARCH=$GOARCH \
  --platform $GOOS/$GOARCH

REGISTRY="docker.io"
docker push ${{REGISTRY}}/${{REGISTER_REPOSITORY}}:latest
docker push ${{REGISTRY}}/${{REGISTER_REPOSITORY}}:$version
docker push ${{REGISTRY}}/${{REGISTER_REPOSITORY}}:$GITHUB_SHA
```

## 拉取

当你构建的二进制文件时, 在拉取时需要指定目标的平台和架构

```bash
docker pull resistery/user/repo:v2.0.0 --platform linux/amd64
```

## 最佳实践示例

安装新版的Docker Desktop时, 使用`init`可以生成多个语言的Dockerfile和compose:

```bash
docker init
```

```Dockerfile
# syntax=docker/dockerfile:1
# https://docs.docker.com/go/dockerfile-reference/

# 定义基础镜像的 Golang 版本
ARG GOIMAGE=golang:1.23.1-alpine3.20

FROM --platform=$BUILDPLATFORM ${GOIMAGE} AS build
WORKDIR /src

# 版本号
ARG VERSION=latest

# Go的环境变量, 例如alpine镜像不内置gcc,则关闭CGO很有效
ARG GOOS=linux
ARG GOARCH=amd64
ARG CGOENABLED=0

# Go的环境变量, 例如alpine镜像不内置gcc,则关闭CGO很有效
ARG GO_PROXY=https://proxy.golang.com.cn,direct

COPY . .

# 设置环境变量
# RUN go env -w GOPROXY=https://goproxy.cn,direct
RUN go env -w GOPROXY=$GO_PROXY

# 利用 Docker 层缓存机制，单独下载依赖项，提高后续构建速度。
# 使用缓存挂载和绑定挂载技术，避免不必要的文件复制到容器中。
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download -x

# 获取代码版本号，用于编译时标记二进制文件
RUN echo "$a: $GOOS $GOARCH $CGOENABLED"
RUN VERSION=$(git describe --tags --always) || true
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=. \
    GOOS=$GOOS \
    GOARCH=$GOARCH \
    CGOENABLED=$CGOENABLED \
    go build -o /bin/main .
   # 带版本的形式: go build -ldflags="-X main.Version=${VERSION}" -o /bin/main .
   # 多个服务的形式: go build -o /bin/ ./...

FROM alpine:latest AS final
# 从构建阶段复制编译好的 Go 应用程序到运行阶段
COPY --from=build /bin/main /bin/

# 用户进程ID
ARG UID=10001

# 后端程序的HTTP/gRPC端口
ARG HTTP_PORT=30001
ARG GRPC_PORT=30002

# 修改镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# 安装应用运行必需的系统证书和时区数据包
# RUN --mount=type=cache,target=/var/cache/apk \
#    apk --update add ca-certificates tzdata && update-ca-certificates

# 创建一个非特权用户来运行应用，增强容器安全性
RUN adduser --disabled-password --gecos "" --home "/nonexistent" --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser

# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

USER appuser

# 复制配置文件
COPY app.env .

# 指定容器对外暴露的端口号
EXPOSE $HTTP_PORT
EXPOSE $GRPC_PORT

# 设置容器启动时执行的命令
CMD ["/bin/main"]

# 构建Docker所属的当前平台与架构的二进制文件, 进到当前的backend目录
# export VERSION=v2.0.0
# export REPOSITORY="lisa/backend"
# export GOOS=linux
# export GOARCH=amd64
# export HTTP_PORT=30001
# export GRPC_PORT=30002
# docker build . \
#   --progress=plain \
#   -t $REPOSITORY:$VERSION \
#   --build-arg CGOENABLED=0 \
#   --build-arg GOIMAGE=golang:1.23.1-alpine3.20 \
#   --build-arg GOOS=$GOOS \
#   --build-arg GOARCH=$GOARCH \
#   --build-arg VERSION=$VERSION \
#   --build-arg HTTP_PORT=$HTTP_PORT
#   --build-arg GRPC_PORT=$GRPC_PORT
#   --load

# 构建多架构的二进制文件, 需要在Docker Desktop 启用 containerd 映像存储
# https://docs.docker.com/desktop/containerd/#enable-the-containerd-image-store
# export VERSION=v2.0.0
# export REPOSITORY="lisa/backend"
# export GOOS=linux
# export GOARCH=amd64
# export HTTP_PORT=30001
# export GRPC_PORT=30002
# docker buildx build . \
#   --progress=plain \
#   -t $REPOSITORY:$VERSION \
#   --build-arg CGOENABLED=0 \
#   --build-arg GOIMAGE=golang:1.23.1-alpine3.20 \
#   --build-arg VERSION=$VERSION \
#   --build-arg HTTP_PORT=$PORT \
#   --build-arg GRPC_PORT=$PORT \
#   --build-arg GOOS=$GOOS \
#   --build-arg GOARCH=$GOARCH \
#   --platform $GOOS/$GOARCH

# 推送
# export register="ccr.ccs.tencentyun.com"
# docker tag $REPOSITORY:$VERSION $register/$REPOSITORY:$VERSION
# docker push $register/$REPOSITORY:$VERSION

# 拉取
# export GOOS=linux
# export GOARCH=amd64
# docker pull $register/$REPOSITORY:$VERSION --platform $GOOS/GOARCH

# 运行
# docker run \
# --rm \
# -p 30001:30001 \
# -p 30002:30002 \
# -e GIN_MODE=release \
# -e DB_SOURCE="postgresql://postgres:postgres@159.75.231.54:5432/simple_bank?sslmode=disable" \
# $register/container:$VERSION

```
