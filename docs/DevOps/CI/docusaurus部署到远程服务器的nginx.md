
nginx.conf:
```conf

```

```shell
# 相对与根目录, 打包生成HTML后的目录, 例如build/dist
export c_dist_dir="build"

# 远程服务器的用户名, 应使用Gitlab CI来保护, 不要修改变量的名称
# export s_user=""

# 远程服务器的主机IP, 应使用Gitlab CI来保护, 不要修改变量的名称
# export s_host=""

# 远程服务器的密码, 应使用Gitlab CI来保护, 用于给sshpass这个工具使用, 不要修改变量的名称
# export SSHPASS=""

# 远程服务器的nginx的html目录
export s_html_dir="/home/nginx"

# 镜像名
export image_name="nginx-quic"

cat > .gitlab-ci.yml <<EOF
stages:
  - check
  - web
  - deploy

cache:
  key: nginx-quic
  paths:
    - ./node_modules

# 防止变量没有定义就被执行
job_check:
  stage: check
  image: alpine:latest
  tags:
    - did
  script:
    - if [ -z "${SSHPASS}" ] || [ -z "${s_user}" ] || [ -z "${s_host}" ]; then echo "至少一个变量未定义"; exit 1; fi

job_deploy:
  stage: deploy
  image: alpine:latest
  only:
    - main
  tags:
    - did
  script:
    - sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
    - apk update
    - apk add tar
    - apk add sshpass
    - apk add openssh-client
    - tar -czf dist.tar.gz -C build .
    - ls
    - sshpass -e scp -o stricthostkeychecking=no dist.tar.gz ${s_user}@${s_host}:${s_html_dir}
    - sshpass -e ssh -o stricthostkeychecking=no ${s_user}@${s_host} 'cd ${s_html_dir} && rm -rf html/* && tar -xzvf dist.tar.gz -C html && docker restart ${image_name}'
EOF
```

