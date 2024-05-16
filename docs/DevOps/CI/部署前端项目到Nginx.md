```shell

```

```yaml
stages:
  - init
  #  - test
  - build
  #  - first_run
  #  - deploy
  - verify

variables:
  # 是否需要初始化, 初始化的工作包含拉取和构建运行Web应用的镜像
  FRONTEND_INIT: "false"
  # 是否需要初始化, 初始化的工作包含创建argo的proj
  BACKEND_INIT: "true"

  # Web目录, 在远程服务器存在的目录
  NGINX_DIR: /home/nginx
  # 项目名称
  PROJECT_NAME: backend
  # 版本号
  VERSION: "v1.0.0"
  # 标签
  IMAGE_TAG: "backend"
  # 运行前端的runner tag
  FRONTEND_RUNNER: "node"
  # 运行后端的runner tag
  BACKEND_RUNNER: "go"
  # 运行Docker的runner tag
  DOCKER_RUNNER_TAG: "docker"
  # 客户端项目名称
  PROJECT_NAME_CLIENT: "frontend"
  # 服务端项目名称
  PROJECT_NAME_SERVER: "backend"

  # 当使用dind服务时，你必须指示docker与服务内部启动的daemon对话。
  # 这个守护进程可以通a网络连接来使用，而不是默认的/var/run/docker套接字。
  # 如果你使用的是GitLab Runner 12.7或更早版本的Kubernetes执行器和Kubernetes 1.6或更早版本，由于
  # Kubernetes执行器的连接方式，该变量必须设置为tcp://localhost:2375
  DOCKER_HOST: "tcp://docker:2375"
  # 这指示Docker不要重新启动TLS。如果远程注册表不是HTTPS, 就填写
  DOCKER_TLS_CERTDIR: ""

# 初始化运行时的工作, 用于创建基本的环境, 后续环境不再需要时, 把FIRST开关设为非true即可
job_frontend_init:
  stage: init
  image: ccr.ccs.tencentyun.com/lisa/alpine:latest
  script:
    - |
      cat > env_vars.sh <<EOF
       #!/usr/bin/bash
       export DOMAIN=${DOMAIN}
       export NGINX_DIR=${NGINX_DIR}
       export HTML_DIR=${NGINX_DIR}/html
       export CONF_DIR=${NGINX_DIR}/conf
       export SSL_DIR=${NGINX_DIR}/ssl
      EOF
    - chmod +x ./env_vars.sh
    - ./env_vars.sh
    - cat env_vars.sh
    - tar -czf dist.tar.gz -C frontend/dist .
    - sshpass -e scp -o stricthostkeychecking=no docker/nginx/first.sh env_vars.sh dist.tar.gz ${s_user}@${s_host1}:/tmp/
    - sshpass -e ssh -o stricthostkeychecking=no ${s_user}@${s_host1} '
      chmod +x /tmp/env_vars.sh
      ; source /tmp/env_vars.sh
      ; echo ${HTML_DIR}
      ; tar -zxvf /tmp/dist.tar.gz -C ${HTML_DIR}
      ; chmod +x /tmp/first.sh
      ; source /tmp/first.sh
      ; rm -rf /tmp/env_vars.sh
      ; rm -rf /tmp/first.sh
      ; rm -rf /tmp/dist.tar.gz
      '
  only:
    variables:
      - $FRONTEND_INIT == "true"

job_web_update:
  stage: deploy
  image: node:18-alpine
  script:
    - sshpass -e ssh -o stricthostkeychecking=no ${s_user}@${s_host1} 'docker exec -it nginx-quic nginx -s reload'
  only:
    - main
    - dev

job_frontend_nginx_deploy:
  stage: deploy
  image: ccr.ccs.tencentyun.com/lisa/alpine:latest
  only:

  script:
    - |
      cat > env_vars.sh <<EOF
        #!/usr/bin/bash
        export DOMAIN=${DOMAIN}
        export NGINX_DIR=${NGINX_DIR}
        export HTML_DIR=${NGINX_DIR}/html
        export CONF_DIR=${NGINX_DIR}/conf
        export SSL_DIR=${NGINX_DIR}/ssl
      EOF
    - chmod +x env_vars.sh
    - ./env_vars.sh
    - cat env_vars.sh
    - tar -czf dist.tar.gz -C frontend/dist .
    - sshpass -e scp -o stricthostkeychecking=no dist.tar.gz env_vars.sh ${s_user}@${s_host1}:/tmp/
    - sshpass -e ssh -o stricthostkeychecking=no ${s_user}@${s_host1} '
      chmod +x /tmp/env_vars.sh
      ; source /tmp/env_vars.sh
      ; echo "HTML_DIR: ${HTML_DIR}"
      ; tar -zxvf /tmp/dist.tar.gz -C ${HTML_DIR}
      ; docker restart nginx-quic
      ; rm -rf /tmp/env_vars.sh
      ; rm -rf /tmp/first.sh
      ; rm -rf /tmp/dist.tar.gz
      '
```
