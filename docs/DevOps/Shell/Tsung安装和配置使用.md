## 安装

Ubuntu:

```shell
apt-get install tsung

```

mac:

```shell
brew install tsung
```

其他: http://tsung.erlang-projects.org/user_manual/installation.html

## 配置

https://juejin.cn/post/7290485046128508940

编写一个简单的go web程序:

1. 初始化

```shell
go mod init example
```

2. 编写主程序

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		testdata := map[string]string{
			"message": "pong",
			"jpg1":    "user12-1.mp4.jpg",
			"jpg23":   "user12-1.mp4.jpg",
			"jpg5":    "user12-1.mp4.jpg",
			"jpg4":    "user12-1.mp4.jpg",
			"jpg11":   "user12-1.mp4.jpg",
			"jpg14":   "user12-1.mp4.jpg",
			"jpg3":    "user12-1.mp4.jpg",
			"jpg51":   "user12-1.mp4.jpg",
			"jpg6":    "user12-1.mp4.jpg",
			"jpg15":   "user12-1.mp4.jpg",
			"jpg125":  "user12-1.mp4.jpg",
			"jpg421":  "user12-1.mp4.jpg",
			"jpg124":  "user12-1.mp4.jpg",
			"jpg1255": "user12-1.mp4.jpg",
			"jpg":     "user12-1.mp4.jpg",
		}

		jsonData, err := json.Marshal(testdata)
		if err != nil {
			fmt.Println("JSON serialization error:", err)
			panic(err)
		}
		// 设置响应头
		w.Header().Set("Content-Type", "text/plain")
		_, err1 := w.Write(jsonData)
		if err1 != nil {
			panic(err1)
		}
	})

	fmt.Println("http server started on :8080")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		panic(err)
	}
}

```

部署到Docker或者Kubernetes

#### Docker部署

Dockerfile:

```yml
FROM golang:alpine AS builder
MAINTAINER Lookeke
ENV VERSION 1.0

WORKDIR /app

# 拷贝当前目录下可以执行文件
COPY . .

RUN go env -w GOPROXY=https://proxy.golang.com.cn,direct

# 里要加-tags netgo进行静态编译，否则由于alipne基础镜像缺少必要的动态库，可能会出现类似“no such file or directory"的报错
# 或者直接禁用gcc，然后进行编译
RUN mkdir -p /app/bin
# # pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change

RUN go mod download && go mod verify
RUN go env -w CGO_ENABLED=0 GOOS=linux GOARCH=amd64 && go build -o example .

FROM scratch
#FROM alpine

WORKDIR /app

# 从 builder 镜像中复制 Go 二进制文件到当前镜像中
COPY --from=builder /app/example .

# 定义容器启动时运行的命令
ENTRYPOINT ["/app/example"]

# docker build --progress=plain --no-cache -t example .
# docker run -itd -v ./configs:/data/conf -p 8080:8080 -p 4000:4000 example
```

docker-compose.yml:

```yml
version: '3'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
      - "4000:4000"
    container_name: example
```

运行:

```shell
docker-compose up -d
```

### Kubernetes

将`image`替换为容器的URL

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
  labels:
    app: example
spec:
  replicas: 1
  selector:
    matchLabels:
      app: example
  template:
    metadata:
      name: example
      labels:
        app: example
    spec:
      containers:
        - name: example
          image: examole
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              protocol: TCP
              containerPort: 8080
      restartPolicy: Always
```

示例配置:

