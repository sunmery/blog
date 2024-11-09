## CLI命令
https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#config


## 缩写
| 名称           | 缩写     | Kind        |
| ------------ | ------ | ----------- |
| namespaces   | ns     | Namespace   |
| deployments  | deploy | Deployment  |
| scrvices     | svc    | Service     |
| nodes        | no     | Node        |
| pods         | po     | Pod         |
| replicasets  | rs     | ReplicaSets |
| statefulsets | sts    | StatefulSet |
| ConfMap      | cm     | ConfMap     |

## 查看证书
包含证书和DNS地址
```shell
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text
```
## kubectl 

### 通用选项
- -o yaml/json 以yaml/json格式输出
- -A 列出资源的全部信息
- -owide 列出当前资源的详细信息

### endpoints 地址
```
k get endpoints <namespace>
```

### 获取Pod名字

```bash
export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")
```
### patch

替换字段或字段值, 例如:
将`spec.type`的值修改为: `NodePort`
```shell
kubectl patch svc simple-prod-query -n observability -p '{"spec":{"type":"NodePort"}}'
```
### uncordon 调度
将Pod变为可调度, 与污点/容忍度相关
语法:
```shell
kubectl uncordon <node-name>
```

### edit 编辑
编辑现有的资源
语法:
type: cm/ConfMap, po/Pods, svc/Service, deploy/Deployment...
```shell
kubectl edit <type>/<pod> 
```

选项:
- -n monitoring
- -o yaml
- -o yaml > a.yaml 以yaml/json格式输出并保存到coredns-config.yaml文件

示例:
```shell
ct edit svc/prometheus-k8s -n monitoring
```
### wait 等待
等待一组Pod/Deployment/Service/Certiflcate等资源完成

语法:
```bash
kubectl wait --for=<条件> <资源类型>/<资源名> [options]
```

示例: 等待一个命名空间为`default`的`deployment/opentelemetry-operator-controller-manager` deployment的资源的condition是Complete的时间300秒
```bash
kubectl wait --for=condition=Complete deployment/opentelemetry-operator-controller-manager -n default --timeout=300s
```

options:
- --timeout=300s 等待300s

### create 创建
语法:
```sh
kubectl create <options>
```
options:
- namespace/ns 创建命名空间
- deployment `<name>`创建一个deployment部署
	- --image `<image:version>`  镜像
	- --replicas 副本数量
serviceaccount `<服务账号名>` 创建一个服务账号

### config 
config current-context 查看当前上下文
config set-context $(ct config current-context) --namespace=`<ns>` 切换命名空间
切换到`dev`命名空间
```sh
kubectl config set-context $(kubectl config current-context) --namespace=dev
```

切换到默认命名空间
```sh
kubectl config set-context $(kubectl config current-context) --namespace=default
```

### run 运行
- --image=`<image>` 镜像
- --replicas=`<number>` 副本数量
- it 交互模式
- `--rm` 运行完毕自动删除Pod
- --namespace/ns `<ns>` 在命名空间中创建
示例: 以交互模式创建3个busybox副本,完成后销毁
```sh
run busybox --image-busybox -it --rm --replicas=3
```

### explain
```shell
kubectl explain sts.spec.serviceName
```

### exec 执行
exec -it `<pod>` -- `<shell>` `shell` shell解释器, 例如`sh`,`bash`

### expose
语法:
```sh
kubectl expose deploy/<pod-name> <options>
```

options:
- --name=`<service-name>` 服务名称
- --port=`<number>` 对外暴露端口
- --target-port=`<number>` 容器端口
- --type=`<ClusterIP/NodePort/ExternalName/LoadBalancer>`

示例: 对外开放Nginx的端口为8080
```sh
kubectl expose deploy/nginx --name=nginx --port=8080 --target-port=80
```

### get 获取
语法:
```sh
kubectl get [options]
```
options: 
- -o yaml > coredns-config.yaml 以yaml/json格式输出并保存到coredns-config.yaml文件
- get node/nodes 列出所有节点
	- -owide 列出详细的nodes信息
- get all 列出命名空间所有, 包括nodes, deployment, service,crd
- get pod 
	- -A 列出Pod信息
	- -owide 列出详细的pod信息
	- --show-labels 查看每个 Pod 的标签
	- -n=`"<ns-name>"` 查看命名空间的pod
	- -l "`<key=value>`"  查看某个标签所在的Pod
		- -o wide 查看某个标签所在的Pod的详细信息
