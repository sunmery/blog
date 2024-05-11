## 前置
1. 已安装istio并正常
2. 安装样例文件
```shell
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.20/samples/httpbin/httpbin.yaml
```
3. 使用istio apis在80端口配置Gateway
```shell
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: httpbin-gateway
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "httpbin.example.com"
EOF

```
4. 配置路由
```shell
kubectl apply -f - <<EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - "httpbin.example.com"
  gateways:
  - httpbin-gateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        port:
          number: 8000
        host: httpbin
EOF

```

5. 设置环境变量
分几种情况:
1. helm安装的istio
Ingress Gateway 名称和命名空间都是 `istio-ingress`：

查看helm安装的istio:
```shell
helm ls -n istio-system
```

会列出以下资源:
```
NAME      	NAMESPACE   	REVISION	UPDATED                                	STATUS  	CHART        	APP VERSION
istio-base	istio-system	1       	2023-11-22 13:04:57.709170238 +0800 CST	deployed	base-1.20.0  	1.20.0
istiod    	istio-system	1       	2023-11-22 12:53:01.707353616 +0800 CST	deployed	istiod-1.20.0	1.20.0
```

导出ingress的svc名与命名空间名称
```shell
export INGRESS_NAME=istio-ingress
export INGRESS_NS=istio-ingress
```

2. yaml文件安装的istio Gateway:
默认的命名空间为`istio-ingress`, Service服务名称为`istio-ingressgateway`, 根据你的实际情况来修改

导出ingress的svc名与命名空间名称
```shell
export INGRESS_NAME=istio-ingress
export INGRESS_NS=istio-ingressgateway
```

3. 设置端口:
命令含义:
1. 获取istio-ingressgateway的http2 外部端口
2. 获取istio-ingressgateway的https 外部端口
3. 获取istio-ingressgateway的tcp 外部端口
```shell
export INGRESS_PORT=$(kubectl -n "${INGRESS_NS}" get service "${INGRESS_NAME}" -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

export SECURE_INGRESS_PORT=$(kubectl -n "${INGRESS_NS}" get service "${INGRESS_NAME}" -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

export TCP_INGRESS_PORT=$(kubectl -n "${INGRESS_NS}" get service "${INGRESS_NAME}" -o jsonpath='{.spec.ports[?(@.name=="tcp")].nodePort}')
```

如果`INGRESS_PORT`设置失败, 尝试把`http2`替换为`http`
因为是NodePort类型, `TCP_INGRESS_PORT`可能没有对应的输出

## 资料
1. https://istio.io/latest/zh/docs/tasks/traffic-management/ingress/ingress-control/#using-node-ports-of-the-ingress-gateway-service