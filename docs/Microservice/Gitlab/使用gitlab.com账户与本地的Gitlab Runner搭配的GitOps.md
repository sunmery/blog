## 介绍

### 需求在哪里?

要知道, 一个CI的pipeline管道执行的效率与服务器的性能有很大关联, 内存配置越好, 带宽越高, 那么管道执行的速度也就越快,
那么CI/CD交付的速度也就越快, 而痛点就在于, 大多数公有云的服务器非常贵. 那么有没有一种方法, 可以利用现有的机器来运行Gitlab
Runner并可以与gitlab.com账户搭配使用呢? 答案是: yep!. 这就是本篇文章的由来. 那么也引出了几个问题:

1. gitlab.com账户能使用本地Gitlab Runner吗?
2. 本地机器没有公网IP或者域名, 是否能与gitlab.com互联吗?
3. 我该如何注册gitlab.com的账号?
4. 我该如何安装使用Gitlab Runner

解决方案:

1. 注册Gitlab.com账户
2. 本地机器安装与配置Gitlab Runner
3. 验证

## 注册Gitlab.com账户

建议使用Github账号来创建Gitlab账号, 访问`gitlab.com`创建即可
然后进行以下操作:

1. 本地化设置, 如果你更喜欢以中文显示的话.
   个人头像(profile) -> preferences -> Localization -> Language -> 选择你喜欢的语言
   ![[img/Pasted image 20240505135522.png]]

2. 添加ssh密钥, 注意, 如果你的Git源码机器与Gitlab Runner所在的机器不是同一台的话, 那么就需要同时添加两者的公钥, 否则Gitlab
   CI流水线在运行时会无法拉取Git仓库.
   ![[img/Pasted image 20240505134946.png]]

## 本地机器安装与配置Gitlab Runner

### 新建Runner

1. 进入gitlab.com, 创建一个项目, 进入到左侧栏的`设置` -> `CI/CD` -> `新建Runner`
   ![[img/Pasted image 20240505130202.png]]

来到新建项目Runner界面, 只需要关心标签的名字, 注意, 这里建议填写它的作用, 它将会在gitlab CI中发挥很重要的作用,
例如我需要利用这个Runner来对Golang项目进行打包, 那么就需要`go`这个软件包, 那么就需要再Gitlab Runner中使用`go`的镜像, 例如
`go:1.22.2`,那么这个标签名就可以填写`go1.22.2`,`go`等标签名, 方便使用者记忆和联想
![[img/Pasted image 20240505130355.png]]

之后点击蓝色`创建Runner`按钮, 它会显示一个`Token`,如红框所示.
这回答了第二个问题, Gitlab用于与Gitlab Runner的通信的一个标记
![[img/Pasted image 20240505130949.png]]

之后就可以在Linux发行版, Docker容器, Kubernetes中安装Gitlab Runner

### 在Docker安装Gitlab Runner

#### 安装Docker

需要在机器上安装Docker, 如果你是Linux发行版是`Ubuntu`或者使用`apt/apt-get`的发行版,
那么这里有现成的shell用于安装最新版的Docker:

```shell
# https://docs.docker.com/engine/install/ubuntu/
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli docker-buildx-plugin containerd.io docker-compose-plugin

sudo docker run hello-world
```

> 其它的发行版请参考`https://docs.docker.com/engine/install`

#### 安装Gitlab Runner

源码位于本人Github仓库: `https://github.com/Mandala-lab/docker-deploy/blob/main/gitlab/`

```shell
wget https://github.com/Mandala-lab/docker-deploy/blob/main/gitlab/runner/install.sh
chmod +x install.sh
```

需要定义的几个变量:

1. token: 即在`新建项目Runner界面`中显示的token参数, 例如`glrt-KhPfWzzS35C3mJsNWBQq`
2. img_name: 名称, 将作为Gitlab Runner容器的名称
3. config: 存储Gitlab Runner容器数据的路径, 例如`/home/gitlab/runner/runner1/config`

把对应内容填入引号中, 然后再机器上执行:

```shell
export token=""
export img_name=""
export config=""
./install.sh
```

#### 注册Gitlab Runner

1. 选择一个你需要的镜像,例如`node`与`go`,完整的镜像列表可在`https://hub.docker.com/`找到推荐几个镜像, 它们都非常小:

- node:18-alpine3.19
- golang:alpine

2. 把镜像填入引号中, 然后再机器上执行:

```shell
export image=""
wget https://github.com/Mandala-lab/docker-deploy/blob/main/gitlab/runner/register.sh
chmod +x register.sh
./register.sh
```

## 验证

在所有步骤都完成后, 即可进行测试, 查看它们是否正确的安装与配置Runner, 图中所示即为成功配置Gitlab Runner

### 创建示例仓库

```shell
git clone --depth 1 https://gitlab.com/lookeke/full-stack-engineering.git
```

### 编写Gitlab CI管道文件

```yml
stages:
  - build
  - build_image
  - deploy

# 显式的变量列表, 隐私的变量请使用gitlab的提供的变量选项
variables:
  PROJECT_PATH: "/home/kubernetes/microservice-shop"
  RUNNER_NODE_TAG: "node" # 包含 node 的git runner
  #RUNNER_DOCKER_TAG: "did2" # 包含 docker 的git runner
  RUNNER_DOCKER_TAG: "go" # 包含 docker 的git runner
  IMAGE_TAG: "v1.0.0" # 版本号
  #构建的前端项目镜像名称
  IMAGE_FRONTEND_NAME: "frontend"
  #构建的后端项目镜像名称
  IMAGE_BACKEND_NAME: "backend"
  #DOCKER_HOST: tcp://docker:2375

  # 在gitlab定义的变量:
  # HOST: argo所在的服务器的IP
  # USER: argo所在的服务器的用户名
  # SSHPASS: argo所在的服务器的密码
  # HARBOR_REGISTRY: Harbor的URL, 例如: harbor.local.com
  # HARBOR_REPO: Harbor的仓库名, 例如backend, 即Harbor的项目名称
  # HARBOR_USERNAME: Harbor的用户名
  # HARBOR_PASSWORD: Harbor的密码
  # ARGOCD_SERVER: argocd的IP/域名,不包含https://与.com

# 缓存, 下次Job利用时不需要重新下载
cache:
  key: ${frontend_PROJECT_NAME}
  paths:
    - node_modules
    - dist

# 定义前端构建作业
frontend_build:
  stage: build
  image: node:18-alpine3.19
  tags:
    - ${RUNNER_NODE_TAG}
  script:
    - echo "安装pnpm包管理器"
    - node -v
    - npm install pnpm -g
    - cd frontend && pnpm install
    - pnpm build
  only:
    - main
  artifacts:
    paths:
      - frontend/dist/
```

推送:

```shell
git add .
git commit -m "test: test gitlab ci script"
git push
```

查看Gitlab Runner是否正常运行:

![[img/Pasted image 20240505135655.png]]
