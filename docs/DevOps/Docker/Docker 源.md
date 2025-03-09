
```text
vim /etc/docker/daemon.json
```

```bash
cp /etc/docker/daemon.json{,back}
cat > /etc/docker/daemon.json <<EOF
{  
  "registry-mirrors": [
    "https://646f636b6572.boown.com"
  ]
}
EOF
systemctl restart docker
```

使用宿主机代理:
```
"proxies" : {
    "http-proxy": "http://127.0.0.1:7890",
    "no-proxy": "localhost,127.0.0.0/8",
    "https-proxy": "http://127.0.0.1:7890"
  },
```

```json
{
  "registry-mirrors": [
    "https://646f636b6572.boown.com",
    "https://docker.rainbond.cc",
    "https://dockerproxy.cn",
    "https://docker.udayun.com",
    "https://docker.211678.top",
    "https://docker-cf.registry.cyou",
    "https://dockercf.jsdelivr.fyi",
    "https://docker.jsdelivr.fyi",
    "https://dockertest.jsdelivr.fyi",
    "https://mirror.aliyuncs.com",
    "https://dockerproxy.com",
    "https://mirror.baidubce.com",
    "https://docker.m.daocloud.io",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://docker.rainbond.cc"
  ]
}
```


```bash
cat > /etc/docker/daemon.json <<EOF
EOF
systemctl restart docker
```

```shell
systemctl restart docker
```

## 资料
https://cloud.tencent.com/document/product/1207/45596