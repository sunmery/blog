## 前置

安装之前卸载删除之前的Docker
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
## 安装
1. 设置存储库
```shell
sudo yum install -y yum-utils
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
```

> !如果按照官方教程使用yum安装了, 使用sed命令删除

```shell
sed -i -e 's/baseurl=https:\/\/download\.docker\.com\/linux\/\(fedora\|rhel\)\/$releasever/baseurl\=https:\/\/download.docker.com\/linux\/centos\/$releasever/g' /etc/yum.repos.d/docker-ce.repo
```

2. 安装Docker
```shell
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

3. 启动Docker
```shell
sudo systemctl start docker
```

4. 通过运行 `hello-world` 映像来验证 Docker 引擎安装是否成功。

```console
sudo docker run hello-world
```

## 优化设置
1. 自启
```shell
sudo systemctl enable docker
```

2. 添加源
```shell
vi /etc/docker/daemon.json
```
添加任意一个国内源
```json
{
	"registry-mirrors": [ 
	        "https://docker.mirrors.ustc.edu.cn" 
	    ]
}
```

示例:
```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "registry-mirrors": [
    "https://docker.mirrors.sjtug.sjtu.edu.cn"
  ]
}
```

## 参考资料
1. https://docs.docker.com/engine/install/rhel/
2. https://stackoverflow.com/questions/70358656/rhel8-fedora-yum-dns-causes-cannot-download-repodata-repomd-xml-for-docker-ce