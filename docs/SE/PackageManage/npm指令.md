# NPM指令

#PackageManage #命令

卸载

```shell
npm uninstall --save-dev
npm uninstall -g
npm uninstall
```

强制重新build,重新构建package依赖

```shell
npm rebuild
```

清除缓存

```shell
npm cache clean
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

获取npm配置缓存位置

```shell
npm config get cache
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

## npm 与 yarn 对比

```
+--------------------------------------------------+--------------------------+
| npm | yarn |
+==================================================+==========================+
| npm install | yarn install |
+--------------------------------------------------+--------------------------+
| npm install <package>                            | yarn add <package>       |
+--------------------------------------------------+--------------------------+
| npm install <package> --save | yarn add <package>       |
| npm install <package> --save-dev | yarn add <package> --dev |
+--------------------------------------------------+--------------------------+
| npm uninstall  <package>                         | yarn remove <package>    |
| npm uninstall <package> --save-dev | yarn remove <package>    |
| npm uninstall <package> -save-optional [package] | yarn remove <package>    |
+--------------------------------------------------+--------------------------+
| 清除缓存 | npm cache clean |
| npm cache clean | |
+--------------------------------------------------+--------------------------+
| 卸载node_module并重新安装 | yarn upgrade |
| rm -rf node_modules && npm install | |
+--------------------------------------------------+--------------------------+
```