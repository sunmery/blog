1. 修改配置文件
```shell
vim /etc/docker/daemon.json
```

2. 添加内容

上海交大镜像
[上海交大官网](https://mirrors.sjtug.sjtu.edu.cn/docs/docker-registry)

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.sjtug.sjtu.edu.cn"
  ]
}
```

3. 重启docker服务
```shell
systemctl restart docker.service
```

可能有帮助的[文章](https://cloud.tencent.com/developer/article/1806455)