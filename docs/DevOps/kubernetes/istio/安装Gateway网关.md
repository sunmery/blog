## 安装

1. 本地机器可改为NodePort, 根据实际需要

```yaml
apiVersion: v1
kind: Service
metadata:
  name: istio-ingressgateway
  namespace: istio-ingress
spec:
  type: LoadBalancer
  #type: NodePort
  selector:
    istio: ingressgateway
  ports:
  - port: 80
    name: http
  - port: 443
    name: https
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: istio-ingressgateway
  namespace: istio-ingress
spec:
  selector:
    matchLabels:
      istio: ingressgateway
  template:
    metadata:
      annotations:
        # 选择网关注入模板（而不是默认的 Sidecar 模板）
        inject.istio.io/templates: gateway
      labels:
        # 为网关设置唯一标签。这是确保 Gateway 可以选择此工作负载所必需的
        istio: ingressgateway
        # 启用网关注入。如果后续连接到修订版的控制平面，请替换为 `istio.io/rev: revision-name`
        sidecar.istio.io/inject: "true"
    spec:
      # 允许绑定到所有端口（例如 80 和 443）
      securityContext:
        sysctls:
        - name: net.ipv4.ip_unprivileged_port_start
          value: "0"
      containers:
      - name: istio-proxy
        image: auto # 每次 Pod 启动时，该镜像都会自动更新。
        # 放弃所有 privilege 特权，允许以非 root 身份运行
        securityContext:
          capabilities:
            drop:
            - ALL
          runAsUser: 1337
          runAsGroup: 1337
---
# 设置 Role 以允许读取 TLS 凭据
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: istio-ingressgateway-sds
  namespace: istio-ingress
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: istio-ingressgateway-sds
  namespace: istio-ingress
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: istio-ingressgateway-sds
subjects:
- kind: ServiceAccount
  name: default

```

2. 最佳实践是创建新的命名空间:

```yaml
kubectl create namespace istio-ingress
```

3. 应用部署:

```shell
kubectl apply -f ingress.yaml
```

## 资料

1. https://istio.io/latest/zh/docs/setup/additional-setup/gateway/
2. https://istio.io/latest/zh/docs/tasks/traffic-management/ingress/ingress-control/#determining-the-ingress-ip-and-ports
