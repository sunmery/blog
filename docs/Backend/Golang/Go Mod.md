## 版本迭代: 
GOPATH -> GOVORDER -> GOMOD

```shell
go mod <options>
```

options:
- init 初始化新项目,创建 `go.mod`文件
- download 下载模块到本地缓存
- tidy 调整项目的依赖, 对不需要的模块进行删除或对需要的模块进行增加
- `-compat=1.17`  在 Go 1.17 及以上版本中，`go mod tidy` 命令用于整理并更新项目的模块依赖。而在 Go 1.17 之前的版本中，并没有 `-compat` 这个参数。
`-compat=1.17` 是一个非标准的参数，它允许您在 Go 1.17 及以上版本中使用 Go 1.17 引入的一些新的模块相关的功能，而不会影响到 Go 1.17 之前的版本。使用这个参数，可以确保在 Go 1.17 及以上版本中获得一些新功能的好处，而在较旧的版本中仍然保持向后兼容性。
## Proxy
即模块的缓存, 分发

没有 Proxy 之前:

由于源代码大多数都是存储在 `git`/`svn`仓库上,如果作者对代码进行删除, 则项目更新了该模块, 则有可能依赖丢失问题,造成安全隐患. 

引入 Proxy 之后:
- 对模块进行缓存
- 加速下载, 譬如 `github`等国外服务器下载慢的问题

## go get
```shell
go get exampke/pkg[options]
```

options:
- `@update` 更新依赖
- `@none` 删除依赖
- `@vX.Y.Z` 依赖`X.Y.Z`这个`tag`的具体版本
- `@commit version` 指定该依赖的`commit`提交
- `@master` 分支名的依赖
	- `@latest` 标签标识 
	- `@v1` 版本号标识