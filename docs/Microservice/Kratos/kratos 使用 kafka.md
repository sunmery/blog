仓库: https://github.com/sunmery/kratos-kafka.git

## 安装 kafka

Kafka 有多种部署方式, 这里仅演示 Kubernetes 安装的方法

Kubernetes跟着 https://strimzi.io/quickstarts/ 安装即可

Kubernetes安装kafka脚本:
```bash
set -o posix errexit -o pipefail

mkdir -p /home/kubernetes/kafka
cd /home/kubernetes/kafka

# 入门: https://strimzi.io/quickstarts/

kubectl create namespace kafka
# 单机版kafka, 它声明了100g的pv, 需要节点有sc的存储支持
# 更多的kafka安装:https://github.com/strimzi/strimzi-kafka-operator/tree/0.43.0/examples/kafka

# 应用 Strimzi 安装文件，包括 ClusterRoles、ClusterRoleBindings 和一些自定义资源定义 （CRD）。
# CRD 定义用于自定义资源（CR，例如 Kafka、KafkaTopic 等）的架构，您将用于管理 Kafka 集群、主题和用户
wget 'https://strimzi.io/install/latest?namespace=kafka'
mv 'latest?namespace=kafka' kafka.yml
kubectl create -f kafka.yml -n kafka
kubectl get pod -n kafka

# 创建 Apache Kafka 集群
# 创建新的 Kafka 自定义资源以获取单节点 Apache Kafka 集群：
# Apply the `Kafka` Cluster CR file

#wget https://strimzi.io/examples/latest/kafka/kraft/kafka-single-node.yaml
cat > lb-10Gi-kafka-single-node.yaml <<EOF
apiVersion: kafka.strimzi.io/v1beta2
kind: KafkaNodePool
metadata:
  name: dual-role
  labels:
    strimzi.io/cluster: my-cluster
spec:
  replicas: 1
  roles:
    - controller
    - broker
  storage:
    type: jbod
    volumes:
      - id: 0
        type: persistent-claim
        size: 10Gi
        deleteClaim: false
        kraftMetadata: shared
---

apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
  annotations:
    strimzi.io/node-pools: enabled
    strimzi.io/kraft: enabled
spec:
  kafka:
    version: 3.9.0
    metadataVersion: 3.9-IV0
    listeners:
      - name: plain
        port: 9092
        type: loadbalancer
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    config:
      offsets.topic.replication.factor: 1
      transaction.state.log.replication.factor: 1
      transaction.state.log.min.isr: 1
      default.replication.factor: 1
      min.insync.replicas: 1
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF

#kubectl apply -f kafka-single-node.yaml -n kafka
kubectl apply -f lb-10Gi-kafka-single-node.yaml -n kafka
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n kafka
```

## 测试

### Kubernetes

生产者: 
复制粘贴等它启动好之后显示 `>` 时输入任意数据, 然后退出
```bash
# 发送和接收消息
# 在集群运行的情况下，运行一个简单的生产者向 Kafka 主题发送消息（该主题是自动创建的）：
# 测试发送
kubectl -n kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.43.0-kafka-3.8.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic

```

消费者:
复制粘贴等它启动好之后显示你刚刚输入的数据, 如果没有显示, 那么安装没有成功
```bash
# 测试接收
# 要在不同的终端中接收它们，请运行：
kubectl -n kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.43.0-kafka-3.8.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning
```
### go 程序
创建简单的 go 程序来测试Kafka

> kafka 默认不允许隐式创建topic, 在测试时使用已有的 topic 即可, 例如`my-topic`

生产者代码: 
把`brokerAddress`替换成你的 kafka 服务地址
```go
package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/segmentio/kafka-go"
)

// Kafka 配置
var (
  brokerAddress := "192.168.3.125:9092" // Kafka 服务器地址
  topic := "my-topic"                   // Kafka 主题
)

func main() {
	// 创建一个 Kafka Writer，用于发送消息
	writer := kafka.NewWriter(kafka.WriterConfig{
		Brokers:  []string{brokerAddress}, // Kafka 服务器地址
		Topic:    topic,                   // Kafka 主题
		Balancer: &kafka.LeastBytes{},     // 负载均衡策略（按最小字节数分配）
	})

	defer writer.Close() // 程序结束时关闭 Writer

	// 发送消息
	for i := 0; i < 10; i++ {
		msg := fmt.Sprintf("Message %d", i) // 消息内容
		err := writer.WriteMessages(context.Background(), kafka.Message{
			Key:   []byte(fmt.Sprintf("Key-%d", i)), // 消息的 Key（可选）
			Value: []byte(msg),                      // 消息的 Value
		})
		if err != nil {
			log.Fatalf("Failed to write message: %v", err)
		}
		fmt.Printf("Produced message: %s\n", msg)
		time.Sleep(1 * time.Second) // 每秒发送一条消息
	}
}

```

