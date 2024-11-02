# CMD常用操作

#Shell #PackageManage #命令

- 创建文件夹

```shell
    md <folder>
    or
    mkdir <folder>
```

- 删除文件夹

> rd 只能删除空文件夹 <br/>
> 参数
>- /s 直接删除
>- /q (即quiet) 安静模式(不询问)

```shell
rd /s /q [盘符:\][路径\]
```

- 创建文件

> 格式:
> type nul> *.*
> 第一个` * `代表文件名
>
> 第二个` * `代表扩展名/后缀名

```shell
创建一个名为.npmrc的文件
type nul>.npmrc
```

删除文件

```
del 文件路径
```

CMD 与 PowderShell 区别
PowderShell 使用 ; 来分割

CMD使用 && 来连接

```shell
cmd: 以 && 来连接指令, 使用 ; 或报错
```

```shell
pnpm add element-plus @types/node sass -D &&
pnpm add echarts -S &&
pnpm add vue-router@next vue-i18n@next pinia@next 
```

PowerShell: 以 ; 来分割指令,使用 && 会报错

```shell
pnpm add element-plus @types/node sass -D;
pnpm add echarts -S;
pnpm add vue-router@next vue-i18n@next pinia@next

```

##### 校验文件

`certutil -hashfile <Filename> Hash/Sha256/MD5`