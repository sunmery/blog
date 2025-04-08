## [首次使用](https://argo-cd.readthedocs.io/en/stable/getting_started/)

1. 获取密码

```shell
pwd=$(kubectl -n argocd get secret example-argocd-cluster -o jsonpath='{.data.admin\.password}' | base64 -d)
echo $pwd
```

2. CLI登录
   可选:

- --insecure: 忽略TLS验证
- --grpc-web

```
lb_ip=$(kubectl get service example-argocd-server -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' -n argocd)
argocd login \
$lb_ip \
--username admin \
--password $pwd \
--insecure
```

3. 修改密码

```
argocd account update-password
```

4. (可选)列出当前集群上下文

```
kubectl config get-contexts -o name
```

5. (可选)添加集群权限级别的RBAC,即可在任意ns创建/删除应用(需要注意安全性), 示例:

```
argocd cluster add kubernetes-admin@kubernetes
```

之后进入到快速使用来创建项目(project)和创建应用(application), 使用项目来管理应用

## 创建项目

https://argo-cd.readthedocs.io/en/stable/user-guide/projects/#managing-projects

1. 创建项目, 分配该项目权限

```
argocd proj create frontend
```

2. 添加仓库到项目
   语法

```
argocd proj add-source <PROJECT> <REPO>
```

示例:

```
argocd proj add-source frontend https://gitlab.com/lookeke/full-stack-engineering.git
```

查看proj的信息

```shell
argocd proj get frontend
```

删除

```
argocd proj remove-source <PROJECT> <REPO>
```

排除项目

```
argocd proj add-source <PROJECT> !<REPO>
```

排除项目的yaml清单:

```yaml
spec:
  sourceRepos:
    # Do not use the test repo in argoproj
    - '!ssh://git@GITHUB.com:argoproj/test'
    # Nor any Gitlab repo under group/ 
    - '!https://gitlab.com/group/**'
    # Any other repo is fine though
    - '*'
```

3. 添加/集群与命名空间

```
argocd proj add-destination <PROJECT> <CLUSTER>,<NAMESPACE>
```

示例:

```
argocd proj add-destination frontend https://kubernetes.default.svc,frontend
```

删除:

```
argocd proj remove-destination <PROJECT> <CLUSTER>,<NAMESPACE>
```

排除:

```
argocd proj remove-destination <PROJECT> !<CLUSTER>,!<NAMESPACE>
```

示例:

```
argocd proj add-destination frontend https://192.168.2.160:6443 frontend
```

yaml清单

```yml
spec:
  destinations:
  # Do not allow any app to be installed in `kube-system`  
  - namespace: '!kube-system'
    server: '*'
  # Or any cluster that has a URL of `team1-*`   
  - namespace: '*'
    server: '!https://team1-*'
    # Any other namespace or server is fine though.
  - namespace: '*'
    server: '*'
```

5. 创建APP

- --repo: 仓库URL
- --path: k8s部署清单目录相对仓库路径的位置, 也可以是URL
- --dest-server: 使用的Kubernetes集群
- --dest-namespace default: 部署在什么命名空间
- --sync-option CreateNamespace=true: 自动创建命名空间

```
argocd app create <app> \
--repo https://github.com/argoproj/argocd-example-apps.git \
--path <app> \
--dest-server https://kubernetes.default.svc \
--dest-namespace <namespace>
--sync-option CreateNamespace=true
```

yaml清单:

```yaml
apiVersion: argoproj.io/v1alpha1  # 指定 Argo CD API 版本
kind: Application  # 定义资源类型为 Application
metadata: # 元数据部分
  name: frontend   # 指定 Application 的名称
  namespace: frontend  # 指定 Application 所属的命名空间
  # 定义资源的 finalizers
  # https://argo-cd.readthedocs.io/en/stable/user-guide/app_deletion/#about-the-deletion-finalizer
  finalizers:
    - resources-finalizer.argocd.argoproj.io  # 删除时行级联删除
    #- resources-finalizer.argocd.argoproj.io/background  # 删除时后台行级联删除
spec: # 规范部分
  project: frontend  # 应用程序将被配置的项目名称，这是在 Argo CD 中应用程序的一种组织方式
  source: # 指定源
    # Kubernetes 资源清单在仓库中的路径
    path: frontend/ci
    # 指定 Git 仓库的 URL
    #repoURL: http://192.168.2.158:7080/root/full-stack-engineering.git
    repoURL: https://gitlab.com/lookeke/full-stack-engineering.git
    # targetRevision：想要使用的 git 分支
    targetRevision: HEAD
  # 部署应用到Kubernetes 集群中的位置
  destination:
    namespace: frontend  # 指定应用的命名空间
    server: https://192.168.2.160:6443  # 如果部署到同一集群，可以省略
  syncPolicy: # 指定同步策略
    automated: # 自动化同步
      prune: true  # 启用资源清理
      selfHeal: true  # 启用自愈功能
      allowEmpty: false  # 禁止空资源
    syncOptions: # 同步选项
      - Validate=false  # 禁用验证
      - CreateNamespace=true  # 启用创建命名空间
    retry: # 重试策略
      limit: 5  # 重试次数上限
      backoff: # 重试间隔
        duration: 10s  # 初始重试间隔
        factor: 2  # 重试间隔因子
        maxDuration: 3m  # 最大重试间隔

```

4. 手动同步:

```
argocd app sync <app>
```

删除app

```
argocd app delete guestbook
```

## 常用命令

列出已经创建的applications

```
kubectl -n argocd get applications
```

列出已经创建的Project

```
kubectl get appproject -n argocd
```

列出用户

```
argocd account list
```

```
kubectl patch -n argocd cm argocd-cm --type='json' -p='[{"op": "remove", "path": "/data/accounts.alice"}]'
```