```xml
<?xml version="1.0"?>
<!DOCTYPE tsung SYSTEM "/usr/share/tsung/tsung-1.0.dtd">
<tsung loglevel="notice" version="1.0">

    <!-- Client side setup -->
    <clients>
        <client host="localhost" use_controller_vm="false" maxusers="2000" cpu="4"/>
    </clients>

    <!-- Server side setup -->
    <servers>
        <server host="localhost" port="8080" type="tcp"></server>
    </servers>

    <!-- to start os monitoring (cpu, network, memory). Use an erlang
    agent on the remote machine or SNMP. erlang is the default -->
<!--    <monitoring>-->
<!--        <monitor host="myserver" type="snmp"></monitor>-->
<!--        <monitor host="localhost" type="snmp"></monitor>-->
<!--    </monitoring>-->

    <load>
        <!-- several arrival phases can be set: for each phase, you can set
        the mean inter-arrival time between new clients and the phase
        duration -->
        <arrivalphase phase="1" duration="10" unit="minute">
            <users maxnumber="100" interarrival="0.02" unit="second"></users>
        </arrivalphase>
    </load>

    <options>
        <option type="ts_http" name="user_agent">
            <user_agent probability="80">Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21</user_agent>
            <user_agent probability="20">Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4</user_agent>
        </option>
    </options>

    <!-- start a session for a http user. the probability is the
    frequency of this type os session. The sum of all session's
    probabilities must be 100 -->

    <sessions>
        <session name="http-example" probability="100" type="ts_http">

            <!-- full url with server name, this overrides the "server" config value -->

            <request>
                <http url="/" method="GET" version="1.1"></http>
            </request>

            <thinktime value="20" random="true"></thinktime>

<!--            <request>-->
<!--                <http url="/index.html" method="GET" version="1.1" ></http>-->
<!--            </request>-->
        </session>

<!--        <session name="http-example" probability="30" type="ts_http">-->
<!--            <setdynvars sourcetype="random_number" start="1" end="100">-->
<!--                <var name="itemid" />-->
<!--            </setdynvars>-->
<!--            <setdynvars sourcetype="random_number" start="20" end="5000000">-->
<!--                <var name="content" />-->
<!--            </setdynvars>-->
<!--            <transaction name='getlist'>-->
<!--                <request subst="true">-->
<!--                    <http url="/comment/addComment" method="POST" contents = "item_type=image&amp;item_id=%%_itemid%%&amp;content=%%_content%%"></http>-->
<!--                </request>-->
<!--            </transaction>-->
<!--        </session>-->
    </sessions>
</tsung>

```

## 使用

选项:
-f file：用于设置配置文件的路径，指定测试用例和配置信息的文件。默认情况下，配置文件是 ~/.tsung/tsung.xml。
-l logdir：指定日志文件存储的目录。Tsung 将在该目录下创建以日期和时间命名的子目录来存储日志文件。默认目录是 ~/.tsung/log/。
-i id：设置控制器的标识符，通常为空。
-r command：设置远程连接器的命令，通常为 ssh。
-s：启用 Erlang SMP（对称多处理）模式，用于在客户端节点上利用多核处理器。
-p max：设置每个 Erlang 虚拟机的最大进程数。默认值是 250,000。
-X dir：添加额外的 Erlang 加载路径。可以多次使用 -X 参数来指定多个目录。
-m file：将监控输出写入指定的文件。默认文件是 tsung.log。您还可以将监控输出定向到标准输出，使用 - 参数。
-F：使用全名（Fully Qualified Domain Name，FQDN）作为 Erlang 节点的名称。
-L lifetime：设置 SSL 会话的生存期，默认为 600 秒。
-w delay：设置预热延迟，即在开始正式测试之前等待的时间，默认为 1 秒。
-n：禁用 Web GUI，默认情况下 Tsung 会在端口 8091 上启动 Web GUI。
-k：在测试完成后保持 Web GUI（和控制器）运行。
-v：打印 Tsung 版本信息并退出。
-6：使用 IPv6 用于 Tsung 内部通信。
-x tags：指定要从运行中排除的请求标签。多个标签可以使用逗号分隔。
-t min：设置 Erlang Inet 监听的 TCP 端口号的最小值，默认为 64000。
-T max：设置 Erlang Inet 监听的 TCP 端口号的最大值，默认为 65500。
-h：显示帮助信息。

运行示例

```shell
tsung -f http.xml start -k
```

查看Web GUI的状态
浏览器访问: `<IP>:8091` 即可查看
