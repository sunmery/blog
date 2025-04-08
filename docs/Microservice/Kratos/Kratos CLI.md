[参考](https://go-kratos.dev/docs/getting-started/usage/)

## 快速入门

创建项目模板
-b: 指定分支
-r: 指定模板的源

```
kratos new helloworld -b main
kratos new helloworld -r https://gitee.com/go-kratos/kratos-layout.git
```

用`--nomod`添加服务，共用`go.mod`，大仓模式

```
kratos new app/user --nomod
```

生成proto模板

```
kratos proto add api/user/v1/user.proto
```

生成client源码

```shell
make api
```

或者

```
kratos proto client api/helloworld/helloworld.proto
```

会在proto文件同目录下生成:

```
api/helloworld/v1/demo.pb.go
api/helloworld/v1/demo_grpc.pb.go# 注意 http 代码只会在 proto 文件中声明了 http 时才会生成api/helloworld/v1/demo_http.pb.go
```

生成service代码

```
kratos proto server api/helloworld/helloworld.proto -t internal/service
```
