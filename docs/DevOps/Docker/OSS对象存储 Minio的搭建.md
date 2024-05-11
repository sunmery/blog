防火墙设置
```shell
firewall-cmd --zone=public --add-port=5000/tcp --permanent
firewall-cmd --zone=public --add-port=5001/tcp --permanent
firewall-cmd --zone=public --add-port=9000/tcp --permanent
firewall-cmd --zone=public --add-port=9090/tcp --permanent
firewall-cmd --reload
```
4. 运行配置
一个经过测试可运行的配置:
-  -p 5000:9000 // Linux主机`5000`端口,映射到`minio`的`9000`端口,用于访问文件时的URL
- -p 5001:9090 // Linux主机`5001`端口,映射到`minio`的`9090`端口,用于访问`Minio`控制台
- --name minio 容器名为`minio`
- -v /mnt/minio/data:/data 挂载Linux主机的`/mnt/minio/data`路径映射到`minio`的`data`目录
- -e "MINIO_ROOT_USER=root" 设置账号,账号为`root`
- -e "MINIO_ROOT_PASSWORD=msdnmmi,. 设置密码, 密码为`msdnmmi,.` 密码必须是8位数及以上
- --console-address ":9090" 控制台端口
```shell
mkdir -p /home/minio/data
chmod -R 777 /home/minio/data/
docker run \
-d \
--restart=always \
-p 9000:9000 \
-p 9090:9090 \
--name minio \
-v /home/minio/data:/data \
-e "MINIO_ROOT_USER=root" \
-e "MINIO_ROOT_PASSWORD=msdnmmi,." \
quay.io/minio/minio server /data \
--console-address "0.0.0.0:9090"
```

or

`docker.compose.yaml`
- image: 通过`https://github.com/minio/minio/releases/tag/`找到容器版本
- `MINIO_ROOT_USER` 和 `MINIO_ROOT_PASSWORD` 若未配置，则默认账号和密码均为 `minioadmin`；  
- `MINIO_BROWSER_REDIRECT_URL` 为 Console 管理平台登录网址，若不希望通过浏览器登录，可以增加 `MINIO_BROWSER: off`，禁止浏览器登录；  
- `MINIO_SERVER_URL` 为文件分享网址。若未设置，则默认为本身的容器 IP，不可正常使用。若使用了 nginx 反向代理，则更需要设置此参数；
```yaml
version: '3'
services:
  minio:
    image: quay.io/minio/minio
    container_name: minio
    volumes:
      - /data/minio/data:/data
    environment:
      - MINIO_ROOT_USER=root
      - MINIO_ROOT_PASSWORD=msdnmmi,.
    ports:
      - "5000:9000"
      - "5001:9090"
    command: server /data --console-address "0.0.0.0:9090"
    restart: always

```

## 参考
1. [Minio教程](https://min.io/docs/minio/container/index.html)
3. [简书](https://www.cnblogs.com/jetsung/p/minio-oss.html)