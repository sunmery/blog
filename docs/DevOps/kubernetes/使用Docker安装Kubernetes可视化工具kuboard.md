
1. 创建存储
```shell
mkdir -p /home/docker/kuboard-data
```

2. shell:
Docker与Kubernetes 主节点在同一台集群上, 不在同一台把`KUBOARD_ENDPOINT`改成Kubernetes 主节点IP
```shell
docker run \
-d   \
--restart=unless-stopped  \
--name=kuboard \
-p 30080:80/tcp  \
-p 10081:10081/tcp  \
-e KUBOARD_ENDPOINT="http://0.0.0.0:80"   \
-e KUBOARD_AGENT_SERVER_TCP_PORT="10081" \
-v /home/docker/kuboard-data:/data \
swr.cn-east-2.myhuaweicloud.com/kuboard/kuboard:v3
```

参数解释

- 建议将此命令保存为一个 shell 脚本，例如 `start-kuboard.sh`，后续升级 Kuboard 或恢复 Kuboard 时，需要通过此命令了解到最初安装 Kuboard 时所使用的参数；
- 第 4 行，将 Kuboard Web 端口 80 映射到宿主机的 `80` 端口（您可以根据自己的情况选择宿主机的其他端口）；
- 第 5 行，将 Kuboard Agent Server 的端口 `10081/tcp` 映射到宿主机的 `10081` 端口（您可以根据自己的情况选择宿主机的其他端口）；
- 第 6 行，指定 KUBOARD_ENDPOINT 为 `http://内网IP`，如果后续修改此参数，需要将已导入的 Kubernetes 集群从 Kuboard 中删除，再重新导入；
- 第 7 行，指定 KUBOARD_AGENT_SERVER 的端口为 `10081`，此参数与第 5 行中的宿主机端口应保持一致，修改此参数不会改变容器内监听的端口 `10081`，例如，如果第 5 行为 `-p 30081:10081/tcp` 则第 7 行应该修改为 `-e KUBOARD_AGENT_SERVER_TCP_PORT="30081"`；
- 第 8 行，将持久化数据 `/data` 目录映射到宿主机的 `/root/kuboard-data` 路径，请根据您自己的情况调整宿主机路径；

## 访问 Kuboard v3.x

在浏览器输入 `http://your-host-ip:80` 即可访问 Kuboard v3.x 的界面，登录方式：

- 用户名： `admin`
- 密 码： `Kuboard123`

## 资料
1. https://kuboard.cn/install/v3/install-built-in.html#%E5%AE%89%E8%A3%85
2. https://github.com/eip-work/kuboard-press
3. https://cloud.tencent.com/developer/article/2330921
4. https://kuboard.cn/