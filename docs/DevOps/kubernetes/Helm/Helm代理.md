Helm通过操作系统自己的网络去进行下载, 只需要在执行前加上代理即可, 例如:
```bash
export https_proxy=http://192.168.3.220:7890 http_proxy=http://192.168.3.22:7890
all_proxy=socks5://192.168.3.22:7890

helm repo add grafana https://grafana.github.io/helm-charts
```

```bash
cat >> ~/.bashrc <<EOF
alias proxy="export https_proxy=http://192.168.3.220:7890 http_proxy=http://192.168.3.22:7890
all_proxy=socks5://192.168.3.22:7890"
alias unproxy="unset https_proxy;unset http_proxy; unset all_proxy"
EOF
source ~/.bashrc
```