消费者代码:
把`brokerAddress`替换成你的 kafka 服务地址
```go
package main

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/segmentio/kafka-go"
)

func main() {
	// Kafka 配置
	topic := "my-topic"                   // Kafka 主题
	brokerAddress := "192.168.3.125:9092" // Kafka 服务器地址
	groupID := "my-group"                 // 消费者组 ID

	// 创建一个 Kafka Reader，用于消费消息
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers:  []string{brokerAddress}, // Kafka 服务器地址
		Topic:    topic,                   // Kafka 主题
		GroupID:  groupID,                 // 消费者组 ID
		MinBytes: 10e3,                    // 最小读取字节数（10KB）
		MaxBytes: 10e6,                    // 最大读取字节数（10MB）
	})

	defer reader.Close() // 程序结束时关闭 Reader

	// 消费消息
	for {
		msg, err := reader.ReadMessage(context.Background())
		if err != nil {
			log.Fatalf("Failed to read message: %v", err)
		}
		fmt.Printf("Consumed message: topic=%s partition=%d offset=%d key=%s value=%s\n",
			msg.Topic, msg.Partition, msg.Offset, string(msg.Key), string(msg.Value))
		time.Sleep(1 * time.Second) // 模拟处理消息的延迟
	}
}

```

## Kratos 使用 Kafka

场景:
用户注册的微服务, 生产者把用户数据传递给消费者进行创建用户
### 编写 API

```protobuf
syntax = "proto3";

package helloworld.v1;

import "google/api/annotations.proto";

option go_package = "kratos-kafka2/api/helloworld/v1;v1";
option java_multiple_files = true;
option java_package = "dev.kratos.api.helloworld.v1";
option java_outer_classname = "HelloworldProtoV1";

// The greeting service definition.
service Greeter {
  // Sends a greeting
  rpc CreateUser (Request) returns (Reply) {
    option (google.api.http) = {
      post: "/v1/user/register",
      body: "*"
    };
  }
}

// The request message containing the user's name.
message Request {
  string name = 1;
  string email = 2;
  string password = 3;
  uint32 id = 4;
}

// The response message containing the greetings
message Reply {
  uint32 id = 1;
}

```

### 配置 kafka 参数
编写 proto
```protobuf

message Data {

  message Kafka {
    repeated string brokers = 1;
    string topic = 2;
    string group_id = 3;
  }
  Kafka kafka = 3;
}
```

编写实际值
```yaml
data:
  kafka:
    brokers:
      - 192.168.3.125:9092
    topic: my-topic
    group_id: create-account

```

### biz层
```go
package biz

import (
	"context"
	"encoding/json"
	"fmt"

	v1 "kratos-kafka2/api/helloworld/v1"

	"github.com/go-kratos/kratos/v2/errors"
	"github.com/go-kratos/kratos/v2/log"
)

var (
	// ErrUserNotFound is user not found.
	ErrUserNotFound = errors.NotFound(v1.ErrorReason_USER_NOT_FOUND.String(), "user not found")
)

// Greeter is a Greeter model.
type Greeter struct {
	Hello string
}

type User struct {
	ID       int64
	Email    string
	Name     string
	Password string
}

// GreeterRepo is a Greater repo.
type GreeterRepo interface {
	Create(ctx context.Context, user *User) (int64, error)
	KafkaSendMessage(ctx context.Context, key []byte, value []byte) (err error)

	Save(context.Context, *Greeter) (*Greeter, error)
	Update(context.Context, *Greeter) (*Greeter, error)
	FindByID(context.Context, int64) (*Greeter, error)
	ListByHello(context.Context, string) ([]*Greeter, error)
	ListAll(context.Context) ([]*Greeter, error)
}

// GreeterUsecase is a Greeter usecase.
type GreeterUsecase struct {
	repo GreeterRepo
	log  *log.Helper
}

// NewGreeterUsecase new a Greeter usecase.
func NewGreeterUsecase(repo GreeterRepo, logger log.Logger) *GreeterUsecase {
	return &GreeterUsecase{repo: repo, log: log.NewHelper(logger)}
}

func (uc *GreeterUsecase) CreateUser(ctx context.Context, user *User) (id int64, err error) {
	fmt.Printf("CreateUser:%+v\n", user)
	id, err = uc.repo.Create(ctx, user)
	if err != nil {
		return
	}
	if id > 0 {
		fmt.Printf("CreateUser:%+v\n", user)
		var b []byte
		b, err = json.Marshal(user)
		if err != nil {
			return
		}
		err = uc.repo.KafkaSendMessage(ctx, []byte(user.Name), b)
		if err != nil {
			return
		}
	}
	return
}

// CreateGreeter creates a Greeter, and returns the new Greeter.
func (uc *GreeterUsecase) CreateGreeter(ctx context.Context, g *Greeter) (*Greeter, error) {
	uc.log.WithContext(ctx).Infof("CreateGreeter: %v", g.Hello)

	return uc.repo.Save(ctx, g)
}

```

