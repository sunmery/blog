注入代理

```
kubectl label namespace bookinfo istio-injection=enabled
```

确保[入站网关（Ingress Gateway）](https://istio.io/latest/zh/docs/concepts/traffic-management/#gateways)配置文件没有问题:

```
istioctl analyze
```

查看istio Gateway

```
k get gw -A
```

VistualService:
Istio VistualService 中可以限制外部能够访问的路由地址，而 DestinationRule 则可以配置访问的 Pod 策略。可以为 Istio
VistualService 绑定一个 Istio DestinationRule，通过 DestinationRule 我们还可以定义版本子集等，通过更加丰富的策略转发流量。

```
kubectl get vs -A
```
