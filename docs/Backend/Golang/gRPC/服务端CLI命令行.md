https://github.com/ktr0731/evans/releases
## 安装

二进制:

```bash
VERSION="v0.10.11"
ARCH="arm64"
OS="darwin"

wget https://github.com/ktr0731/evans/releases/download/$VERSION/evans_${OS}_$ARCH.tar.gz

mv evans ~/Public/go/bin
```

检查是否安装
```bash
evans -v
```

## [使用](https://github.com/ktr0731/evans)

启动grpc服务
- --port 30001, gRPC默认端口50043
- --host: 网络地址
- -r/--reflection: 服务器如果使用[gRPC反射](https://github.com/grpc/grpc/blob/master/doc/server-reflection.md), 添加此参数
- -t/--tls: 使用tls
```bash
evans --host localhost --port 30001 -r repl
```

- 显示 proto 文件的包名称:  show package
- 显示服务或消息的摘要: 
```
package api
show service
show message
```

显示消息的更多描述:  desc SimpleRequest
为每个请求设置标头:  header foo=bar

show header

