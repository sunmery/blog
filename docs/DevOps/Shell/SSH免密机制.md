## 原理

利用ssh的RSA加密算法的公钥与私钥进行加密与解密, 则不再需要密码作为key即可进行免密登录

## Use

把本机的`<file>.pub`公钥文件传输至远程主机的`~/.ssh/`, 并创建具有权限的`authorized_keys`

### 快速部署

```shell
export user="root"
export host="192.168.2.101"
scp ~/.ssh/id_rsa.pub $user@$host:~/.ssh/authorized_keys
```

### 第三方库:

语法:

```bash
ssh-copy-id <file>.pub user@host 
```

示例:

```bash
ssh-copy-id root@192.168.0.152
```

参数:
-i 指定文件

```bash
ssh-copy-id -i <file>.pub user@host 
```

示例:
本机(158) 发送`gitlabpullweb_rsa.pub`公钥文件至远程主机`192.168.0.152`中

```bash
ssh-copy-id -i ~/.ssh/gitlabpullweb_rsa.pub root@192.168.0.152
```

## 测试:

> 第一次可能需要密码, 请重复执行两次

示例:

```bash
ssh root@192.168.0.152
```

## 启用私钥登录,禁用密码登录

生成本地的公钥和私钥文件，并想要使用它们来登录远程Linux主机，可以按照以下步骤进行：

1. **将公钥复制到目标主机**：首先，您需要将您的公钥复制到远程主机的`~/.ssh/authorized_keys`文件中。您可以使用`scp`
   命令或其他文件传输工具来实现。例如：

```shell
scp /path/to/your/public/key user@remote_host:~/.ssh/authorized_keys
```

替换`/path/to/your/public/key`为您的公钥文件的实际路径，`user`为目标主机上的用户名，`remote_host`
为目标主机的地址。这将把您的公钥添加到远程主机的授权密钥文件中。

2. **SSH登录**：一旦您的公钥添加到远程主机上，您就可以使用私钥文件进行SSH登录。使用`ssh`命令，通过`-i`选项指定私钥文件的路径，如下所示：

```shell
ssh -i /path/to/your/private/key user@remote_host
```

替换`/path/to/your/private/key`为您的私钥文件的实际路径，`user`为目标主机上的用户名，`remote_host`为目标主机的地址。

3. **输入私钥密码**（如果有的话）：如果您的私钥文件受密码保护，您需要在登录时输入该密码。

这样，您就可以使用已有的本地公钥和私钥文件登录到目标Linux主机了。请确保私钥文件的权限设置为仅拥有者可读（通常是600），以确保安全性。如果您的私钥文件不在默认位置（
`~/.ssh/id_rsa`或`~/.ssh/id_dsa`），请使用`-i`选项指定私钥文件的路径。
