## 前置条件

1. 当前PC拥有任意一种终端,`cmder`,`Window PowerShell`, `PowerShell`, `warp`
   推荐使用`PowerShell 7` [链接](https://docs.microsoft.com/zh-cn/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7.2)
2. 当前PC拥有`PNPM`,检查是否安装了`PNPM`

```shell
pnpm -v
```

## 核心思路

通过`Sehll`的配置文件,吗,每次启动读取自身的配置文件,将`PNPM`的别名指向`PNPM`

以下针对的是 `PowerShell 7`的设置

1. 检查是否存在`PowerShell 7`的配置文件

```pwsh
echo $PROFILE
```

![[images/Pasted image 20220907102712.png]]
通过输出的路径找到该配置文件

PS： 如果没有配置文件，则手动创建,使用`PowerShell`将`<PowerShell-config-file>`替换为通过`echo $PROFILE`指令的地址

```powershell
new-item <PowerShell-config-file>
```

2. 导入`PNPM`别名配置
1. 打开配置文件
2. 复制指令,将你想设置的`别名`替换`<alias-name>`
3. 重启`PowerShell`

```ps1
Set-Alias -Name <alias-name> -Value pnpm
```

示例: 将p作为PNPM的别名

```ps1
Set-Alias -Name p -Value pnpm
```

3. 校验

```Shell
p -v
```

![[images/Pasted image 20220907102959.png]]

## 参考

[1] 掘金文章 https://juejin.cn/post/7103763842760441893
[2] PNPM ](https://pnpm.io/zh/installation#%E4%BD%BF%E7%94%A8%E8%BE%83%E7%9F%AD%E7%9A%84%E5%88%AB%E5%90%8D)