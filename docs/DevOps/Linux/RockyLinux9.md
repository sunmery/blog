[静态IP](https://docs.rockylinux.org/zh/guides/network/basic_network_configuration/)

## 安装Docker
1. 安装之前卸载删除之前的Docker
```shell
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

rm -rf /var/lib/docker/
```

2. 设置存储库


```shell
sudo yum install -y yum-utils
sudo dnf config-manager     --add-repo     https://download.docker.com/linux/fedora/docker-ce.repo
```

> !如果按照官方教程使用yum安装了, 使用sed命令删除

```shell

sed -i -e 's/baseurl=https:\/\/download\.docker\.com\/linux\/\(fedora\|rhel\)\/$releasever/baseurl\=https:\/\/download.docker.com\/linux\/centos\/$releasever/g' /etc/yum.repos.d/docker-ce.repo
```


3. 安装Docker
```shell
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

4. 启动Docker
```shell
sudo systemctl start docker
```

5. 通过运行 `hello-world` 映像来验证 Docker 引擎安装是否成功。

```console
sudo docker run hello-world
```

5. 优化设置
```shell
sudo systemctl enable docker
```
