```yaml
# 初始化运行时的工作, 用于创建基本的环境, 后续环境不再需要时, 把FIRST开关设为非true即可
#job_first_run:
#  stage: init
#  #  tags:
#  #    - ${DOCKER_TAG}
#  image: ccr.ccs.tencentyun.com/lisa/alpine:latest
#  script:
#    - |
#      cat > env_vars.sh <<EOF
#       #!/usr/bin/bash
#       export DOMAIN=${DOMAIN}
#       export NGINX_DIR=${NGINX_DIR}
#       export HTML_DIR=${NGINX_DIR}/html
#       export CONF_DIR=${NGINX_DIR}/conf
#       export SSL_DIR=${NGINX_DIR}/ssl
#      EOF
#    - chmod +x ./env_vars.sh
#    - ./env_vars.sh
#    - cat env_vars.sh
#    - tar -czf dist.tar.gz -C frontend/dist .
#    - sshpass -e scp -o stricthostkeychecking=no docker/nginx/first.sh env_vars.sh dist.tar.gz ${s_user}@${s_host1}:/tmp/
#    - sshpass -e ssh -o stricthostkeychecking=no ${s_user}@${s_host1} '
#      chmod +x /tmp/env_vars.sh
#      ; source /tmp/env_vars.sh
#      ; echo ${HTML_DIR}
#      ; tar -zxvf /tmp/dist.tar.gz -C ${HTML_DIR}
#      ; chmod +x /tmp/first.sh
#      ; source /tmp/first.sh
#      ; rm -rf /tmp/env_vars.sh
#      ; rm -rf /tmp/first.sh
#      ; rm -rf /tmp/dist.tar.gz
#      '
#  only:
#    variables:
#      - $FIRST == "true"
```
