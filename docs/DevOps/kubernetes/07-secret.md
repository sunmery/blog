## 类型

| 内置类型                                  | 用法                               |
| ------------------------------------- | -------------------------------- |
| `Opaque`                              |                                  |
| `kubernetes.io/service-account-token` | 服务账号令牌                           |
| `kubernetes.io/dockercfg`             | `~/.dockercfg` 文件的序列化形式          |
| `kubernetes.io/dockerconfigjson`      | `~/.docker/config.json` 文件的序列化形式 |
| `kubernetes.io/basic-auth`            | 用于基本身份认证的凭据                      |
| `kubernetes.io/ssh-auth`              | 用于 SSH 身份认证的凭据                   |
| `kubernetes.io/tls`                   | 用于 TLS 客户端或者服务器端的数据              |
| `bootstrap.kubernetes.io/token`       | 启动引导令牌数据                         |

默认为Opaque类型, 必须使用generic来声明
```shell
kubectl create secret generic
```

## Yaml定义
需要base64加密的值
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: redis-password
data:
  password: msdnmm
```

## 命令行定义
```shell
kubectl create secret generic redis-password --from-literal=redis-password=msdnmm,. -n redis-ha
```