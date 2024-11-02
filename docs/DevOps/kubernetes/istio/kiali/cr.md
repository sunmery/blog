配置CR：
1. [webui](https://kiali.io/docs/installation/installation-guide/accessing-kiali/#accessing-kiali-through-a-loadbalancer-or-a-nodeport)
```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  deployment:
    service_type: "NodePort"
```

2. 登录验证：
变量： [spec.auth.strategy](https://kiali.io/docs/configuration/kialis.kiali.io/#.spec.auth.strategy)
分为几种参数， 常见参数：
1. anonymous： 不校验
```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  auth:
    strategy: anonymous
```

2. token 使用toke
使用以下命令获取[token](https://kiali.io/docs/installation/installation-guide/example-install/#access-the-kiali-server-ui)：
```shell
kubectl get secret -n istio-system $(kubectl get sa kiali-service-account -n istio-system -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d
```