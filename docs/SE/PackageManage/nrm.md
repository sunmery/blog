# Node Registry Manager

#PackageManage #命令 #教程
> Node 镜像 管理

## 安装

```
npm install -g nrm
```

## 查看列表镜像源

```
nrm ls
```

## 查看当前使用的镜像源

```
nrm current
```

## 测速

> registry

```
nrm test <registry>
```

## 切换到镜像

> registry 镜像名,在nrm ls中选择

```
nrm use <registry>
```

## 增加镜像源

> 你可以增加定制的源，特别适用于添加企业内部的私有源
>
> registry: 源名
>
> url: 源的网址/路径

```
nrm add <registry> <url>
```

## 删除

> registry 镜像源名称

```
nrm del <registry>
```