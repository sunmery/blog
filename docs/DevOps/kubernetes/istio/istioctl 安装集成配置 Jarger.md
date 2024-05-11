## 前言
- 这教程是istio的Jarger的配置, 是istio写的Jarger配置文件, 不是Jarger官网的配置, 它是比较好集成了Jarger, 当然也只是简单的配置, 不包括性能和安全性问题
- 适用于使用Jarger搭配istio
- istio有helm和istioctl安装方式, 这里使用istioctl安装istio, 理由是比较简单安装
## 安装
https://istio.io/latest/zh/docs/setup/install/istioctl/

## 配置
1. 修改[github](https://raw.githubusercontent.com/istio/istio/release-1.19/samples/addons/jaeger.yaml)的配置文件, 把`ClusterIP`替换为`NodePort`, 启用Web UI
```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: istio-system
  labels:
    app: jaeger
spec:
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
        sidecar.istio.io/inject: "false"
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "14269"
    spec:
      containers:
        - name: jaeger
          image: "docker.io/jaegertracing/all-in-one:1.46"
          env:
            - name: BADGER_EPHEMERAL
              value: "false"
            - name: SPAN_STORAGE_TYPE
              value: "badger"
            - name: BADGER_DIRECTORY_VALUE
              value: "/badger/data"
            - name: BADGER_DIRECTORY_KEY
              value: "/badger/key"
            - name: COLLECTOR_ZIPKIN_HOST_PORT
              value: ":9411"
            - name: MEMORY_MAX_TRACES
              value: "50000"
            - name: QUERY_BASE_PATH
              value: /jaeger
          livenessProbe:
            httpGet:
              path: /
              port: 14269
          readinessProbe:
            httpGet:
              path: /
              port: 14269
          volumeMounts:
            - name: data
              mountPath: /badger
          resources:
            requests:
              cpu: 10m
      volumes:
        - name: data
          emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: tracing
  namespace: istio-system
  labels:
    app: jaeger
spec:
  type: ClusterIP
  ports:
    - name: http-query
      port: 80
      protocol: TCP
      targetPort: 16686
    # Note: Change port name if you add '--query.grpc.tls.enabled=true'
    - name: grpc-query
      port: 16685
      protocol: TCP
      targetPort: 16685
  selector:
    app: jaeger
---
# Jaeger implements the Zipkin API. To support swapping out the tracing backend, we use a Service named Zipkin.
apiVersion: v1
kind: Service
metadata:
  labels:
    name: zipkin
  name: zipkin
  namespace: istio-system
spec:
  ports:
    - port: 9411
      targetPort: 9411
      name: http-query
  selector:
    app: jaeger
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger-collector
  namespace: istio-system
  labels:
    app: jaeger
spec:
  type: ClusterIP
  ports:
  - name: jaeger-collector-http
    port: 14268
    targetPort: 14268
    protocol: TCP
  - name: jaeger-collector-grpc
    port: 14250
    targetPort: 14250
    protocol: TCP
  - port: 9411
    targetPort: 9411
    name: http-zipkin
  - port: 4317
    name: grpc-otel
  - port: 4318
    name: http-otel
  selector:
    app: jaeger
```
## 测试
查看Web UI的端口, 假设istio安装在istio-system这个命名空间:
```bash
kubectl get svc -n istio-system -owide
```

![[../images/Pasted image 20231105153636.png]]
![](/Users/art/Library/CloudStorage/OneDrive-aetcolor/Work/Operations/kubernetes/Pasted image 20231105153636.png)

Web UI的端口为`30976`, 浏览器访问即可:
![[../images/Pasted image 20231105153801.png]]

## 资料
1. https://istio.io/latest/docs/ops/integrations/jaeger/
2. https://istio.io/latest/zh/docs/setup/install/istioctl/
3. https://github.com/jaegertracing/jaeger
4. https://www.jaegertracing.io/docs/1.50/operator/#kubernetes