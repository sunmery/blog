### 1、停止 Docker 服务

```bash
sudo systemctl stop docker
```

### 2、迁移或者备份
- 备份当前的 Docker 数据存储目录 `/var/lib/docker`

```bash
sudo mv /var/lib/docker /var/lib/docker.bak
```
- 迁移到新的存储库
```shell
sudo mv /var/lib/docker <newPath>
```

### 3、创建新的 Docker 数据存储目录，例如 `/data/docker`

```bash
sudo mkdir /data/docker
```

### 4、修改 Docker 配置文件

      修改 Docker 配置文件 `/etc/docker/daemon.json`，如果该文件不存在，则创建它：

```bash
sudo nano /etc/docker/daemon.json
```

将以下内容复制粘贴到文件中，并将其中的 `/data/docker` 替换为实际的数据存储路径： 

```bash
{"data-root": "/data/docker"
}
```

### 5、保存并关闭配置文件

### 6、启动 Docker 服务

```bash
sudo systemctl start docker
```

### 7、测试验证

确认 Docker 数据存储路径是否已经修改成功：

```bash
docker info | grep 'Docker Root Dir'
```

如果输出结果中显示的是新的数据存储路径，则说明修改成功。