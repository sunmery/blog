[官网参数](https://redis.io/docs/management/config-file/)
[TLS](https://redis.io/docs/management/security/encryption/#certificate-configuration)
[RedisTLS 教程](https://devpress.csdn.net/redis/62ed1a027e668234661807b8.html)
[DockerHub](https://hub.docker.com/r/bitnami/redis)

参数:
- bind            # 监听ip，多个ip用空格分隔，监听所有的IP地址
- daemonize yes   # 允许后台启动
- logfile         # 日志路径
- dir             # 数据库备份文件存放目录
- masterauth      # slave连接master密码，master可省略
- requirepass     # 设置master连接密码，slave可省略
- appendonly       yes # 在/opt/apache/redis/data目录生成appendonly.aof文件，将每一次写操作请求都- 追加到appendonly.aof 文件中

常用:
```
## 安全
### 禁止特定命令
rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
rename-command flushdb b840fc02d524045429941cc15f59e41cb7be6c54
rename-command flushall b840fc02d524045429941cc15f59e41cb7be6c55

### 密码
requirepass 263393

###  绑定的 IP 列表
bind 127.0.0.1

# 主从模式设置: 主密码
# masterauth
# relicaof <masterip> <masterport> 主机ip地址和端口

#  端口
port 6539

# 以守护进程的方式运行，默认是 no
daemonize yes

## 日志
loglevel notice

### 日志文件
logfile "/data/redis/data/redis.log"

## 进程
### 数据库的数量
database 16

###  最大客户端连接数
maxclients 10000
###  如果以后台的方式运行，我们就需要指定一个 pid 文件
pidfile /var/run/redis_6379.pid

## 存储
###  保存 rdb 的错误校验
rdbchecksum yes

###  rdb文件名
dbfilename dump.rdb

###  rdb文件保存路径
dir /data/redis/data/rdb

### 900秒内至少有1个key被修改，就进行快照
sava 900 1
save 300 10

### 持久化如果出错，是否还需要继续工作
stop-writes-on-bgsave-error yes

### 是否压缩rdb文件
rdbcompression yes

###开启aof, 默认为 no, 而且aof和rdb不能同时开启.默认是不开启aof模式的，默认是使用rdb方式持久化的，在大部分所有的情况下， rdb完全够用！
appendonly no

###持久化文件名
appendfilename "appendonly.aof"

#  always 每次修改都会 sync。消耗性能，但是数据完整性最好！
# everysec 每秒执行一次 sync，可能会丢失这1s的数据！
# no 不执行 sync，这个时候操作系统自己同步数据，速度最快 ！ 但是数据完整性最差！
appendfsync no



```