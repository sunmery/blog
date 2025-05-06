
不清理或许会导致的问题: docker buildx 无法使用存储, 而引发最外层抛出的表面错误:
![[d3f70f110d31abd0c91482bc2b7b7b23.png]]

问题
```
docker pull golang:1.24.0-alpine3.21

1.24.0-alpine3.21: Pulling from library/golang
failed commit on ref "config-sha256:d3f5bd625c1b89e695817c6a5b207a24563c30dcaa6b4c183c5fce51245ffe0d": commit failed: "config-sha256:d3f5bd625c1b89e695817c6a5b207a24563c30dcaa6b4c183c5fce51245ffe0d" failed size validation: 2324 != 2099: failed precondition
```

解决方案: 清理 Docker 的下载缓存和临时文件：
```bash
docker system prune -a
docker builder prune -a
```

清理 Buildx 缓存,保留最近24 小时使用的数据
```bash
docker buildx prune --filter until=24h -f
```

彻底清理所有 Buildx 缓存（谨慎操作！）
```bash
docker buildx prune -a -f
```

删除未使用的镜像、容器、卷和网络：

```bash
# 清理所有未使用的 Docker 资源（镜像、容器、卷、网络）
docker system prune -a -f --volumes
```



清理前:
![[Pasted image 20250427104253.png]]

清理后:
![[Pasted image 20250427104305.png]]