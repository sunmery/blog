## 高级用法

1. 使用自定义values.yaml文件替换chats的值

```shell
helm upgrade --install argo argo-cd-6.7.18.tgz -f values.yaml -n cicd --create-namespace --reuse-values

helm pull kafka-ui/kafka-ui --untar
```

### [CLI](https://helm.sh/docs/helm/helm_install/)

- helm repo update 更新
- helm repo list 查看列表
- helm search repo stable 查看 stable 仓库可用的 charts 列表
- helm repo remove incubator 删除 incubator 仓库
- helm show chart stable/mysql 查看指定 chart 的基本信息
- helm show all stable/mysql 获取指定 chart 的所有信息
- helm install my-redis bitnami/redis ``[-n default]`` 指定 release 的名字为 my-redis，- n 指定部署到 k8s 的 namespace

- helm install bitnami/redis --generate-name 不指定 release 的名字时，需使用 –generate-name 随机生成一个名字
- helm ls
- helm list
- helm status my-redis
- helm uninstall my-redis 删除指定的release
- helm pull stable/mysql 拉取chart 到本地目录（现在所在的目录中）
- helm create nginx 创建生成一个模板

## 安装

1. 访问`https://github.com/helm/helm/releases/tag`下载对应操作系统版本, 截止`2023/10/11`最新版为`v3.13.1`,
   根据实际情况替换版本号:

```shell
wget https://get.helm.sh/helm-v3.13.1-linux-amd64.tar.gz
```

2. 上传

```shell
scp ./helm-v3.13.1-linux-amd64.tar.gz root@192.168.152:/
```

3. 解压

```shell
tar -zxvf /helm-v3.13.1-linux-amd64.tar.gz 
```

4. 移动二进制文件到PATH, 方便操作

```shell
mv /helm-v3.13.1-linux-amd64/linux-amd64/helm /usr/local/bin/
```

5. 自动补全

```shell
vi /etc/bash.bashrc

source <(helm completion bash)
```

## 参考

1. https://juejin.cn/post/7209977982950293561?searchId=202310212249153EA5159FC1BF8C2822A6
