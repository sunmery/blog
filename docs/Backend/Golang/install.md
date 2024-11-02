原理: 
1. 将`<package>`下载的包编译成二进制文件, 并放到`$GOPATH/bin` 中
```shell
go install <pakcage>
```

## 示例
1. **...** 安装某个目录下面所有的二进制文件
```shell
go install github.com/cloudflare/cfssl/cmd/...@latest
```

2. **@version**tag安装方式:
```
go install github.com/cloudflare/cfssl@latest
```



运行别人的git仓库包
1. 克隆
2. 安装依赖 `go mod download`