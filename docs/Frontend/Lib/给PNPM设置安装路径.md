# 给PNPM设置不一样的家——设置PNPM全局安装路径

## 引言

在使用[PNPM](https://pnpm.io)默认的全局配置时，它会在系统盘存储你全局安装的NPM包，使用久了，安装全局的包多了，自然就会占用很多系统盘的存储空间，对于给系统盘分配较小的存储空间的小伙伴是不太友好的，而且重装系统时也同样会被格式化。 在安装PNPM时给它改变全局安装的位置，让系统盘的做它应该做的事

## 流程

分为5个步骤：

1.  配置PNPM环境变量
2.  配置PNPM仓库路径
3.  配置PNPM全局安装路径
4.  配置PNPM缓存路径
5.  配置PNPM状态路径   

**关键步骤： 使用`NPM`的`config`选项的`set`指令**

### 配置PNPM环境变量

> 给PNPM找到你配置的全局安装路径

1. WIN+S快捷键 -> 编辑系统环境变量 -> 环境变量 -> 新建系统变量
2. 设置PNPM环境变量映射:
    1. PNPM仓库名: `PNPM_HOME`
    2. PNPM路径(你要存放的仓库目录): `E:/.pnpm-store\bin`

### 配置PNPM全局存储路径

1. 打开任意终端
2. 将`<global-store-path>`替换成你要存放的仓库目录,例如`E:\.pnpm-store\global`

语法:

```shell
pnpm config set store-dir <global-store-path>
```

示例:

```shell
pnpm config set store-dir E:\.pnpm-store\global
```

### 配置PNPM全局bin存储路径

1. 打开任意终端
2. 将`<store-bin-path>`替换成你的PNPM的bin目录, 例如`E:\.pnpm-store\bin`
```shell
pnpm config set global-bin-dir <store-bin-path>
```

示例:

```shell
pnpm config set global-bin-dir E:\.pnpm-store\bin
```

 
### 配置PNPM缓存存储路径

> PNPM的缓存存储位置

1. 打开任意终端
2. 将`<store-cache-path>`替换成你要存放的缓存目录,例如:`E:\.pnpm-store\cache`
```shell
pnpm config set cache-dir <store-cache-path>
```

示例:

```shell
pnpm config set cache-dir E:\.pnpm-store\cache
```

### 配置PNPM状态存储路径

> 选择存储PNPM状态的位置(管理安装/网络 失败/异常等)

1. 打开任意终端
2. 将`<store-state-path>`替换成你要存放的仓库目录,例如`E:\.pnpm-store\state`
```shell
pnpm config set state-dir <store-state-path>
```

示例:

```shell
pnpm config set state-di E:\.pnpm-store\state
```


### 应用配置(可选)

> 如果你使用以上方式配置成功了,那么此步骤可以跳过

1. 打开任意终端
2. 输入指令:


```shell
 pnpm setup
```

## 检验
1. 测试设置的路径是否是自己设置的
  
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e70a0bae97854487848c72401a6b873b~tplv-k3u1fbpfcp-watermark.image?)

2. 测试全局安装

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/377bff007c924ddba39c66d7ce779b1b~tplv-k3u1fbpfcp-watermark.image?)

## 注意

1. 本文章设置时`PNPM`的版本为`7.15.0`, 适用于`7.x`版本左右, 其他版本未经测试.
2. 若按照本文教程配置出错,考虑降低`PNPM`版本为本教程同样版本再试.


## 参考
1.[NPM](https://docs.npmjs.com/cli/v8/using-npm/config)

2.[PNPM](https://pnpm.io/zh/configuring)
