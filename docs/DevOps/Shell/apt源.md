

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