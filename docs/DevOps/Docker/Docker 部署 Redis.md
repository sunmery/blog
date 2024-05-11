```shell

```


`docker-compose.yml`
```yml
version: '3'

services:
  redis-stand-alone:
    image: redis:latest
    restart: always
    volumes:
      - /data/redis/data:/data
      - /data/redis/redis.conf:/etc/redis/redis.conf
    container_name: redis
    ports:
      - "36379:36379"
    logging:
      options:
        max-size: "100m"
        max-file: "2"
```

`redis.conf`
```conf
# 绑定的 IP 列表
bind 0.0.0.0

# 以守护进程的方式运行，默认是 no
daemonize yes

# 日志等级
loglevel notice

# 日志文件
logfile "/data/redis/data/redis.log"

# 密码
requirepass 263393

# 主从模式设置: 主密码
# masterauth
# relicaof <masterip> <masterport> 主机ip地址和端口

# 端口
port 6539

# 数据库的数量
database 16

# 如果以后台的方式运行，我们就需要指定一个 pid 文件
pidfile /var/run/redis_6379.pid

# 保存 rdb 的错误校验
rdbchecksum yes

# rdb文件名
dbfilename dump.rdb

# rdb文件保存路径
dir /data/redis/data/rdb

# 900秒内至少有1个key被修改，就进行快照
sava 900 1
save 300 10

# 持久化如果出错，是否还需要继续工作
stop-writes-on-bgsave-error yes

# 是否压缩rdb文件
rdbcompression yes

# 开启aof, 默认为 no, 而且aof和rdb不能同时开启.默认是不开启aof模式的，默认是使用rdb方式持久化的，在大部分所有的情况下， rdb完全够用！
appendonly no

# 持久化文件名
appendfilename "appendonly.aof"

# always 每次修改都会 sync。消耗性能，但是数据完整性最好！
# everysec 每秒执行一次 sync，可能会丢失这1s的数据！
# no 不执行 sync，这个时候操作系统自己同步数据，速度最快 ！ 但是数据完整性最差！
appendfsync no

```