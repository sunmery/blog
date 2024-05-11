# PNPM

#PackageManage #命令

## 换源
阿里源
 ```shell
pnpm config set registry http://registry.npmmirror.com
```
官方源
```shell
pnpm config set registry https://registry.npmjs.org/
```

检查是否替换成功
```sh
 pnpm config get registry
```
参数:
--fetch-retries 5: 重试次数5

升级

```shell
pnpm add -g pnpm
```

列出全局包

```shell
pnpm ls -g
```

卸载

```shell
pnpm rm <page>
```