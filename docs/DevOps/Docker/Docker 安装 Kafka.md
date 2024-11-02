## 无界面Kafka
https://hub.docker.com/r/bitnami/kafka
```yml
version: "3.5"  
services:  
  kafka1:  
      image: 'bitnami/kafka:3.3.1'  
      container_name: kafka1  
      user: root  
      ports:  
          - "9092:9092"  
          - "9093:9093"  
      environment:  
           KAFKA_ENABLE_KRAFT: yes # 允许使用kraft，即Kafka替代Zookeeper  
           KAFKA_CFG_PROCESS_ROLES: broker,controller # kafka角色，做broker，也要做controller  
           KAFKA_CFG_CONTROLLER_LISTENER_NAMES: CONTROLLER # 指定供外部使用的控制类请求信息  
           KAFKA_CFG_LISTENERS: PLAINTEXT://:9092,CONTROLLER://:9093 # 定义kafka服务端socket监听端口  
           KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP: CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT # 定义安全协议  
           KAFKA_KRAFT_CLUSTER_ID: LelM2dIFQkiUFvXCEcqRWA # 使用Kafka时的集群id，集群内的Kafka都要用这个id做初始化，生成一个UUID即可  
           KAFKA_CFG_CONTROLLER_QUORUM_VOTERS: 1@kafka1:9093 # 集群地址  
           ALLOW_PLAINTEXT_LISTENER: yes # 允许使用PLAINTEXT监听器，默认false，不建议在生产环境使用  
           KAFKA_HEAP_OPTS: -Xmx512M -Xms256M # 设置broker最大内存，和初始内存  
           KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE: true # 是否允许自动创建主题  
           KAFKA_CFG_ADVERTISED_LISTENERS: PLAINTEXT://:9092 # 定义外网访问地址（宿主机ip地址和端口）  
           KAFKA_BROKER_ID: 1 # broker.id，必须唯一  
      volumes:  
          - kafka1_data:/bitnami/kafka  
#      extra_hosts:  
#          - "kafka1:云服务器IP"  
#          - "kafka2:云服务器IP"  
#          - "kafka3:云服务器IP"  
  
volumes:  
  kafka1_data: /home/data/kafka
```
测试kafka Docker
0. 进入容器

```shell
docker exec -it <imagename> /bin/bash
```

1. 创建一个 Kafka 主题

使用以下命令可以创建一个名为 "test-topic" 的主题：

```shell
/opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server localhost:9092 --topic test-topic --partitions 1 --replication-factor 1
```
- `--bootstrap-server` 参数指定了 Kafka 服务器的地址和端口。在本地启动的情况下，通常是 `localhost:9092`。
- `--topic` 参数指定了要创建的主题的名称。
 - `--partitions` 参数指定主题的分区数。这里设置为 1。
- `--replication-factor` 参数指定主题的复制因子。这里设置为 1，表示只有一个副本。

1. 发送测试消息

使用以下命令可以发送一条测试消息到刚刚创建的主题：
```shell
echo "This is a test message" | bin/kafka-console-producer.sh --broker-list localhost:9092 --topic test-topic
```

这个命令使用 `bin/kafka-console-producer.sh` 工具将消息发送到指定的主题。确保替换 `localhost:9092` 和 `test-topic` 为你的 Kafka 服务器地址和主题名称。

3. 消费测试消息
使用以下命令可以从刚刚创建的主题中消费消息：

```shell
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning
```

这个命令使用 `bin/kafka-console-consumer.sh` 工具从指定的主题中消费消息，并且使用 `--from-beginning` 参数从最早的消息开始消费。

## 有界面kafka
[详细文档](https://docs.kafka-ui.provectus.io/overview/getting-started)

```yml
version: '3.5'
services:
  kafka:
    image: bitnami/kafka:latest
    container_name: kafka
    # 初始化一写数据 写入kafka的数据，会被保存在容器的/tmp/logs目录下
    command:
      - 'sh'
      - '-c'
      - '/opt/bitnami/scripts/kafka/setup.sh && kafka-storage.sh format --config "$${KAFKA_CONF_FILE}" --cluster-id "lkorDA4qT6W1K_dk0LHvtg" --ignore-formatted  && /opt/bitnami/scripts/kafka/run.sh' # Kraft specific initialise
    environment:
      - ALLOW_PLAINTEXT_LISTENER=yes # 允许使用PLAINTEXT监听器，默认false，不建议在生产环境使用
      - KAFKA_CFG_NODE_ID=1 # 节点id，必须唯一
      - KAFKA_CFG_BROKER_ID=1 # broker.id，必须唯一
      - KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=1@kafka:9093   # 集群地址
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT,INTERNAL:PLAINTEXT # 定义安全协议
      - KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER # 指定供外部使用的控制类请求信息
      - KAFKA_CFG_LOG_DIRS=/tmp/logs # 日志目录
      - KAFKA_CFG_PROCESS_ROLES=broker,controller # kafka角色，做broker，也要做controller
      - KAFKA_CFG_LISTENERS=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093,INTERNAL://0.0.0.0:9094 # 定义kafka服务端socket监听端口
      - KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true # 是否允许自动创建主题
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://192.168.2.158:9092,INTERNAL://kafka:9094 # 定义外网访问地址（宿主机ip地址和端口）
    ports:
      - "0.0.0.0:9092:9092"
    volumes:
      - /home/data/kafka/docker:/bitnami/kafka
      - /home/data/kafka/docker/config:/bitnami/kafka/config
      - /home/data/kafka/docker/data:/bitnami/kafka/data
      - /home/data/kafka/docker/logs:/bitnami/kafka/logs

  kafka-ui:
    image: provectuslabs/kafka-ui
    container_name: kafka-ui
    ports:
      - "9091:8080" # kafka-ui的Web端口
    restart: "always"
    environment:
      KAFKA_CLUSTERS_0_NAME: "lkorDA4qT6W1K_dk0LHvtg" # 集群id
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:9094 # 集群地址
    depends_on:
      - kafka

```

简单测试
```shell
docker run -it --rm -p 8082:8080 -e DYNAMIC_CONFIG_ENABLED=true provectuslabs/kafka-ui
```

