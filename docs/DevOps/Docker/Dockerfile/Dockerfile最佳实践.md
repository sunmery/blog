# 最佳实践

1. 下载依赖项作为一个单独的步骤来利用Docker的缓存。
2. 利用缓存挂载到/go/pkg/mod/来加快后续构建。
3. 利用绑定挂载（bind mounts）来引入go.sum和go.mod文件，而不是将这些文件复制到容器中。
4. 这样做可以减少构建时的数据复制操作，加快构建速度，并确保容器中的文件总是与宿主机上的文件同步
5. 这意味着在这个目录下的所有文件都会被缓存，即使在多次构建容器会被销毁。
6. 缓存Go模块，避免在每次构建时都需要重新下载，从而加速构建过程
7. 多阶段构建：首先使用一个包含 Golang 编译环境的较大镜像进行构建，然后在第二个阶段使用轻量级的 Alpine Linux 镜像运行应用。这样做可以显著减小最终镜像的体积，提高运行时效率
8. 跨平台构建, 一次部署即可编译构建多个平台架构的软件包

## 定义Dockerfile解析器的版本
用于AST的解析器规则, 实验版本包含未经过长期验证, 但包含新的特性

## 稳定版本
1. `syntax=docker/dockerfile:1`, 表示使用最新的 1.x.x和补丁版本进行更新
3. `docker/dockerfile:1.2`: 使用最新的 1.2.x 补丁版本保持更新，并在版本 1.3.0 发布后停止接收更新。
5. `docker/dockerfile:1.2.1`; 固定版本

## 实验版本
1. docker/dockerfile:labs - 频道上的 labs 最新版本。
2. docker/dockerfile:1-labs - 与 dockerfile:1 相同，并启用了实验性功能。
3. docker/dockerfile:1.2-labs - 与 dockerfile:1.2 相同，并启用了实验性功能。
4. docker/dockerfile:1.2.1-labs - 不可变：从不更新。与 dockerfile:1.2.1 相同，并启用了实验性功能。

## 平台选择
golang的Docker容器支持:
1. linux/amd64
2. linux/arm64/v8
3. linux/arm64/v7
4. linux/arm64/v6
5. linux/386
6. linux/ppc64le
7. linux/s390x

## 多平台构建
```shell
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t ccr.ccs.tencentyun.com/lisa/go:alpine3.19 .

docker buildx build -t ccr.ccs.tencentyun.com/lisa/go:alpine3.19 --platform linux/amd64 . --push
docker buildx build -t ccr.ccs.tencentyun.com/lisa/go:alpine3.19 --platform linux/arm64 . --push
docker buildx build -t ccr.ccs.tencentyun.com/lisa/go:alpine3.19 --platform linux/arm/v7 . --push
```
