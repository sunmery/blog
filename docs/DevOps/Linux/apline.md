安装
```
docker pull apline
```

运行
```
docker run -it apline /bin/sh
```

换源
```
 sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
```

常用组件
ssh, scp: openssh-client  
sshpass: sshpass
```
apk update  
apk add sshpass  
apk add openssh-client  
apk add scp  
apk info -e sshpass openssh-client scp ssh
```

Dockerfile:
打包和推送镜像
你需要将以下命令替换为你自己的仓库信息
```shell
cat > Dockerfile <<EOF
# 使用 alpine:latest 作为基础镜像
FROM alpine:latest

# 修改镜像源为中国科技大学的镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories

# 更新安装包索引并安装所需软件包
RUN apk update && \
    apk add --no-cache tar sshpass openssh-client
EOF
docker build -t lisa/alpine:latest .
docker tag lisa/alpine:latest ccr.ccs.tencentyun.com/lisa/alpine:latest
docker push ccr.ccs.tencentyun.com/lisa/alpine:latest
```
