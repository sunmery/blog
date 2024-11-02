
## Containerd 的 Docker 代替工具

## 安装
[github](https://github.com/containerd/nerdctl)

镜像加速
https://blog.csdn.net/IOT_AI/article/details/131975562
https://help.aliyun.com/zh/acr/user-guide/accelerate-the-pulls-of-docker-official-images
```shell
systemctl restart containerd
```

## 使用

登录
```shell
nerdctl login <image>
```

打包成镜像
```shell
nerdctl build -t <image_name> <filepath>
```

打标签
```shell
nerdctl tag [imageId] <image>:[tag] 
```

推送镜像 
```shell
nerdctl push <image>:[tag]
```

拉镜像
```shell
nerdctl pull <image>
```

运行容器
```shell
nerdctl run <image>
```

`docker-compose`
- 启动服务
```shell
nerdctl compose up
```

- 停止并删除服务 
```shell
nerdctl compose down
```

- 显示服务状态 
```shell
nerdctl compose ps
```

- 启动服务，并在启动完成后退出 
```shell
nerdctl compose start 
```

- 停止服务，但不删除服务 
```shell
nerdctl compose stop
```