获取特定用户信息

```
argocd account get --account <username>
```

生成token

```
argocd account generate-token --account admin
```

## 权限设置

RBAC权限示例:

```
p, role:admin, applications, *, */*, allow
p, role:admin, clusters, get, *, allow
p, role:admin, repositories, get, *, allow
p, role:admin, repositories, create, *, allow
p, role:admin, repositories, update, *, allow
p, rol:admin, repositories, delete, *, allow
p, role:admin, projects, get, *, allow
p, role:admin, projects, create, *, allow
p, role:admin, projects, update, *, allow
p, role:admin, projects, delete, *, allow
p, role:admin, logs, get, *, allow
p, role:admin, exec, create, */*, allow
g, admin, role:admin
```

验证RBAC权限:

- 验证包含rbac的yml或csv文件

```
argocd admin settings rbac validate --policy-file argocd-rbac-cm.yml
```

- 验证命名空间的argocd-rbac-cm.yml文件:

```
argocd admin settings rbac validate --namespace argocd
```

[测试策略](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#testing-a-policy)

```
argocd admin settings rbac can role:org-admin get applications --policy-file argocd-rbac-cm.yaml
```

## 全部指令

[语法](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd/):

```
argocd [option]
```

选项:

```shell
      --auth-token string               Authentication token
      --client-crt string               Client certificate file
      --client-crt-key string           Client certificate key file
      --config string                   Path to Argo CD config (default "/home/user/.config/argocd/config")
      --controller-name string          Name of the Argo CD Application controller; set this or the ARGOCD_APPLICATION_CONTROLLER_NAME environment variable when the controller's name label differs from the default, for example when installing via the Helm chart (default "argocd-application-controller")
      --core                            If set to true then CLI talks directly to Kubernetes instead of talking to Argo CD API server
      --grpc-web                        Enables gRPC-web protocol. Useful if Argo CD server is behind proxy which does not support HTTP2.
      --grpc-web-root-path string       Enables gRPC-web protocol. Useful if Argo CD server is behind proxy which does not support HTTP2. Set web root.
  -H, --header strings                  Sets additional header to all requests made by Argo CD CLI. (Can be repeated multiple times to add multiple headers, also supports comma separated headers)
  -h, --help                            help for argocd
  --http-retry-max int              Maximum number of retries to establish http connection to Argo CD server
  --insecure                        Skip server certificate and domain verification
  --kube-context string             Directs the command to the given kube-context
  --logformat string                Set the logging format. One of: text|json (default "text")
  --loglevel string                 Set the logging level. One of: debug|info|warn|error (default "info")
  --plaintext                       Disable TLS
  --port-forward                    Connect to a random argocd-server port using port forwarding
  --port-forward-namespace string   Namespace name which should be used for port forwarding
  --redis-haproxy-name string       Name of the Redis HA Proxy; set this or the ARGOCD_REDIS_HAPROXY_NAME environment variable when the HA Proxy's name label differs from the default, for example when installing via the Helm chart (default "argocd-redis-ha-haproxy")
  --redis-name string               Name of the Redis deployment; set this or the ARGOCD_REDIS_NAME environment variable when the Redis's name label differs from the default, for example when installing via the Helm chart (default "argocd-redis")
  --repo-server-name string         Name of the Argo CD Repo server; set this or the ARGOCD_REPO_SERVER_NAME environment variable when the server's name label differs from the default, for example when installing via the Helm chart (default "argocd-repo-server")
  --server string                   Argo CD server address
  --server-crt string               Server certificate file
  --server-name string              Name of the Argo CD API server; set this or the ARGOCD_SERVER_NAME environment variable when the server's name label differs from the default, for example when installing via the Helm chart (default "argocd-server")
```

- [argocd account](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_account/)- Manage account
  settings  
  argocd account - 管理帐户设置
- [argocd admin](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_admin/)- Contains a set of commands
  useful for Argo CD administrators and requires direct Kubernetes access  
  argocd admin - 包含一组对 Argo CD 管理员有用的命令，需要直接访问 Kubernetes
- [argocd app](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_app/)- Manage applications  
  argocd app - 管理应用程序
- [argocd appset](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_appset/)- Manage ApplicationSets  
  argocd appset - 管理应用程序集
- [argocd cert](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_cert/)- Manage repository
  certificates and SSH known hosts entries  
  argocd cert - 管理存储库证书和 SSH 已知主机条目
- [argocd cluster](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_cluster/)- Manage cluster
  credentials  
  argocd cluster - 管理集群凭据
- [argocd completion](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_completion/)- output shell
  completion code for the specified shell (bash or zsh)  
  argocd completion - 指定 shell（bash 或 zsh）的输出 shell 完成代码
- [argocd context](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_context/)- Switch between
  contexts  
  argocd context - 在上下文之间切换
- [argocd gpg](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_gpg/)- Manage GPG keys used for
  signature verification  
  argocd gpg - 管理用于签名验证的 GPG 密钥
- [argocd login](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_login/)- Log in to Argo CD  
  argocd login - 登录 Argo CD
- [argocd logout](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_logout/)- Log out from Argo CD  
  argocd logout - 从 Argo CD 注销
- [argocd proj](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_proj/)- Manage projects  
  argocd proj - 管理项目
- [argocd relogin](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_relogin/)- Refresh an expired
  authenticate token  
  argocd relogin - 刷新过期的身份验证令牌
- [argocd repo](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_repo/)- Manage repository connection
  parameters  
  argocd repo - 管理仓库连接参数
- [argocd repocreds](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_repocreds/)- Manage repository
  connection parameters  
  argocd repocreds - 管理存储库连接参数
- [argocd version](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_version/)- Print version
  information  
  argocd version - 打印版本信息
