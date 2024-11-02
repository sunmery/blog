安装配置的yml
```yaml
# kuboard.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: kuboard
spec:
  selector:
    app: kuboard
  type: NodePort
  ports:
  - name: web
    protocol: TCP
    port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: kuboard
    labels:
      app: kuboard
spec:
    replicas: 1
    selector:
      matchLabels:
        app: kuboard
    template:
      metadata:
        labels:
          app: kuboard
      spec:
        containers:
        - name: kuboard
          image: eipwork/kuboard:v3
          ports:
          - containerPort: 80

```

应用
```shell
kubectl apply -f kuboard.yaml
```

查看端口
```shell
kubectl get svc
```

默认账号: admin
默认密码: Kuboard123
