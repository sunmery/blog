1. 添加helm repo包
```shell
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
```
2. 下载解压helm repo[包](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator)(国内服务器推荐)
```shell
tar -xzvg opentelemetry-operator.tar.gz
```

3. 修改拉取helm repo包的`values.yml`的镜像配置, 使用国内镜像URL代替国外镜像(国内服务器推荐), 截止2023/11/24,ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator与otel/opentelemetry-collector-contrib的版本是v0.89.0, 这里使用Docker拉取之后上传至腾讯云的镜像容器服务,本镜像公开
```yaml
...
manager:
  image:
#    repository: ghcr.io/open-telemetry/opentelemetry-operator/opentelemetry-operator
    repository: ccr.ccs.tencentyun.com/lisa/opentelemetry
#    tag: v0.89.0
    tag: latest
  collectorImage:
#    repository: otel/opentelemetry-collector-contrib
    repository: ccr.ccs.tencentyun.com/lisa/otel-opentelemetry-collector-contrib
#    tag: 0.89.0
    tag: latest
...
```
4. 使用本地包安装
参数含义:
- test: 包名, 随便起, 加在k8s pod的前缀
- opentelemetry-operator: 下载解压下来的helm repo包的路径
- --set admissionWebhooks.certManager.enabled=false: 是否安装certManager
- -set admissionWebhooks.certManager.autoGenerateCert=true 是否自动生成自签名证书
- --namespace opentelemetry-operator-system: 安装到opentelemetry-operator-system这个命名空间(必须提前创建eg. kubectl create ns opentelemetry-operator-system)
- --values values.yaml 使用新配置覆盖helm repo包的配置(如果你直接修改了helm repo包的配置, 该参数不需要加)
```shell
helm install test opentelemetry-operator/ --set admissionWebhooks.certManager.enabled=false --set admissionWebhooks.certManager.autoGenerateCert=true --namespace opentelemetry-operator-system --values values.yaml
```

5. 检查
```shell
kubectl --namespace opentelemetry-operator-system get pod
```
![[images/Pasted image 20231124150412.png]]

## 资料
1. https://opentelemetry.io/docs/kubernetes/helm/
2. https://github.com/open-telemetry/opentelemetry-helm-charts
3. https://github.com/open-telemetry/opentelemetry-operator
4. https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator


## 资料
0. https://github.com/open-telemetry/opentelemetry-operator
1. https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector/examples
2. https://github.com/open-telemetry/opentelemetry-operator
3. https://github.com/open-telemetry/opentelemetry-operator/blob/main/tests/e2e/daemonset-features/00-add-scc.yaml
4. https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-operator