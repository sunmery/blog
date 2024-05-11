### minikube
minikube start 启动
minikube stop 停止集群
minikube delete --all 清空集群
minikube dashboard 可视化Web UI
minikube node add --worker 添加节点
更改默认内存限制（需要重新启动）：

```shell
minikube config set memory 9001
```
#### Service
https://minikube.sigs.k8s.io/docs/start/
示例部署并在端口 8080 上公开它：
```shell
kubectl create deployment hello-minikube --image=kicbase/echo-server:1.0
kubectl expose deployment hello-minikube --type=NodePort --port=8080
```
#### LoadBalancer
https://minikube.sigs.k8s.io/docs/start/
一个示例部署：
```shell
kubectl create deployment balanced --image=kicbase/echo-server:1.0
kubectl expose deployment balanced --type=LoadBalancer --port=8080
```
在另一个窗口中，启动隧道，为“平衡”部署创建可路由的 IP：
```shell
minikube tunnel
```
若要查找可路由的 IP，请运行以下命令并检查 `EXTERNAL-IP` 列：
```shell
kubectl get services balanced
```
#### Ingress
Enable ingress addon: 启用 ingress 插件：
```shell
minikube addons enable ingress
```
以下示例创建简单的 echo-server 服务和 Ingress 对象以路由到这些服务。
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
    - name: foo-app
      image: 'kicbase/echo-server:1.0'
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
    - port: 8080
---
kind: Pod
apiVersion: v1
metadata:
  name: bar-app
  labels:
    app: bar
spec:
  containers:
    - name: bar-app
      image: 'kicbase/echo-server:1.0'
---
kind: Service
apiVersion: v1
metadata:
  name: bar-service
spec:
  selector:
    app: bar
  ports:
    - port: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
spec:
  rules:
    - http:
        paths:
          - pathType: Prefix
            path: /foo
            backend:
              service:
                name: foo-service
                port:
                  number: 8080
          - pathType: Prefix
            path: /bar
            backend:
              service:
                name: bar-service
                port:
                  number: 8080
---
```
应用内容
```shell
kubectl apply -f https://storage.googleapis.com/minikube-site-examples/ingress-example.yaml
```

等待ingress地址
```shell
kubectl get ingress
NAME              CLASS   HOSTS   ADDRESS          PORTS   AGE
example-ingress   nginx   *       <your_ip_here>   80      5m45s
```

>注意事项：
 要使 ingress 正常工作，您需要打开一个新的终端窗口并运行 `minikube tunnel` ，并在以下步骤中使用 `127.0.0.1` `<ip_from_above>` 代替 .

现在验证入口是否正常工作:
```shell
curl <ip_from_above>/foo
Request served by foo-app
...

curl <ip_from_above>/bar
Request served by bar-app
...
```

## 配置
v1.24版本默认使用google镜像源, 改为`cn`使用为阿里云镜像源, v1.24以上不支持`Docker`, 使用`containerd`或其他容器技术代替
```sh
minikube start \
--image-mirror-country='cn' \
--container-runtime=containerd
```