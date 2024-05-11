# Linux 环境安装Docker

#Linux #Docker
参考:
[Docker官方文档](https://docs.docker.com/engine/install/centos/)
[个人博客,不严谨](https://www.cnblogs.com/yang37/p/14464674.html)

## RockyLinux
```sh
sudo sed -i.bak -e "s|^mirrorlist=|#mirrorlist=|" -e "s|^#baseurl=|baseurl=|" -e "s|dl.rockylinux.org/\$contentdir|$MIRROR|" /etc/yum.repos.d/rocky-*.repo
```

## (可选)卸载现有的Docker

```Shell
sudo yum remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-engine
```

## 设置存储库

安装软件包（提供实用程序）并设置**稳定**存储库。`yum-utils``yum-config-manager`

```Shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# 可替换为国内源
https://download.docker.com/linux/centos/docker-ce.repo
```

## **可选**：启用**夜间**或**测试**存储库。

这些存储库包含在上述文件中，但默认情况下处于禁用状态。您可以与稳定存储库一起启用它们。以下命令启用**夜间**存储库。`docker.repo`

```Shell
sudo yum-config-manager --enable docker-ce-nightly
```

若要启用**测试**通道，请运行以下命令：

```Shell
sudo yum-config-manager --enable docker-ce-test
```

您可以通过运行带有该标志的命令来禁用**夜间**或**测试**存储库。要重新启用它，请使用该标志。以下命令禁用**夜间**
存储库。`yum-config-manager``--disable``--enable`

```Shell
sudo yum-config-manager --disable docker-ce-nightly
```

[了解**夜间**和**测试**频道](https://docs.docker.com/engine/install/)。

## 安装 Docker 引擎

1. 安装_最新版本_的 Docker 引擎和 containerd，

   ```Shell
   sudo yum install -y docker-ce docker-ce-cli containerd.io
   ```

或安装特定版本：
1. 搜索docker-ce版本
```sh
sudo yum list docker-ce --showduplicates | sort -r
```

2. 安装: 例如安装`3:20.10.9-3.el8`
```
sudo yum install -y docker-ce:1:20.10.8-3.el8 docker-ce-cli:1:20.10.8-3.el8 containerd.io
```

4. 启动 Docker。

    ```Shell
    sudo systemctl start docker
    sudo systemctl enable docker.service
    ```

3. 通过运行映像验证 Docker 引擎是否已正确安装。`hello-world`

```Shell
	sudo docker run hello-world
```

配置国内源
`vi /etc/docker/daemon.json`
添加如下
```json
"registry-mirrors": [
    "https://docker.mirrors.sjtug.sjtu.edu.cn"
]
```

#### 升级 Docker 引擎

要升级 Docker 引擎，请下载较新的包文件并重复[安装过程](https://docs.docker.com/engine/install/centos/#install-from-a-package)，使用 代替 ，然后指向新文件。

```Shell
yum -y upgrade
yum -y install
```

## 卸载 Docker 引擎

1. 卸载 Docker 引擎、CLI 和容器包：

   ```
   $ sudo yum remove docker-ce docker-ce-cli containerd.io
   ```

2. 主机上的映像、容器、卷或自定义配置文件不会自动删除。删除所有映像、容器和卷：

   ```
   $ sudo rm -rf /var/lib/docker
   $ sudo rm -rf /var/lib/containerd
   ```