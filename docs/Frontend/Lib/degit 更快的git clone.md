## 下载
```shell
pnpm add -g degit
```

## 使用
```shell
degit user/repo
degit github:user/repo
degit git@github.com:user/repo
degit https://github.com/user/repo
```

## 核心原理
不去深度克隆历史

## 为什么需要?
1. 更快的git clone, 不去深度克隆历史
2. 不需要重新`git init`进行初始化成自己的git仓库