## 具体表现
```
Failed to pull image "nginx": failed to pull and unpack image "docker.io/library/nginx:latest": failed to resolve reference "docker.io/library/nginx:latest": failed to do request: Head "https://registry-1.docker.io/v2/library/nginx/manifests/latest": tls: failed to verify certificate: x509: certificate is valid for *.twitter.com, twitter.com, *.x.com, x.com, not registry-1.docker.io
```

查看CoreDNS配置:
```yaml
kubectl get configmap coredns -n kube-system -o yaml
```

例如:
```yml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
```

查看CoreDNS日志:
```bash
kubectl logs -n kube-system -l k8s-app=kube-dns
```

## 解决方案

1. 尝试不使用系统的DNS配置文件, 在Kubernetes集群显式指定DNS服务器
```yml
apiVersion: v1
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes cluster.local in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        #forward . /etc/resolv.conf {
        forward . 1.1.1.1 1.0.0.1 8.8.8.8 223.5.5.5 {
           max_concurrent 1000
        }
        cache 30
        loop
        reload
        loadbalance
    }
kind: ConfigMap
```

2. 修改系统的`/etc/resolv.conf`DNS配置, 注意,有些云厂商的服务器不允许直接修改`/etc/resolv.conf`文件,需要修改对应的文件,具体询问对应的厂商
