# CMD,PowerSehll,Git终端开启代理

#Shell

> 方便在终端通过代理工具加速下载

类别:
#效率 #Shell

参考:
[CSDN](https://blog.csdn.net/qq_27879651/article/details/109749112)
[其他博客](https://bestproxy.cc/4339.html)

## 使用方式

### 临时变量

**将PowerSehll的端口设为与代理软件的端口一致**

语法:

- cmd 语法:
    - `set hhtp_proxy=<url:port>`
    - `set hhtps_proxy=<url:port>`

```Shell
set http_proxy=http://127.0.0.1:7890 & set https_proxy=http://127.0.0.1:7890
```

- Powershell 语法:
    - `$Env:http_proxy=":<port>"`
    - `$Env:https_proxy=":<port>"`

示例:

```Shell
$Env:http_proxy=":7890";$Env:https_proxy=":7890"
```

bash 语法:

示例:

```Shell
export http_proxy=”:port” export https_proxy=":port"

or

export http_proxy=”socks5://127.0.0.1:1080″ export https_proxy=”socks5://127.0.0.1:1080″
```

- git 语法:

示例:

```
git config –global https.proxy http://127.0.0.1:1080 git config –global https.proxy https://127.0.0.1:1080
```

- (按需)设置全部的代理

```Shell
export ALL_PROXY=”socks5://127.0.0.1:1080″
```

取消代理

```
git config –global –unset http.proxy git config –global –unset https.proxy
```

### 写入配件配置

**不卸载软件删除配置文件则一直都存在**

方案: 把代理服务器地址写入shell配置文件.bashrc或者.zshrc 直接在.bashrc或者.zshrc添加上面内容