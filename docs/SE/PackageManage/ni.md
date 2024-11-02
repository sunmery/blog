# ni

#PackageManage #命令
> [antfu/ni: 💡 Use the right package manager (github.com)](https://github.com/antfu/ni)
> [core/contributing.md at main · vuejs/core (github.com)](https://github.com/vuejs/core/blob/main/.github/contributing.md#development-setup)

## ni  安装

> npm install 缩写

```shell
ni <package>
ni <package> -g
```

对应包管理:

```shell
+ pnpm i <package> -g
+ npm i <package> -g
+ yarn global add <package>
```

```
ni --frozen 确保您拥有包锁和最新安装
```

对应包管理器:

+ npm ci
+ yarn install --frozen-lockfile
+ pnpm install --frozen-lockfile

## nr  运行

> 类似 npm run

```
nr dev --post=3000
```

对应包管理器:

+ pnpm run dev --port=3000
+ yarn run dev --port=3000
+ npm run dev --port=3000

```
nr
```

交互式选择要运行的脚本(提供一个脚本列表选择运行)

## nx  执行

> 类似 npx

```
nx jest
```

对应包管理器:

+ npx jest
+ yarn dlx jest
+ pnpm dlx jest

## nu  升级

> npm upgrade

```
nu
```

```
nu -i 更新项目依赖,显示出可更新的依赖
```

+ npm upgrade
+ yarn upgrade-interactive
+ pnpm upgrade

## nci 全新安装

> 如果相应的节点管理器不存在，则此命令将沿途package.json安装它