- get deployment 
	- `<pod>` -o yaml >> app2.yaml 输出到文件,yaml可改为json格式
	- --show-labels 显示所有部署的标签
	- deploy/`<deployment-name>` --show-labels 显示`<deployment-name>`部署的标签
	- -l "`<key=value>`"  查看某个标签所在的Pod
		- -o wide 查看某个标签所在的Pod的详细信息
- get svc 获取service信息
- get describe service/svc `<service-name>`
- get rs 查看 Deployment 创建的 ReplicaSet
	- --watch 观察副本集(需要再另外终端进行扩容/减配方可观察)
- get hpa 查看自动缩放
- get ns 查看命名空间
- get serviceaccounts 列举你[当前名字空间](https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/namespaces/#setting-the-namespace-preference) 中的所有[服务账号](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-service-account/)资源
- get cert Secret的别名,存储隐私数据
- get clusterrolebindings 获取ClusterRole 的所有权元数据
	- -o yaml 以yaml形式输出
- `-w`: 使用watch模式，实时监视资源的变化，一旦有新的Pod被创建或者现有的Pod发生变化，将立即显示在命令行中
### set
set image deployment/deploy `<pod>` `<url>`  --record 给pod设置镜像并记录到历史记录
set image deploy/`<pod-name>` `<image-name>`=`<image:version>`
示例:
```sh
kubectl set image deploy/nginx nginx=nginx:1.23
```
### rollout 滚动更新
rollout status `<pod>` 查看 Deployment 上线状态
rollout history deploy/`<pod>` 查看项目历史版本
- --revision=`<version>` 查看版本信息
rollout undo deployment `<pod>` 回滚到上个版本
- --to-revision=`<version>` 回滚到指定版本
rollout restart deployment `<pod>` 重新部署pod(删除,重新生成pod)
rollout pause deployment `<deployment>` 暂停运行，暂停后，对 deployment 的修改不会立刻生效，恢复后才应用设置
rollout resume deployment `<deployment>` 恢复运行

### autoscale自动缩放
> 需要声明Pod的资源限制, 同时使用`Metrics Server`服务

语法:
```sh
kubectl autoscale deployment/<pod-name> [options] 
```

options:
- --min=`<number>` 
- --max=`<number>`
- --cpu-percent=`<number>` CPU维持在`<number>`值以下

### scale 副本操作
scale deployment `<deployment-name>` --replicas=`<number>` 扩展pod副本数量

### port-forward 端口操作
语法:
port-forward `<pod>` `[namespace]` `宿主port`:`容器port`
示例: 暴露在本地(localhost/127.0.0.1)的443端口
```sh
kubectl port-forward test-k8s-backend-fbf6d4d79-6bh94 443:443
```
选项:
- `--address 0.0.0.0` 将本地端口转发到指定的网络接口, 这里是`0.0.0.0`即所有的网络端口
### describe 描述
语法:
```sh
kubuctl describe pod <pod-name>
```
describe pod `<pod>` 查看pod的详细信息

### logs 日志信息
语法:
```sh
kubectl logs pod [-f] [-p] (pod | TYPE/NAME) [-c] [--tail=<num>]
```
- -f 持续查看日志
- -c `kubectl logs <pod-name> -c <container-name>` 显示指定 Pod 中指定容器的日志, `kubectl logs <pod-name> -c <container-1-name> -c <container-2-name>
`查看多个容器的 Pod 日志
- --tail=`<num-lines>` 查看最后几行日志，默认是最后 1
### delete 删除
语法:
```sh
kubuctl delete <option>
```
- delete svc `<service-name>` 删除service
- delete hpa `<pod-name>` 删除自动缩放
- delete ns `<ns-name>` 删除命名空间
- delete deployment `<deployment-name>` 删除deployment部署
- delete pod `<pod-name>` --force 强制删除
- delete  node `<node>` 删除node节点
参数: 
-f `<file>` 删除配置文件创建的kubernetes资源对象
--force: 强制删除
all: 选择全部
--all: 删除全部
#### 示例
```
k delete all --all
```

### cluster-info 集群信息
- kubectl cluster-info
	- - dump 调试

