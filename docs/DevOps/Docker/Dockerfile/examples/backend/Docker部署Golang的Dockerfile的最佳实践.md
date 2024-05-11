
```Dockerfile
# syntax=docker/dockerfile:1
# https://docs.docker.com/go/dockerfile-reference/

# 定义基础镜像的 Golang 版本
ARG GO_VERSION=alpine3.19
FROM --platform=$BUILDPLATFORM golang:${GO_VERSION} AS build
WORKDIR /src

# 设置环境变量
RUN go env -w GOPROXY=https://goproxy.cn,direct

# 利用 Docker 层缓存机制，单独下载依赖项，提高后续构建速度。
# 使用缓存挂载和绑定挂载技术，避免不必要的文件复制到容器中。
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download -x

# 获取代码版本号，用于编译时标记二进制文件
ARG TARGETARCH
RUN VERSION=$(git describe --tags --always)
RUN --mount=type=cache,target=/go/pkg/mod/ \
    --mount=type=bind,target=. \
    CGO_ENABLED=0 GOARCH=$TARGETARCH go build -ldflags "-X main.Version=${VERSION}" -o /bin/server ./...

FROM alpine:latest AS final

# 安装应用运行必需的系统证书和时区数据包
RUN --mount=type=cache,target=/var/cache/apk \
    apk --update add ca-certificates tzdata && update-ca-certificates

# 创建一个非特权用户来运行应用，增强容器安全性
ARG UID=10001
RUN adduser --disabled-password --gecos "" --home "/nonexistent" --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser

# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

USER appuser

# 从构建阶段复制编译好的 Go 应用程序到运行阶段
COPY --from=build /bin/server /bin/

# 指定容器对外暴露的端口号
EXPOSE 30001

# 设置容器启动时执行的命令
ENTRYPOINT ["/bin/server", "-conf", "/data/conf"]
```
