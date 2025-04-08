## 新机安装

```shell
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y linux-generic-hwe-22.04
sudo update-grub
sudo reboot
```

### 更新

- sudo apt update 更新系统的软件包
- sudo apt upgrade 更新已安装的软件包
- sudo do-release-upgrade 更新系统版本
- sudo apt full-upgrade
- apt-mark showhold 查看被要求保留的软件包
- sudo apt-mark unhold 软件包名称 :解除某个软件包的保留状态(使其可以被正常升级或移除)

更新源出现问题:

```
Reading package lists... Done
E: Method https has died unexpectedly!
E: Sub-process https received signal 4.
```

错误原因: 网络连接问题、安全证书问题或软件包管理器与HTTPS服务器之间的通信问题引起
解决方案:
https://www.cnblogs.com/guangdelw/p/17616268.html
临时: 添加`GNUTLS_CPUID_OVERRIDE=0x1`

```
GNUTLS_CPUID_OVERRIDE=0x1 apt update -y
```

环境变量:
https://blog.csdn.net/qq_31173341/article/details/130557810
长期使用需要在/etc/environment文件中添加GNUTLS_CPUID_OVERRIDE=0x1

```shell
cat >> /etc/environment <<EOF
GNUTLS_CPUID_OVERRIDE=0x1
EOF
```

### 源

Ubuntu采用apt作为软件安装工具，其镜像源列表记录在/etc/apt/source.list文件中。

首先将source.list复制为source.list.bak备份。

```shell
cp /etc/apt/sources.list /etc/apt/sources.list.back
```

修改完成后保存source.list文件，需要执行命令后才能生效：

```shell
sudo apt update -y
```

本文为 Ubuntu 22.04 的阿里云镜像源列表。若为其他版本，将所有jammy更改为其他版本代号即可。
常用的Ubuntu版本代号如下：
Ubuntu 22.04：jammy
Ubuntu 20.04：focal
Ubuntu 18.04：bionic
Ubuntu 16.04：xenia

```shell
vim /etc/apt/source.list
```

将文件内容清空，然后复制下方代码粘贴，wq保存退出即可。

```
deb https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-security main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-updates main restricted universe multiverse

# deb https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse
# deb-src https://mirrors.aliyun.com/ubuntu/ jammy-proposed main restricted universe multiverse

deb https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ jammy-backports main restricted universe multiverse
```

## 资料

1. https://developer.aliyun.com/mirror/ubuntu
2. https://blog.csdn.net/fansnn/article/details/131236270
