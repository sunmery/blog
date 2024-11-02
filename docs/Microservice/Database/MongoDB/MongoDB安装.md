## Linux

[参考](https://blog.csdn.net/Amor_Leo/article/details/85858145)

1. docker pull mongo

2. 创建存储数据的文件夹

```shell
mkdir -p /data/mongodb/databases
```

3. 给所有权限

```shell
chmod 777 /data/mongodb/databases
```

4. 运行mongo程序
   -d 后台运行
   -v 运行路径
   -p 映射端口
   --privileged 获取systemctl权限
   -e MONGO_INITDB_ROOT_USERNAME=root 设置mongodb的root账号
   -e MONGO_INITDB_ROOT_PASSWORD=msdnmm 设置mongodb的root密码

放行端口
```shell
firewall-cmd --zon=public --add-port 27017/tcp --premanent
firewall-cmd --reload
```

运行示例
```shell
docker run \
-d \
--restart=always \
--name mongodb \
-v /data/mongodb/databases:/data/db \
-e MONGO_INITDB_ROOT_USERNAME=root \
-e MONGO_INITDB_ROOT_PASSWORD=msdnmm \
--privileged=true \
-p 27017:27017 mongo
```

## 社区版/企业版
[Mongo](https://www.mongodb.com/compatibility/docker)
[示例](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-enterprise-with-docker/)
1. 运行docker

> mac: 
> 添加此条命令： --platform linux/amd64

```bash
docker run \
--platform linux/amd64 \
--restart=always \
--name mongodb \
-v /data/mongodb/databases \
-d \
-p 27017:27017 \
-e MONGO_INITDB_ROOT_USERNAME=root \
-e MONGO_INITDB_ROOT_PASSWORD=msdnmm \
mongodb/mongodb-community-server //社区版
mongodb/mongodb-enterprise-server //企业版
```

2. 修改配置文件,不修改默认只为127.0.0.1(Docker本地)
[Mongodb](https://www.mongodb.com/docs/v4.4/core/security-mongodb-configuration/)
进入mongodb容器修改
使用`,`分割多IP
```shell
mongod --bind_ip 192.168.0.152,139.198.165.102
```
开通全部IP
- net.bindIpAll
- 0.0.0.0 IPV4
- ::,0.0.0.0 IPV6+IPV4
```shell
mongod --bind_ip net.bindIpAll
```

> 另类方式
```
find / -name "mongd.conf"
```

3.  修改为放行的端口, 示例为`net.bindIpAll`,即`0.0.0.0`
```
bindIp: net.bindIpAll
```
![[Pasted image 20230224143009.png]]

4. 查看是否正确
```shell
docker exec -it mongo bash
cat /etc/mongod.conf
```

5. 如不正确则返回第二步继续操作, 选择其他`mongod.conf`文件修改

6. 连接Mongo

```shell
mongo admin
```

7. 创建root账户
[参考](https://www.mongodb.com/docs/manual/reference/method/db.createUser/)
```shell
use admin
db.createUser(
	{
		user: 'root',
		pwd: 'admin',
		roles:[ { role: '<用户名>', db: '<授予的数据库>' } ]
	}
)
```

8. 连接

```shell
mongo -u <用户>
```

9. 创建用户
[角色权限参考](https://www.mongodb.com/docs/manual/reference/built-in-roles/#std-label-built-in-roles)
```shell
db.createUser(
	{
		user: '<用户名>',
		pwd: '<密码>',
		roles:[ { role: '<用户名>', db: '<授予的数据库>' } ]
	}
)
```

Q&A: 容器被占用,删除即可

```shell
docker rm -f <容器ID>
```

Q&A: 需要开放端口?
[参考](https://blog.csdn.net/chushiyan/article/details/104902491)
![[Pasted image 20220726121543.png]]

## Windows:

1. docker pull mongo
2. docker run --name mongo -d -p 27017:27017 mongo
3. docker exec -itd mongo

错误: CPU不支持AVX
检查当前电脑是否支持CPU的AVX指令
1. 进入`WSL`的命令行模式
2. 查看`/proc/cpuinfo`的`tags`字段是否包含`avx`,如果没有,则电脑不支持

```shell
cat /proc/cpuinfo 
```

解决方案:
不使用`mongo`5.x以上上版本