```yaml
# This workflow will build a golang project
# For more information see: https://docs.github.com/en/actions/automating-builds-and-tests/building-and-testing-go

name: Deploy backend application to production
run-name: Deploy backend application to production

# git add .; git commit -m "test: test github actions"
# git tag v1.1.8; git push; git push main v1.1.8
on:
  push:
    branches:
      - pre
      - main
    tags:
      - 'v*.*.*'
env:
  # 微服务所在目录
  SERVICE_DIR: user
  # 仓库
  REGISTER_NAMESPACE: e-commence
  # 版本号, git tag的标签名
  # https://docs.github.com/zh/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#github-context
  #VERSION: ${{ github.ref_name }}
  VERSION: v1.0.0
  # 目标的操作系统
  GOOS: linux
  # 目标的架构
  GOARCH: amd64
  # 目标架构列表,例如: linux/amd64,linux/arm64
  TARGET_PLATFORMS: linux/amd64
  # golang的镜像
  GO_IMAGE: golang:1.23.3-alpine3.20
  # 代理
  GO_PROXY: https://proxy.golang.org
  # golang环境变量
  CGO_ENABLED: 0
  # 等待部署完成的超时时间, 超时即为失败
  DEPLOY_TIMEOUT: 30s
  # 后端应用的命名空间
  BACKEND_NAMESPACE: tiktok
  # 后端应用的HTTP端口
  BACKEND_HTTP_PORT: 30001
  # 后端应用的GRPC端口
  BACKEND_GRPC_PORT: 30002

jobs:

  backend-test:
    runs-on: ubuntu-24.04
    strategy:
      matrix:
        service: [ addresses, balances, cart, checkout, credit_cards, order, payment, product, user ]  # 定义要并行执行的服务
    defaults:
      run:
        shell: bash
        working-directory: ${{ matrix.service }}
    # Service containers to run with `container-job`
    services:
      # Label used to access the service container
      postgres:
        # Docker Hub image
        image: postgres:17-alpine
        # Provide the password for postgres
        env:
          # 数据库用户名
          POSTGRES_USER: postgres
          # 数据库用户密码
          POSTGRES_PASSWORD: postgres
          # 此可选环境变量可用于为首次启动映像时创建的默认数据库定义不同的名称。如果未指定，则将使用 POSTGRES_USER 的值。
          POSTGRES_DB: postgres
        # Set health checks to wait until postgres has started
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        # Maps tcp port 5432 on service container to the host
        ports:
          - '5432:5432'
    steps:
      - # 检出仓库中的代码，确保脚本可以访问仓库中的所有文件
        name: Checkout repository
        uses: actions/checkout@v4

      -
        # 设置Go版本和缓存机制
        # https://github.com/actions/setup-go#caching-dependency-files-and-build-outputs
        name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.23'
          # 检查是否最新版
          check-latest: true
          # 检查项目中所有的go.sum, 对于单体和多服务的应用都生效
          cache-dependency-path: '**/go.sum'

      - name: Install migrate
        run: |
          curl -L https://github.com/golang-migrate/migrate/releases/download/v4.18.1/migrate.linux-amd64.tar.gz | tar xvz
          sudo mv migrate /usr/bin/
          which migrate

      - name: Run database migrate
        run: |
          export DB_SOURCE="postgresql://postgres:postgres@localhost:5432/postgres?sslmode=disable"
          if [ -d ${{ matrix.service }} ]; then
            echo "Migration directory exists. Running migrations..."
            # 运行迁移命令
            make migrate-up
          else
            echo "Migration directory does not exist. Skipping migrations."
          fi

      -
        # -short: 跳过耗时久的test
        name: Go test
        run: |
          go test -short -coverprofile=coverage.out ./...
          go tool cover -html=coverage.out -o coverage.html

  backend-build:
    needs: backend-test
    name: Build image
    runs-on: ubuntu-24.04
    strategy:
      matrix:
        service_config:
          - { service: addresses, http_port: 30015, grpc_port: 30016 }
          - { service: balances, http_port: 30017, grpc_port: 30018 }
          - { service: cart, http_port: 30003, grpc_port: 30004 }
          - { service: checkout, http_port: 30005, grpc_port: 30006 }
          - { service: credit_cards, http_port: 30007, grpc_port: 30008 }
          - { service: order, http_port: 30009, grpc_port: 30010 }
          - { service: payment, http_port: 30011, grpc_port: 30012 }
          - { service: product, http_port: 30013, grpc_port: 30014 }
          - { service: user, http_port: 30001, grpc_port: 30002 }
    defaults:
      run:
        shell: bash
        working-directory: ${{ matrix.service_config.service }} # 动态指定工作目录
    steps:
      - # 检出仓库中的代码，确保脚本可以访问仓库中的所有文件
        name: Checkout repository
        uses: actions/checkout@v4

      - # 设置 QEMU 仿真器。允许你在 x86 架构的主机上构建和测试其他架构的 Docker 镜像
        # https://github.com/docker/setup-qemu-action
        name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      # - # Buildx 是 Docker 的一个插件，支持多平台构建
      #   name: Set up Docker Buildx
      #   uses: docker/setup-buildx-action@v3

      - # 缓存依赖项
        name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: ~/go/pkg/mod
          key: ${{ runner.os }}-go-modules-${{ hashFiles('**/go.sum') }}
          restore-keys: ${{ runner.os }}-go-modules-

      - # 登录到容器注册表
        name: Login Cloud Registry
        run: echo ${{ secrets.REGISTRY_PASSWORD }} | docker login ${{ secrets.REGISTRY }} --username ${{ secrets.REGISTRY_USERNAME }} --password-stdin

      - # 构建, 标记, 推送镜像到容器注册表
        name: Build tag and push image to Cloud Registry
        run: |
          docker build . \
            -t actions/${{ matrix.service_config.service }} \
            --build-arg GO_PROXY=$GO_PROXY \
            --build-arg GOIMAGE=$GO_IMAGE \
            --build-arg CGOENABLED=$CGO_ENABLED \
            --build-arg VERSION=$VERSION \
            --build-arg HTTP_PORT=${{ matrix.service_config.http_port }} \
            --build-arg GRPC_PORT=${{ matrix.service_config.grpc_port }} \
            --build-arg GOOS=$GOOS \
            --build-arg GOARCH=$GOARCH

          docker tag actions/${{ matrix.service_config.service }} ${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:$VERSION
          # docker tag actions/backend ${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:latest
          # docker tag actions/backend ${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:$GITHUB_SHA

          docker push ${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:$VERSION
          # docker push ${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:latest
          # docker push ${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:$GITHUB_SHA

  create-secrets:
    runs-on: ubuntu-24.04
    steps:
      - name: Install kubectl
        run: |
          curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl{,.sha256}"
          echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
          chmod +x ./kubectl
          cp ./kubectl /usr/local/bin

      - name: Write Kubernetes config file
        run: |
          mkdir -pv ~/.kube/
          echo "${{secrets.KUBE_CONF}}" > ~/.kube/config
          chmod 600 ~/.kube/config

      - name: Set Context
        uses: nick-fields/retry@v3
        with:
          timeout_seconds: 15
          max_attempts: 3
          retry_on: error
          command: |
            if kubectl get ns $BACKEND_NAMESPACE; then
            echo "namespaces $BACKEND_NAMESPACE already exists, skip create"
            else
            kubectl create ns $BACKEND_NAMESPACE
            fi

            kubectl config set-context --current --namespace $BACKEND_NAMESPACE

      - name: Create secret
        uses: nick-fields/retry@v3
        with:
          timeout_seconds: 15
          max_attempts: 3
          retry_on: error
          command: |
            kubectl delete secret db-source-secret --ignore-not-found
            kubectl delete secret redis-address-secret --ignore-not-found
            kubectl delete secret redis-username-secret --ignore-not-found
            kubectl delete secret redis-password-secret --ignore-not-found

            kubectl create secret generic db-source-secret --from-literal='DB_SOURCE=${{ secrets.DB_SOURCE }}'
            kubectl create secret generic redis-address-secret --from-literal='REDIS_ADDRESS=${{ secrets.REDIS_ADDRESS }}'
            kubectl create secret generic redis-username-secret --from-literal='REDIS_USERNAME=${{ secrets.REDIS_USERNAME }}'
            kubectl create secret generic redis-password-secret --from-literal='REDIS_PASSWORD=${{ secrets.REDIS_PASSWORD }}'

      # - name: Create secret
      #   run: |
      #     kubectl delete secret db-source-secret --ignore-not-found
      #     kubectl delete secret redis-address-secret --ignore-not-found
      #     kubectl delete secret redis-username-secret --ignore-not-found
      #     kubectl delete secret redis-password-secret --ignore-not-found
      #
      #     kubectl create secret generic db-source-secret --from-literal='DB_SOURCE=${{ secrets.DB_SOURCE }}'
      #     kubectl create secret generic redis-address-secret --from-literal='REDIS_ADDRESS=${{ secrets.REDIS_ADDRESS }}'
      #     kubectl create secret generic redis-username-secret --from-literal='REDIS_USERNAME=${{ secrets.REDIS_USERNAME }}'
      #     kubectl create secret generic redis-password-secret --from-literal='REDIS_PASSWORD=${{ secrets.REDIS_PASSWORD }}'

  backend-deploy:
    needs: backend-build
    runs-on: ubuntu-24.04
    strategy:
      matrix:
        service: [ addresses, balances, cart, checkout, credit_cards, order, payment, product, user ]  # 定义要并行执行的服务
    defaults:
      run:
        shell: bash
    steps:
      - # 检出仓库中的代码，确保脚本可以访问仓库中的所有文件
        name: Checkout repository
        uses: actions/checkout@v4


      - name: Install Argocd CLI
        run: |
          curl -LO https://github.com/argoproj/argo-cd/releases/download/v2.13.3/argocd-linux-amd64
          mv argocd-linux-amd64 argocd
          chmod +x ./argocd
          cp ./argocd /usr/local/bin

      # https://github.com/marketplace/actions/retry-step
      - name: Connect ArgoCD Server
        uses: nick-fields/retry@v3
        with:
          timeout_seconds: 15
          max_attempts: 3
          retry_on: error
          command: |
            argocd login \
            ${{ secrets.ARGOCD_SERVER_ADDR }} \
            --username ${{ secrets.ARGOCD_SERVER_USER }} \
            --password ${{ secrets.ARGOCD_SERVER_PASS }} \
            --insecure
            argocd version

      # - name: Connect ArgoCD Server
      #   run: |
      #     argocd login \
      #     ${{ secrets.ARGOCD_SERVER_ADDR }} \
      #     --username ${{ secrets.ARGOCD_SERVER_USER }} \
      #     --password ${{ secrets.ARGOCD_SERVER_PASS }} \
      #     --insecure
      #     argocd version

      - name: Connect Kubernetes Cluster
        run: |
          mkdir -pv ~/.kube/
          echo "${{secrets.KUBE_CONF}}" > ~/.kube/config
          chmod 600 ~/.kube/config

      - name: Set Context
        uses: nick-fields/retry@v3
        with:
          timeout_seconds: 15
          max_attempts: 3
          retry_on: error
          command: |
            if kubectl get ns $BACKEND_NAMESPACE; then
              echo "namespaces $BACKEND_NAMESPACE already exists, skip create"
            else
              kubectl create ns $BACKEND_NAMESPACE
            fi
            kubectl config set-context --current --namespace $BACKEND_NAMESPACE

      # - name: Set Context
      #   run: |
      #     if kubectl get ns $BACKEND_NAMESPACE; then
      #       echo "namespaces $BACKEND_NAMESPACE already exists, skip create"
      #     else
      #       kubectl create ns $BACKEND_NAMESPACE
      #     fi
      #
      #     kubectl config set-context --current --namespace $BACKEND_NAMESPACE

      - name: Deploy app to kubernetes
        uses: nick-fields/retry@v3
        with:
          timeout_seconds: 15
          max_attempts: 3
          retry_on: error
          command: |
            # 部署argo app资源清单
            echo "ls ${{ matrix.service_config.service }}/manifests/kustomize/overlays/production"
            ls ${{ matrix.service_config.service }}/manifests/kustomize/overlays/production
            kubectl apply -f ${{ matrix.service_config.service }}/application.yaml
            # 替换镜像
            argocd app set argocd/${REGISTER_NAMESPACE}-${{ matrix.service_config.service }} \
              --kustomize-image example=${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:$VERSION
      
            # 查看argocd的app信息
            argocd app list

      # - name: Deploy app to kubernetes
      #   run: |
      #     # 部署argo app资源清单
      #     kubectl apply -f ./application.yaml
      #
      #     # 替换镜像
      #     argocd app set argocd/${REGISTER_NAMESPACE}-${{ matrix.service_config.service }} --kustomize-image example=${{ secrets.REGISTRY }}/${REGISTER_NAMESPACE}/${{ matrix.service_config.service }}:$VERSION
      #
      #     # 查看argocd的app信息
      #     argocd app list

      - name: Watch app info
        uses: nick-fields/retry@v3
        with:
          timeout_seconds: 15
          max_attempts: 3
          retry_on: error
          command: |
            # kubectl rollout status deploy || kubectl rollout undo deploy
            kubectl get deploy -owide
            kubectl get po -owide
            kubectl get svc

      # - name: Watch app info
      #   run: |
      #     # kubectl rollout status deploy || kubectl rollout undo deploy
      #     kubectl get deploy -owide
      #     kubectl get po -owide
      #     kubectl get svc

```