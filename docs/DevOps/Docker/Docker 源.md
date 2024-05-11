
```text
vim /etc/docker/daemon.json
```

```json
{
	"registry-mirrors": [
			"https://mirror.ccs.tencentyun.com",
	        "http://hub-mirror.c.163.com"
	    ]
}
```

```shell
systemctl restart docker
```

server = "https://docker.io"
[host."https://docker.mirrors.ustc.edu.cn"]
  capabilities = ["pull", "resolve"]

## 资料
https://cloud.tencent.com/document/product/1207/45596