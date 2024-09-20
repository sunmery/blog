## 文件参考
https://docs.docker.com/reference/compose-file
## 命令参考
https://docs.docker.com/reference/cli/docker/compose/

> docker-compose不在需要docker-前缀

包含Dockerfile的指令
```yml
services:
  tiktok:
	# 打包时使用关键字build即可
    build:
      # 根据Dockercompose的Dockerfile所在的目录
      context: ./build/package/backend
      # dockerfile名
      dockerfile: Dockerfile
    image: tiktok
    container_name: tiktok
    restart: always
    ports:
      - "30001:30001"
      - "30002:30002"
    volumes:
      - ./configs:/data/conf
      - ./upload/video/cover:/app/upload/video/cover # 挂载视频上传的目录,ffmpeg生成的文件路径没有目录存在时不会自动创建目录, 为了大小, 一般不会上传视频和封面图
      - /home/ffmpeg-6.0-amd64-static:/usr/local/bin # 挂载宿主机的ffmpeg,不占用容器大量空间
    environment:
      - TZ=Asia/Shanghai
    command: ["/app/tiktok", "-conf", "/data/conf/production.yaml"]

```
同一个服务器的容器内部访问宿主机的端口, 或者称为一个容器与另外一个容器的通信
参考:[links](https://blog.csdn.net/gold0523/article/details/102467102)
```yml
version: '3'
services:
  nginx:
    image: nginx  # 这里需要替换成你的镜像名
    ports:
      - "8080:8080"
    restart: on-failure
    links:
      - tiktok
    volumes:
      - /home/tiktok/build/package/nginx/conf:/etc/nginx
    container_name: tiktok-proxy
  # 这里是被链接的容器名
  tiktok:
    image: tiktok # 这里需要替换成被链接的容器地址

```

1. **docker-compose up**：启动应用程序并创建容器。如果不存在，它会首先构建镜像。
2. **docker-compose down**：停止并删除容器、网络、和其它资源。默认情况下，它会移除容器，但保留卷和网络。
3. **docker-compose ps**：列出正在运行的容器和相关信息。
4. **docker-compose logs**：查看容器的日志。
5. **docker-compose build**：构建镜像。如果已经有构建好的镜像，可以使用 `--no-cache` 参数来避免使用缓存重新构建。
6. **docker-compose exec**：在正在运行的服务中执行命令，类似于 `docker exec`。
7. **docker-compose restart**：重启服务中的容器。
8. **docker-compose stop**：停止服务中的容器，但不会删除它们。
9. **docker-compose start**：启动服务中的已停止的容器。
10. **docker-compose up -d**：以后台方式启动应用程序。加上 `-d` 参数会让容器在后台运行。
11. **docker-compose down -v**：停止并删除容器、网络、卷、以及其它资源。使用 `-v` 参数会移除卷。
12. **docker-compose config**：检查并验证 `docker-compose.yml` 文件的语法。
13. **docker-compose pull**：从镜像仓库拉取服务所需的最新镜像。
14. **docker-compose scale**：设置服务的副本数，以水平扩展服务。
15. **docker-compose top**：查看正在运行的容器的进程。
16. **docker-compose version**：显示 Docker Compose 版本信

## 安装

1. 下载 https://github.com/docker/compose/releases
2. 上传(可选)
   `-i`: 秘钥文件, 如果服务器设置了秘钥登录

```shell
scp -i <pem-file> <docker-compose-file> <user>@host/usr/local/bin/docker-compose
```
3. 授权
```shell
sudo chmod +x /usr/local/bin/docker-compose
```
