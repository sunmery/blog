## install
1. xocde
检查是否安装已经目录的文件是否随着系统更新丢失, 一般有 3 个文件夹 5,7,7 个文件
```shell
ls -l /Library/Developer/CommandLineTools
```
如果没有:
```shell
xcode-select --instal
```

2. brew更新

在`.zprofile`添加:
```shell
val "$(/opt/homebrew/bin/brew shellenv)"
```

```shell

brew update
```

3. protobuf
```shell
brew install protobuf
brew upgrade protobuf
```

protobuf-gen-go