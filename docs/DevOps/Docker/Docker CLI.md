#Docker #教程 #指令

## CLI

https://docs.docker.com/reference/cli/docker/

docker inspect 查看网络信息**

```
docker inspect <container_id_or_name>
```

查看特定的网络

```
docker network ls
docker network inspect <network name>
```

推送正在运行的容器

```shell
old_image="lisa/lib:nginx-http3"
new_image="ccr.ccs.tencentyun.com/lisa/lib:nginx-http3"
docker commit ${old_image}
docker tag ${old_image} ${new_image}
docker push ${new_image}
```

镜像清理
`-a` 或 `--all`: 清理所有的tag 为none镜像，包括未被任何容器引用的镜像。如果不使用 `-a`
选项，只会清理那些没有被任何容器引用的"悬空"镜像，而被正在运行的容器引用的镜像将不受影响。

```shell
docker image prune [option]
```

查看容器大小占用

```shell
docker image history <image_id>
```

打包镜像

```
docker build [--no-cache] -t <image-name> .
```

```shell
docker run -itd --privileged=true eeb6ee3f44bd /usr/sbin/init
```

将Docker的镜像加入到系统自启
语法:

```go
docker update --restart=always <image>
```

运行DockerFile

```shell
docker up docker-compose
```

```shell
docker status sshd 查看某个服务状态
docker --restart = always 停止运行容器时自动重启
docker --restart= on-failure:5 非0自动重启5次
docker start sshd 启动某个服务 把sshd 改成服务名称

systemctl enable sshd 把某个服务加入带启动项

systemctl stop sshd 停止某个

systemctl disable sshd 移除某个服务的自启动

systemctl restart sshd 重启某个服务
```

dicker rmi `<images>` 删除镜像

停止所有容器：
docker stop $(docker ps -a -q)

删除所有容器：
docker rm $(docker ps -a -q)

删除所有镜像：
docker rmi $(docker images -q)

```

## 查看容器相关信息

`docker inspect 容器名`

`docker commit <contID>`

