## 给用户添加Token

通过官网安装的argocd没有apiKey权限, 需要编辑它的`argocd-cm`文件:

```shell
kubectl patch configmap -n argocd argocd-cm --type merge -p '{"data":{"accounts.admin":"apiKey","accounts.apikeyAccount":"apiKey,login"}}'
```

追加了如下内容: admin是用户名, 快捷但不安全的方式

```yaml
data:
  accounts.admin: apiKey
  accounts.apikeyAccount: apiKey,login
```

## 生成Token

admin:用户

```shell
argocd account generate-token --account admin
```

