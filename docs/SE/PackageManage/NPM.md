# NPM

#PackageManage

## 换源
 ```shell
npm config set registry http://registry.npmmirror.com
```

检查是否替换成功
```sh
 npm config get registry
```

> Node Package Manager

## 安装

1. 不加包名

> 根据package.json的依赖环境进行安装

```
npm intsall
```

2. 添加包名

```
npm install <packname>
OR
npm i <packname>
```

## npm install安装原理

![](npm%20install安装原理流程图.png)

## 安装到依赖环境

- 生产和开发依赖

> 关键字: 不加参数,默认值

```shell
npm install <packname> --save-dev
```

OR

```shell
npm i <packname> -D
```

- 开发依赖

> 关键字: --save-dev

```shell
npm install <packname> --save-dev
```

OR

```shell
npm i <packname> -D
```

查看.npmrc位置

```shell
npm config list 
```

编辑.npmrc文件

```shell
npm config edit
```

查看npm版本

```shell
npm -v
```

检查当前npm源
切换回npm默认源

```shell
npm get registry
```

切换到npm淘宝源(淘宝源亲测不是总是最新的)

```shell
npm config set registryhttps://registry.npm.taobao.org/
```

切换回npm默认源

```shell
npm config set registryhttps://registry.npmjs.org
```

## 安装方式:

### 全局安装:

> 需要全局安装的库一般都会自动配置环境变量,通过环境变量去寻找对应的包

全局安装一般都是工具,例如:

- yarn
- pnpm
- webpack
- typescript
- gulp
- rust

> 误区:
> - 全局安装一般都是工具
> - axios, express,koa, vue,element-plus一般不是全局安装
> - 尽管全局安装了某些库,但并不是完全在项目保证可用