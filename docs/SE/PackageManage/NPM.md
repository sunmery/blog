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

切换到最新的淘宝源：

```
npm config set registry https://registry.npmmirror.com
```

使用**阿里云**镜像源加速 NPM

```
npm config set registry https://npm.aliyun.com
```

使用**腾讯云**镜像源加速 NPM

```
npm config set registry http://mirrors.cloud.tencent.com/npm/
```

使用**华为云**镜像源加速 NPM

```
npm config set registry https://mirrors.huaweicloud.com/repository/npm/
```

返回**npm** 官方原始镜像

```
npm config set registry https://registry.npmjs.org/
```

**使用那个镜像，只需要 npm config set registry + 对应的镜像网址就好了**

```
npm config set registry 
```

**查看当前的镜像源**

```
npm config get registry
``````

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
