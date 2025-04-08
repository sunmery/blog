## 应用场景

1. 对应用程序提供配置信息， 例如保持数据库的账号密码等， 这样就可以不修改程序重新上传程序的情况下对服务进行7x24小时对不间断稳定服务提供保证
2. 如果是账号密码等隐私信息， 使用Secret组件， 它能把信息进行加密， 默认是base64编码， 需要配合网络安全， 访问控制，
   身份认证等kubernetes的安全方式来组合使用
3. cm的存储的数据不可超过 1 MiB。如果你需要保存超出此尺寸限制的数据，你可能希望考虑挂载存储卷 或者使用独立的数据库或者文件服务
4. ConfigMap 的名字必须是一个合法的 DNS 子域名: DNS 子域名的定义可参见 [RFC 1123]。 这一要求意味着名称必须满足如下规则：
    1. 不能超过 253 个字符
    2. 只能包含小写字母、数字，以及 '-' 和 '.'
    3. 必须以字母数字开头
    4. 必须以字母数字结尾
5. Pod 和 ConfigMap 必须要在同一个 namespace 中。

## [使用](https://kubernetes.io/zh-cn/docs/tasks/configure-pod-container/configure-pod-configmap/)

### 根据文件来创建

1. 使用键名, 而不是默认使用的文件名来作为data名
    ```shell
    kubectl create configmap game-config-3 \
    --from-file=game-special-key=configure-pod-container/configmap/game.properties
    ```

   生成后就以你定义的`game-special-key`为键名, 而不是默认的`game`
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: game-config-3
    data:
      game-special-key: |
    ```

2. 基于文件创建cm
    ```shell
    kubectl create cm <filename> --from-file <file_path>
    ```

   示例:
    ```shell
    kubectl create cm kratos-config --from-file configs.yaml
    ```

   生成如下:
    ```yaml
    kind: ConfigMap
    metadata:
      creationTimestamp: "2024-05-16T02:52:53Z"
      name: kratos-config
      namespace: default
    apiVersion: v1
    data:
      configs.yaml: |+
        server:
          http:
            addr: 0.0.0.0:30001
            timeout: 1s
          grpc:
            addr: 0.0.0.0:30002
            timeout: 1s
        data:
          database:
            driver: mysql
            source: root:root@tcp(127.0.0.1:3306)/test?parseTime=True&loc=Local
          redis:
            addr: 127.0.0.1:6379
            read_timeout: 0.2s
            write_timeout: 0.2s
    ```

3. 从多个数据源创建 ConfigMap:
    ```shell
    kubectl create configmap game-config-2 --from-file=configure-pod-container/configmap/game.properties --from-file=configure-pod-container/configmap/ui.propertie
    ```

4. 使用--from-env-file 选项来对 env 文件创建 ConfigMap，例如：

   > 注意事项
   > Env 文件包含环境变量列表。其中适用以下语法规则:
   >
   >   Env 文件中的每一行必须为 VAR=VAL 格式。
   >
   >   以＃开头的行（即注释）将被忽略。
   >
   >   空行将被忽略。
   >
   >   引号不会被特殊处理（即它们将成为 ConfigMap 值的一部分）。

   规范的ENV文件示例:
    ```
    enemies=aliens
    lives=3
    allowed="true"
    
    # 此注释和上方的空行将被忽略
    ```

   示例:
    ```shell
    kubectl create configmap game-config-env-file \
           --from-env-file=configure-pod-container/configmap/game-env-file.properties
    ```

   输出如下:
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      creationTimestamp: 2019-12-27T18:36:28Z
      name: game-config-env-file
      namespace: default
      resourceVersion: "809965"
      uid: d9d1ca5b-eb34-11e7-887b-42010a8002b8
    data:
      allowed: '"true"'
      enemies: aliens
      lives: "3"
    ```

5. 从 Kubernetes 1.23 版本开始，kubectl 支持多次指定 --from-env-file 参数来从多个数据源创建 ConfigMap。

    ```shell
    kubectl create configmap config-multi-env-files \
    --from-env-file=configure-pod-container/configmap/game-env-file.properties \
    --from-env-file=configure-pod-container/configmap.properties
    ```

