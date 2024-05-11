## 从终端打开
配置终端环境变量
变量名：你想打开`VSCode`的快捷指令， 例如`code`
变量值：`VSCode`的根目录下的`bin`路径下的`code`文件
- 稳定版:  `<VSCode_DIR>/bin/code`
- 预览版: `<VSCode_DIR>/bin/code-insiders`

Powershell

> 前置条件： 创建过`Powershell`的配置文件，看不懂或者不知道则按照下面操作

1. 查找`Powershell`配置文件
```
echo $PROFILE
```
![[Pasted image 20230205052158.png]]

2. 在`echo $PROFILE`运行之后的输出目录下创建`Microsoft.PowerShell_profile.ps1`文件（右键创建文件或运行以下指令）
![[Pasted image 20230205052236.png]]
```pwsh
new-item Microsoft.PowerShell_profile.ps1
```

添加环境变量：
`%USER_DIR%\Documents\PowerShell/Microsoft.PowerShell_profile.ps1`
指令：
```pwsh
"Set-Alias -Name code -Value <VSCode_DIR>/bin/code" | Out-File -Append .\Microsoft.PowerShell_profile.ps1
```

手动：
```pwsh
Set-Alias -Name code -Value <VSCode_DIR>/bin/code
```

最终效果
![[Pasted image 20230205053410.png]]

示例：
```pwsh
"Set-Alias -Name code -Value 'E:\Microsoft\VS Code Insiders\bin\code-insiders'" | Out-File -Append .\Microsoft.PowerShell_profile.ps1
```

```pwsh
Set-Alias -Name code -Value 'E:\Microsoft\VS Code Insiders\bin\code-insiders'
```

临时（终端关闭失效）
```shell
alias code="<VSCode_DIR>/bin/code>"
```

## 校验

```shell
code .
```