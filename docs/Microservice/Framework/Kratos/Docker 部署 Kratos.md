1. 将`tiktok`替换为你项目名
2. 将`EXPOSE`端口替换为你需要的
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

# RUN make build
RUN go env -w CGO_ENABLED=0 GOOS=linux GOARCH=amd64 && go build -o /app/bin/ ./...

FROM alpine:latest

WORKDIR /app

RUN ls
RUN ls /

# 从 builder 镜像中复制 Go 二进制文件到当前镜像中
COPY --from=builder /app/bin/tiktok .
RUN ls
RUN ls /
# 设置时区为上海
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' >/etc/timezone

# 设置编码
ENV LANG C.UTF-8

# 暴露端口
EXPOSE 8080
EXPOSE 4000

VOLUME /data/conf

# 定义容器启动时运行的命令
ENTRYPOINT ["/app/tiktok", "-conf", "/data/conf"]

# docker build --progress=plain --no-cache -t tiktok .
# docker run -itd -v ./configs:/data/conf -p 8080:8080 -p 4000:4000 tiktok

```