### data 层

data.go
```go
package data

import (
	"context"
	"github.com/segmentio/kafka-go"
	"kratos-kafka2/internal/conf"

	"github.com/go-kratos/kratos/v2/log"
	"github.com/google/wire"
)

// ProviderSet is data providers.
var ProviderSet = wire.NewSet(NewData, NewGreeterRepo, NewKafkaProducer, NewKafkaConsumer)

// Data .
type Data struct {
	kp *KafkaProducer
	kc *KafkaConsumer
}

// NewData .
func NewData(c *conf.Data, logger log.Logger, kp *KafkaProducer, kc *KafkaConsumer) (*Data, func(), error) {
	cleanup := func() {
		log.NewHelper(logger).Info("closing the data resources")
	}
	return &Data{kp, kc}, cleanup, nil
}

type KafkaProducer struct {
	writer *kafka.Writer
}

func NewKafkaProducer(c *conf.Data) *KafkaProducer {
	brokers := c.Kafka.Brokers
	topic := c.Kafka.Topic
	writer := &kafka.Writer{
		Addr:     kafka.TCP(brokers...),
		Topic:    topic,
		Balancer: &kafka.LeastBytes{},
	}
	return &KafkaProducer{writer: writer}
}

func (p *KafkaProducer) SendMessage(ctx context.Context, key, value []byte) error {
	err := p.writer.WriteMessages(ctx, kafka.Message{
		Key:   key,
		Value: value,
	})
	if err != nil {
		return err
	}
	log.Infof("sent message: %s", string(value))
	return nil
}

func (p *KafkaProducer) Close() error {
	return p.writer.Close()
}

type KafkaConsumer struct {
	reader *kafka.Reader
}

func NewKafkaConsumer(c *conf.Data) *KafkaConsumer {
	brokers := c.Kafka.Brokers
	topic := c.Kafka.Topic
	groupId := c.Kafka.GroupId
	reader := kafka.NewReader(kafka.ReaderConfig{
		Brokers: brokers,
		Topic:   topic,
		GroupID: groupId,
	})
	return &KafkaConsumer{
		reader: reader,
	}
}

func (c *KafkaConsumer) Start(ctx context.Context) {
	for {
		msg, err := c.reader.ReadMessage(ctx)
		if err != nil {
			return
		}
		log.Debugf("key=%s || value=%s", string(msg.Key), string(msg.Value))
	}
}

func (c *KafkaConsumer) Close() error {
	return c.reader.Close()
}

```

创建 kafka.go

```go
package data

import (
	"context"
	"github.com/go-kratos/kratos/v2/log"
	"time"
)

func (u *greeterRepo) KafkaSendMessage(ctx context.Context, key []byte, value []byte) (err error) {
	defer u.data.kp.Close()
	// 设置超时时间
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	err = u.data.kp.SendMessage(ctx, key, value)
	if err != nil {
		log.Errorf("KafkaSendMessage() || err=%v", err)
		return
	}
	return
}

```

### Service层
```go
package service

import (
	"context"

	v1 "kratos-kafka2/api/helloworld/v1"
	"kratos-kafka2/internal/biz"
)

// GreeterService is a greeter service.
type GreeterService struct {
	v1.UnimplementedGreeterServer

	uc *biz.GreeterUsecase
}

// NewGreeterService new a greeter service.
func NewGreeterService(uc *biz.GreeterUsecase) *GreeterService {
	return &GreeterService{uc: uc}
}

func (s *GreeterService) CreateUser(ctx context.Context, req *v1.Request) (*v1.Reply, error) {
	id, err := s.uc.CreateUser(ctx, &biz.User{
		ID:       int64(req.Id),
		Email:    req.Email,
		Name:     req.Name,
		Password: req.Password,
	})
	if err != nil {
		return nil, err
	}
	return &v1.Reply{Id: uint32(id)}, err
}

```

启动:
```bash
make all
kratos run
```

访问:
```bash
curl -H "Content-Type: application/json" \
-X POST \
-d '{"name":"mac", "email":"mac@gmail.com", "password":"123456"}' \
http://localhost:8000/v1/user/register
```

查看生产者发来的数据:
进入到Kubernetes控制平面:
- --bootstrap-server: kafka地址, 如果是 LoadBalancer或NodePort 类型, 需要修改为 对应的 IP
- --topic: 填写生产者的 topic
```bash
kubectl -n kafka \
run kafka-consumer \
-ti \
--image=quay.io/strimzi/kafka:0.45.0-kafka-3.9.0 \
--rm=true \
--restart=Never \
-- bin/kafka-console-consumer.sh \
--from-beginning \
--bootstrap-server my-cluster-kafka-bootstrap:9092 \
--topic my-topic
```