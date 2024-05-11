## Install
### Docker
https://blog.csdn.net/weixin_45821811/article/details/116211724

`docker-compose.yml`
```shell
export DATA_DIR="/home/redis/data"
export PORT="6379"
cat >minio-docker-compose.yml <<EOF
version: '3'

services:
  redis-stand-alone:
    image: redis:latest
    restart: always
    volumes:
      - $DATA_DIR:/data
      - $DATA_DIR/redis.conf:/etc/redis/redis.conf
    container_name: redis
    ports:
      - "$PORT:6379"
    logging:
      options:
        max-size: "100m"
        max-file: "2"
EOF
docker-compose -f minio-docker-compose.yml up -d
```
## 测试
```shell
docker exec -it redis redis-cli
auth password 
set s1 123
```