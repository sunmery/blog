## 名称解释
1. Kubernetes: 容器编排
2. Jaeger: 用于监视和诊断分布式应用程序中的性能问题,主要用途是帮助开发人员和运维团队跟踪分布式应用程序的请求流程，以便识别和解决性能问题、延迟、错误和其他与分布式系统相关的问题。它可以帮助你了解应用程序中的各个组件之间的相互作用，包括微服务之间的通信和依赖关系。 属于监控大类的可观测性范畴
3. Jaeger Operator: 是Jaeger的[Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)的实现

## 前置条件
1. 一个运转正常的`Kubernetes`集群或者`minikube`之类的集群
2. JAEGER依赖`cert-manager`必须安装1.6.1或更高版本的`cert-manager`

## 安装

### 安装cert-manager
- 参考官方文档，使用`kubectl`安装[cert-manager](https://github.com/cert-manager/cert-manager)，所有参数使用默认值，这将会把[cert-manager](https://github.com/cert-manager/cert-manager)安装至`cert-manager`命名空间。
1. 访问[cert-manager](https://github.com/cert-manager/cert-manager/releases) 的版本页, 将`cert-manager.yaml`根据你的控制节点的网络情况下载或者直接下载复制到控制节点

> 截止2023/11/04, cert-manager版本为v1.13.2

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.2/cert-manager.yaml
```

查看`cert-manager`节点状态, `STATUS`状态大部分情况下全部为`Running`即可
> ct, 即kubectl, 个人自定义的简写

![[../images/Pasted image 20231104182628.png]]
### 安装JAEGER
1. 创建一个`可观测性`命名空间, 用于保存JAEGER等可观测性的Pod
```bash
kubectl create namespace observability
```

2. 创建JAEGER Operator

> 截止2023/11/04, Jaeger Operator版本为v1.49.0
> 截止2023/12/06, Jaeger Operator版本为v1.51.0

```bash
kubectl create -f https://github.com/jaegertracing/Jaeger-operator/releases/download/v1.51.0/Jaeger-operator.yaml -n observability
```

查看`Jaeger Operator`节点状态
```bash
kubectl get po -n observability
```

![[../images/Pasted image 20231104183158.png]]

## 资料
1. https://www.jaegertracing.io/docs/1.50/operator/
2. https://github.com/jaegertracing/jaeger-operator#jaeger-operator-for-kubernetes
3. https://www.jaegertracing.io/docs/1.50/getting-started/