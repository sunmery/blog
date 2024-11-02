## Gitlab

阅读该链接获取详细的 gitlab 与 gitlab-runner 安装
[[Work/工程化/Docker安装Gitlab]]
[Docker 安装与配置 Gitlab](https://juejin.cn/post/7205954522722828344)

### 安装 Gitlab

```bash
mkdir -p /data/gitlab/config
mkdir -p /data/gitlab/logs
mkdir -p /data/gitlab/data

docker run -d \
-h 192.168.0.152 \
-p 443:443 -p 7000:80 -p 2222:22 \
-e TZ=Asia/Shanghai \
--shm-size 256m \
--name gitlab \
--restart always \
-v /data/gitlab/config:/etc/gitlab \
-v /data/gitlab/logs:/var/log/gitlab \
-v /data/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest
```

### Gitlab-Runner

gitlab 需要 runner, 安装

```bash
mkdir -p /data/gitlab-runner5/config

docker run \
-d \
--name gitlab-runner \
--restart always \
-v /data/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

### 注册 Gitlab-Runner

注册一个或多个 gitlab-runner 对项目进行流水线作业

```bash
docker run \
-it \
-v /data/gitlab-runner/config:/etc/gitlab-runner \
gitlab/gitlab-runner:latest register
```

### 部署

#### 前端

##### Cache

key:

1. 缓存 node_modules,下一次的流水线无需全部安装一次(可优化点)
2. 保留 build 打包之后的 dist 目录,给下一个 Job 使用

###### init Job 部分

script 脚本解释:

1. 使用`node:14-alpine`容器对前端项目进行安装
2. (可选)项目使用`pnpm`包管理器, 所以全局安装`pnpm`使用
3. 打包项目

###### deploy Job 部分

- image:
  rockylinux: Ceontos 的替代发行版

- script 脚本解释:

1. 生成索引缓存索引提供搜索安装速度
2. 下载`sshpass`,`openssh-clients`用于`SSH`登录服务器
3. 进入打包后的`dist`目录,对里面所有文件进行压缩,并排除`node_modules`,压缩后名文件为`dist.tar.gz`
4. 设置生产服务器的密码的变量为`SSHPASS`,从 gitlab 的环境变量获取
5. 发送`dist.tar.gz`文件至生产服务器的`nginx`路径
6. 进入到生产服务器的`nginx`路径, 对`dist.tar.gz`文件进行解压, 解压完成后删除`dist.tar.gz`文件

```yml
stages:
  - web
  - golang
  - deploy

cache:
  key: edu_system
  paths:
    - ./web/node_modules
    - ./web/client/node_modules
    - ./web/client/dist
    - ./app
    - .cache

job_web:
  stage: web
  image: node:14-alpine
  tags:
    - edu-front-end
  script:
    - npm install pnpm -g
    - cd ./web && pnpm install && cd ./client && pnpm install
    - ls
    - pnpm eslint:fix && pnpm stylelint:fix && pnpm build
  only:
    - main
  artifacts:
    paths:
      - ./web/client/dist

job_golang:
  stage: golang
  image: golang:alpine
  tags:
    - edu-back-end
  script:
    - mkdir -p .cache
    - export GOPATH="$CI_PROJECT_DIR/.cache"
    - go env -w GOPROXY=https://proxy.golang.com.cn,direct
    - go get
    - go test ./test/
    - go build -o app
    - chmod +x app
  artifacts:
    paths:
      - ./app

job_deploy:
  stage: deploy
  image: rockylinux
  only:
    - main
  tags:
    - edu-front-end
  script:
    - yum makecache
    - yum install -y sshpass rsync openssh-clients
    - tar -czvf dist.tgz --exclude=node_modules -C ./web/client/dist . --remove-files
    - export SSHPASS="$PASSWORD"
    - sshpass -e scp -o stricthostkeychecking=no ./cmd/dir.sh ./dist.tgz root@192.168.0.158:/home/nginx/html/web/
    - sshpass -e ssh -o stricthostkeychecking=no root@192.168.0.158 'cd /home/nginx/html/web && tar -xzvf dist.tgz'
    - sshpass -e ssh -o stricthostkeychecking=no root@192.168.0.158 'cd /home/nginx/html/web bash ./dir.sh && rm -f ./dir.sh'
    - sshpass -e rsync -a -e "ssh -o stricthostkeychecking=no" --exclude="web" --exclude=".git" --exclude=".cache" --exclude=".idea" --exclude="tmp" . root@192.168.0.158:/home/nginx/html/web/temp
    - sshpass -e ssh -o stricthostkeychecking=no root@192.168.0.158 'cd /home/nginx/html/web/temp && rm -rf ./dist.tgz && bash ./cmd/deploy.sh'
```

#### Golang

```yml
stages:
  - build
  - deploy

# 设置缓存,设置需要保存的产物 下一个Job不会保存前一个Job的资源
cache:
  key: go-build # 如果设置多个Key, 有相同的key会覆盖
  paths:
    - app # 需要保存的产物

# 打包Golang项目为二进制文件
job_build:
  stage: build
  image: golang # 利用Golang容器进行打包Golang项目
  tags:
    - golang
  script:
    - go env -w GOPROXY=https://goproxy.cn,direct
    - go get
    - go build -o app
    - chmod +x app

job_deploy:
  stage: deploy
  image: rockylinux
  only:
    - main
  tags:
    - golang
  script:
    - yum makecache # 生成索引缓存索引提供搜索安装速度
    - yum install -y sshpass  openssh-clients
    - export SSHPASS="$PASSWORD" # 密码,从gitlab的环境变量设置与获取
    - sshpass -e scp -o stricthostkeychecking=no ./dir.sh root@192.168.0.158:/ # sshpass -e 从环境变量获取密码 scp -o stricthostkeychecking=no 忽略RSA Key检查信息
    - sshpass -e ssh -o stricthostkeychecking=no root@'192.168.0.158' 'cd / && bash dir.sh && rm -rf dir.sh'
    - sshpass -e scp -o stricthostkeychecking=no ./app ./Dockerfile ./deploy.sh root@192.168.0.158:/home/temp # sshpass -e 从环境变量获取密码 scp -o stricthostkeychecking=no 忽略RSA Key检查信息
    - sshpass -e ssh -o stricthostkeychecking=no root@'192.168.0.158' 'cd /home/temp && bash deploy.sh' #执行 sh
```

Dockerfile

```dockerfile
# 从alpine镜像运行
FROM alpine

# 映射的端口
EXPOSE 4000
# 从宿主机./app复制到容器的目录/app
COPY . /

# 查看信息
RUN pwd
RUN ls

# 启动容器时运行app二进制文件
ENTRYPOINT ["/app"]

```

### 排除 Web 目录

在项目根目录创建`.dockerignore`并写入需要排除的文件

```
/web
```

创建临时目录
dir.sh

```sh
#!/bin/bash

# 需要创建的目录
dir=/home/temp
# 列出该目录所有文件
res=$(ls -A $dir)
# 检查该目录是否有文件, 没有则创建
if [ -z "$res" ]; then
  rm -rf /home/nginx/html/web/temp
else
 mkdir -p /home/temp
fi
```

deploy.sh

```sh
#!/bin/bash

# 检测goimage(.gitlab-ci.yml提供的golang打包后的二进制文件的名称)是否已在运行, 如果已在运行则停止该容器
# docker ps 列出Docker容器列表
# grep goimage 搜索docker ps 列出Docker容器列表有没有goimage这个字串
# awk '{print $12}' 从docker ps 列出Docker容器列表的第12列(容器名)
# docker stop goimage 停止运行goimage容器
if [ $(docker ps | grep goimage | awk '{print $12}') ]; then docker stop goimage; fi

# 如果goimage容器存在 则删除该容器
# docker ps -a 列出全部容器
# docker ps -q 静默模式,只列出容器编号
# docker ps -aq 列出全部容器编号
# --filter name=goimage 过滤出容器名称为goimage的容器
# docker rm -f goimage 删除goimage容器
if [ $(docker ps -aq --filter name=goimage) ]; then
  docker rm -f goimage
fi

# docker images 列出所有镜像
# docker rmi -f 强制删除
# docker rmi -f goimage 强制删除goimage镜像
if [ $(docker images | grep goimage | awk '{print $1}') ]; then docker rmi -f goimage; fi

# 在Dockerfile当前目录的所有文件的镜像打包至标签为goimage的二进制文件可运行的Docker镜像
# docker build --tag 镜像的名字及标签，通常 name:tag 或者 name 格式；可以在一次构建中为一个镜像设置多个标签。

docker build --tag goimage -f /home/nginx/html/web/temp/Dockerfile .

# docker run 运行ddd
# -d 后台运行容器，并返回容器ID
# -p 映射主机与容器的端口
# --name 容器名称
pwd
docker run -d -p 4000:4000 --name goimage goimage

curl 192.168.0.158:4000/

```
