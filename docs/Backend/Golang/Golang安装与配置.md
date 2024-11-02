## 安装
安装Golang运行时
[Goalng Wownload](https://tip.golang.org/learn/)
https://studygolang.com/dl
## 配置

GOBIN
go install xx/xx的目录
显式定义: 例子:
> 显式定义GOBIN时, 不能使用交叉编译, 交叉编译是在一个平台上编译可以在另一个平台上运行的程序
```
go env -w GOBIN=/Users/lisa/go/bin/
```

### GOROOT
添加系统环境变量`GOROOT`的目录为`Go安装包的根目录`,非`bin`目录下, 例如`e:/go`

### 环境变量
添加GO二进制的变量, 方便随处使用GO
在系统环境变量的`Path`:添加`%GOROOT%\bin`

### GOPATH
1. 创建Golang的工作目录，与GOROOT区分开, 不与GOROOT共在一个目录, 例如:`e:/Web/Golang`
2. 在Golang的工作目录创建:`src`,`pkg`,`bin`目录
通过go env 设置GOPATH
```shell
go env -w GOPATH=E:\Golang\src
```

### Windows 推荐设置
说明
Powershell终端语法:
Foo： key
Bar： value
Machine： system scope 系统环境变量
```powershell
 [Environment]::SetEnvironmentVariable('Foo', 'Bar', 'Machine')
```
删除：
```powershell
[Environment]::SetEnvironmentVariable('Foo', '', 'Machine')
```

推荐设置：
```shell
[Environment]::SetEnvironmentVariable('GOPATH', 'F:\Golang', 'Machine')
[Environment]::SetEnvironmentVariable('GOENV', 'F:\Go\env', 'Machine')
go env -w GOMODCACHE=F:\Go\pkg\mod
go env -w GOCACHE=F:\Go\go-build
```
### vendor
**单项目(独立于GOPATH与GOROOT的目录外的项目)使用vendor管理MOD包**
-   一个库工程（不包含 `main` 的 `package`）不应该在自己的版本控制中存储外部的包在 `vendor` 目录中，除非有特殊原因并且知道为什么要这么做。
-   在一个应用中，（包含 `main` 的 `package`），建议只有一个 `vendor` 目录，且在代码库一级目录。

1. 启用
`go 1.6`以上已经内置
`go 1.5` 需要设置环境变量
```shell
go env -w GO15VENDOREXPERIMENT=1
```

2. 使用vendor管理, 在下面根目录下创建`vendor`目录
```shell
cd project
mkdir vendor
```

3. 使用vendor安装
```shell
go mod vendor
```

在执行 `go build` 或 `go run` 命令时，会按照以下顺序去查找包：
-   当前包下的 vendor 目录
-   向上级目录查找，直到找到 src 下的 vendor 目录
-   在 GOROOT 目录下查找
-   在 GOPATH 下面查找依赖包

## GOMOD
使用`auto`来区分GOPATH工作目录与单项目, 工作目录不应使用`vendor`来管理
```shell
go env -w GO111MODULE=auto
```

日常学习开发可以在`GOPATH`的`src`目录下进行管理与安装, 使用`GOPATH`下的包,而不是单独的创建独立的`vendor`目录来管理依赖

1. 创建mod文件
```pwsh
go mod init
```

2. 更新库
```
go mod tidy
```
