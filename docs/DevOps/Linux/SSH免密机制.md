## 先前准备
```shell
vi /etc/ssh/sshd_config

RSAAuthentication yes

PubkeyAuthentication yes
```

## 原理
利用ssh的RSA加密算法的公钥与私钥进行加密与解密, 则不再需要密码作为key即可进行免密登录

## Use
把本机的`<file>.pub`公钥文件传输至远程主机的`~/.ssh/`, 并创建具有权限的`authorized_keys`

### 快速部署
```shell
export user="root"
export host="192.168.2.101"
#scp ~/.ssh/id_rsa.pub $user@$host:~/.ssh/authorized_keys
scp ~/.ssh/id_ed25519.pub $user@$host:~/.ssh/authorized_keys
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