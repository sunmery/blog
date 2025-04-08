## 基本语法

单行优雅拆分为多行编写, 可读性高: `>`,

```yaml
script:
  - >
    docker build
    -t $IMAGE_TAG:$VERSION
    -f backend/Dockerfile backend
    --build-arg GO_IMAGE=golang:1.22.2-alpine3.19
    --build-arg ARCH=amd64
    --build-arg CGO_ENABLED=0
    --build-arg UID=10001
```

编写多行使用`|`,, 避免单行过长导致可读性降低

```yaml
script:
  - |
    docker build 
    -t $IMAGE_TAG:$VERSION 
    -f backend/Dockerfile backend 
    --build-arg GO_IMAGE=golang:1.22.2-alpine3.19 
    --build-arg ARCH=amd64 
    --build-arg CGO_ENABLED=0 
    --build-arg UID=10001
```

## [预定义的变量](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)

## 使用did时需要注意(Docker in Docker):

参考[官网教程](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-the-docker-executor-with-docker-socket-binding)

1. 注册时需要特权,使用`--docker-privileged`关闭runner的安全机制, 即需要宿主机的root权限
2. 需要挂载宿主机docker的套接字绑定到runner中, 在runner的config.toml配置文件编写, 即:

```toml
[[runners]]
  [runners.docker]
	volumes = ["/var/run/docker.sock:/var/run/docker.sock"]
```

3. gitlab ci作业文件需要修改, 在Docker v19.03或更高版本中，默认开启TLS，需要额外配置,
   参考[教程](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#docker-in-docker-with-tls-enabled-in-the-docker-executor)
   不需要TLS的例子:

```yml
variables:
  # 当使用dind服务时，你必须指示docker与服务内部启动的daemon对话。
  # 这个守护进程可以通a网络连接来使用，而不是默认的/var/run/docker套接字。
  # 如果你使用的是GitLab Runner 12.7或更早版本的Kubernetes执行器和Kubernetes 1.6或更早版本，由于
  # Kubernetes执行器的连接方式，该变量必须设置为tcp://localhost:2375
  DOCKER_HOST: "tcp://docker:2375"
  # 这指示Docker不要重新启动TLS。如果你没有TLS安全的需求, 仅适合非生产环境
  DOCKER_TLS_CERTDIR: ""

job_backend_build:
  stage: build
  #  variables:
  #    FF_NETWORK_PER_BUILD: "true"
  # 建议与你注册Runner选择的Docker镜像一致
  image: docker:26.1.0-dind-alpine3.19
  services:
    # 建议与你注册Runner选择的Docker镜像一致  
    - docker:26.1.0-dind-alpine3.19
  script:
  - echo 验证 Docker 是否正常工作
    - docker info
    - docker version
    - docker login -u $REGISTER_USERNAME -p $REGISTER_PASSWORD $REGISTER_ADDRESS
    - docker build -t $IMAGE_TAG:$VERSION -f backend/Dockerfile .
    - docker tag $IMAGE_TAG:$VERSION $REGISTER_ADDRESS/$REGISTER_REPO/$PROJECT_NAME_SERVER:$VERSION
    - docker push $REGISTER_ADDRESS/$REGISTER_REPO/$PROJECT_NAME_SERVER:$VERSION
    only:
      - main
```

https://blog.csdn.net/redrose2100/article/details/124224732

```yml
before_script:
  - echo "script in global before script..."

after_script:
  - echo "script in global after script..."

variables:
  USERNAME: redrose2100
  PASSWORD: admin123

workflow:
  rules:
    - if: '$USERNAME == "redrose2100"'
      when: always
    - when: never


stages:
  - build
  - test
  - release
  - deploy
  - verify

setup:
  stage: .pre
  script:
    - echo "script in pre..."
  tags:
    - docker_in_docker_demo

teardown:
  stage: .post
  script:
    - echo "script in post..."
  tags:
    - docker_in_docker_demo

build:
  stage: build
  before_script:
    - echo "before script in build..."
    - echo $USERNAME
    - echo $PASSWORD
  script:
    - echo "script in build..."
  after_script:
    - echo "after script in build..."
  tags:
    - docker_in_docker_demo
  rules:
    - if: '$USERNAME == "redrose2100"'
      when: manual
    - if: '$USERNAME == "redrose2200"'
      when: delayed
      start_in: "5"
    - when: on_success

test:
  stage: test
  before_script:
    - echo "before script in test..."
  script:
    - echo "script in test..."
  tags:
    - docker_in_docker_demo
  rules:
    - changes:
        - Dockerfile
      when: manual
  allow_failure: true
  parallel: 5


release:
  stage: release
  script:
    - echo "script in release..."
  after_script:
    - echo "after in release..."
  only:
    - tags
  tags:
    - docker_in_docker_demo
  when: delayed
  start_in: "10"

deploy:
  stage: deploy
  script:
    - echo "script in deploy..."
  tags:
    - docker_in_docker_demo
  when: manual

verify:
  stage: verify
  script: echo "in verify"
  retry: 2
  tags:
    - docker_in_docker_demo

verify-2:
  stage: verify
  script: echo "in verify-2"
  retry:
    max: 2
    when:
      - script_failure
  tags:
    - docker_in_docker_demo
  timeout: 3s
  only:
    - /^dev.*$/
  except:
    - branches

```
