# 安装
### Go1.16版本之后
在非项目目录运行
```shell
go install github.com/cosmtrek/air@latest
```

### Go1.16之前
```shell
go get -u github.com/cosmtrek/air/air
```

## 入门

无需配置环境变量, 直接使用: 
1. 进入项目根目录
2. 初始化air配置
3. 将`GOPATH`替换成实际的`GOPATH`路径

```shell
cd /project
air init
<GOPATH>\bin\air.exe .
```

## 配置

### 配置文件
#### 生成默认配置文件
```shell
cd /project
air init
```

#### 指定配置文件

使用`-c`指定配置文件, 例如`.air.toml`,如果该文件不存在, 则寻找其他匹配的文件
```
cd /project
air -c <air_file>
```

### 设置环境变量

#### Windows
配置`AIR`运行路径
在`shell`临时终端配置`air`的路径别名. 

> 指令在`powershell 7`终端工具可用，其他终端自行尝试

在`shell`添加终端配置`air`的路径别名. 
格式:
```shell
Set-Alias -Name air -Value '<GOPATH>\bin\air.exe'
```

示例：
```shell
Set-Alias -Name air -Value F:\Web\Golang\bin\air.exe
```

2. 添加到临时PATH
```
$env:PATH = $env:PATH + ";E:\GoProject\bin\air.exe"
```

#### Mac
1. 利用`go env GOPATH`查看并复制go安装路径
```shell
go env GOPATH
```

2. 添加`air`别名与`air`的安装路径
```shell
vi ~/.zshrc
alias air='/Users/art/go/bin/air'
```

3. 重新读取`zsh`配置
```shell
source ~/.zshrc
```

### 添加参数
使用`air`运行项目时启动额外的参数
语法:
```
air -- [option1] [options2] [optionsN]
```
例如原本使用`go run . -mode=dev -port=4000`
在`Air`是这样运行:
```
air -- -mode=dev -port=4000
```

### Goland IDE配置环境变量
设置临时变量, 每次启动`Goland`时自动添加该临时变量
优点: 干净, 无需污染环境变量
格式:
```
alias air='<GOPATH>\bin\air.exe'
```
示例:
![[./images/Pasted image 20230206144314.png]]

## 进阶
### 修改air配置
参考[air官网](https://link.zhihu.com/?target=https%3A//github.com/cosmtrek/air/blob/master/air_example.toml)给出的配置文件进行修改
在下面根目录创建 `.air.toml`或`.air.conf`
```toml
# [Air](https://github.com/cosmtrek/air) TOML 格式的配置文件

# 工作目录
# 使用 . 或绝对路径，请注意 `tmp_dir` 目录必须在 `root` 目录下
root = "."
tmp_dir = "tmp"

[build]
# 只需要写你平常编译使用的shell命令。你也可以使用 `make`
# Windows平台示例: cmd = "go build -o tmp\main.exe ."
cmd = "go build -o ./tmp/main ."
# 由`cmd`命令得到的二进制文件名
# Windows平台示例：bin = "tmp\main.exe"
bin = "tmp/main"
# 自定义执行程序的命令，可以添加额外的编译标识例如添加 GIN_MODE=release
# Windows平台示例：full_bin = "tmp\main.exe"
full_bin = "APP_ENV=dev APP_USER=air ./tmp/main"
# 监听以下文件扩展名的文件.
include_ext = ["go", "tpl", "tmpl", "html"]
# 忽略这些文件扩展名或目录
exclude_dir = ["assets", "tmp", "vendor", "frontend/node_modules"]
# 监听以下指定目录的文件
include_dir = []
# 排除以下文件
exclude_file = []
# 如果文件更改过于频繁，则没有必要在每次更改时都触发构建。可以设置触发构建的延迟时间
delay = 1000 # ms
# 发生构建错误时，停止运行旧的二进制文件。
stop_on_error = true
# air的日志文件名，该日志文件放置在你的`tmp_dir`中
log = "air_errors.log"

[log]
# 显示日志时间
time = true

[color]
# 自定义每个部分显示的颜色。如果找不到颜色，使用原始的应用程序日志。
main = "magenta"
watcher = "cyan"
build = "yellow"
runner = "green"

[misc]
# 退出时删除tmp目录
clean_on_exit = true
```
