常见库的源:

语法：

```shell
helm repo add 仓库名 仓库地址
```

- 一个热门团队的仓库:

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
```

- 微软chart仓库:

```shell
helm repo add stable http://mirror.azure.cn/kubernetes/charts
```

使用:

```shell
helm repo remove stable
helm repo add stable http://mirror.azure.cn/kubernetes/charts/
helm repo add incubator http://mirror.azure.cn/kubernetes/charts-incubator/
helm repo update
```

## 参考

https://blog.csdn.net/lwlfox/article/details/104880227
