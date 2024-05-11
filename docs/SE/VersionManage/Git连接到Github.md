# Git连接到Github

#教程 #命令 #Git

> 参考: [Git安装教程](https://www.cnblogs.com/hdlan/p/14395189.html)
>
> 参考: [Git连接Github](https://www.cnblogs.com/hdlan/p/14395681.html)

## 第一次配置

### 设置个人标识

**名称**

> username : 你的名字/昵称

```git
git config --global user.name "username"
```

**邮箱**

> your_email@example.com 你的邮箱

```git
git config --global user.email "your_email@example.com"
```

### 创建密钥
使用`ED25519`算法生成密钥
[深入了解](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/checking-for-existing-ssh-keys)
```git
ssh-keygen -t ed25519 -C "your_email@example.com"
```
1. 输入文件路径（多配置文件的需求）
2. 输入一个密码
3. 输入重复密码

### 多密钥配置
在`~/.ssh`目录创建`config`文件

- Host： 主机，任意名
- HostName： 主机名，固定
- PreferredAuthentications： 认证方式，可选一种或多种，使用逗号分隔
	- publickey：公钥，服务器使用公钥与本地私钥对比
	- password： 密码
- IdentityFile： 密钥文件路径

示例：
```config
Host git
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/github/id_ed25519
```

### 保护密钥
[使用ssh-agent保护密钥](https://learn.microsoft.com/zh-cn/windows-server/administration/openssh/openssh_keymanagement)
使用任意一种终端加密：
将`<id_ed25519-path>`替换成你的实际`id_ed25519`文件路径
- 使用`powershell 7`操作：
```pwsh
# 获取ssh-agent的Windows服务，
# 并将其启动类型设置为手动，
# 以便后续手动启动该服务供 SSH 客户端使用
Get-Service ssh-agent | Set-Service -StartupType Manual

# 启动ssh-agent服务，使其准备好接受 SSH 密钥并保持运行状态。
Start-Service ssh-agent

# 查该服务状态
Get-Service ssh-agent

# Now load your key files into ssh-agent
ssh-add <id_ed25519-path>
```

- 使用`git bash`内置shell[操作](https://docs.github.com/zh/authentication/connecting-to-github-with-ssh/working-with-ssh-key-passphrases)

生成文件如：
- id_ed25519 私钥
- id_ed2519_pub 公钥

打开公钥复制里面的内容

## 远程github配置ssh秘钥

1. 密钥生成后需要在github上配置密钥本地才可以顺利访问
2. 进入github右上角你账号的头像选择settings
3. 选择 SSH and GPG keys
4. 创建SSH Key
5. 输入有意义的Title内容
6. key栏输入复制的 `id_rsa_pub` 内容
7. Add SSH Key

## 仓库配置

生成仓库

```git
git init
```

查看仓库

```git
git remote
```

连接仓库

> ssh地址 : github创建的库中的链接
>
> 示例: `git@github.com:icons/Electron-Template.git`

```git
git remote add origin <仓库地址>
```

## 查看连接的仓库

```git
git remote -v
```

## 把本地库的内容推送到远程

### 参数:

-u : Git不但会把本地的master分支内容推送的远程新的master分支，还会把本地的master分支和远程的master分支关联起来

```git
git push origin master -u
```

本地更新内容,然后提交到远程Github仓库

```git
git push origin master
```
