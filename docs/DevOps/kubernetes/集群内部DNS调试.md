编辑部署一个包含网络调试工具的yaml文件:

```shell
cat <<EOF | kubectl apply -f -
# Source: net-tools.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: net-tools
  labels:
    k8s-app: net-tools
spec:
  selector:
    matchLabels:
      k8s-app: net-tools
  template:
    metadata:
      labels:
        k8s-app: net-tools
    spec:
      tolerations:
        - effect: NoSchedule
          operator: Exists
        - key: CriticalAddonsOnly
          operator: Exists
        - effect: NoExecute
          operator: Exists
      containers:
        - name: net-tools
          image: juestnow/net-tools
          command:
            - /bin/sh
            - "-c"
            - set -e -x; tail -f /dev/null
          resources:
            limits:
              memory: 30Mi
            requests:
              cpu: 50m
              memory: 20Mi
      dnsConfig:
        options:
          - name: single-request-reopen
EOF
```

进入Pod调试:

```shell
kubectl exec -it net-tools-gzn9z /bin/sh
```

进行DNS调试:

```shell
ping jaeger-collector.istio-system.svc.cluster.local
ping: bad address 'bing.com'
```

集群DNS用例:
直接编辑

```shell
kubectl edit cm coredns -n kube-system
```

or 导出后修改

```shell
kubectl get cm coredns -n kube-system -o > coredns.yaml
```

改成如下内容:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
  labels:
    addonmanager.kubernetes.io/mode: EnsureExists
data:
  Corefile: |
    .:53 {
        errors
        health {
            lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
            pods verified
            endpoint_pod_names
            fallthrough in-addr.arpa ip6.arpa
            ttl 30
        }
        prometheus :9153
        forward .  223.5.5.5:53 114.114.114.114:53 119.29.29.29:53 {
            max_concurrent 1000
        }
        cache 30
        reload 6s
        loadbalance
    }  
```

删除coredns pod以达到重启DNS目的, 删除完成之后等待重建Pod

```shell
kubectl delete cm/coredns-xx -n kube-system
```

之后喝杯Java, 等待几分钟, 最后进入net-tool进行测试DNS

## 资料

1. https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/
