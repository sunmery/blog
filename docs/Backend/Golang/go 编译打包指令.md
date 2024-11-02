
```
CGO_ENABLED : 0/1
CGO 表示golang中的工具，CGO_ENABLED=0 表示CGO禁用，交叉编译中不能使用CGO的
```

打包为Linux
1. 
```shell
CGO_ENABLED=0 CC=x86_64-unknown-linux-gnu-gcc CXX=x86_64-unknown-linux-gnu-g++ GOOS=linux GOARCH=amd64 go build -o app .
```

2.  禁止交叉编译
```
CC=x86_64-unknown-linux-gnu-gcc CXX=x86_64-unknown-linux-gnu-g++ GOOS=linux GOARCH=amd64 go build -o app .
```

打包为Windows
```shell
CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc CXX=x86_64-w64-mingw32-g++ GOOS=windows GOARCH=amd64 go build .
```

减少 构建到镜像的体积:
[参考](https://zhuanlan.zhihu.com/p/382175578)

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