
## Root
```
sudo passwd root

sudo sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
```
## 静态
1. 将虚拟机软件设置为桥接
2. 查看mac的路由器的信息
3. 在`/etc/netplan/00-installer-config.yaml`文件修改
```shell
cp /etc/netplan/00-installer-config.yaml{,.back}
cat > /etc/netplan/00-installer-config.yaml <<EOF
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp0s5:
      dhcp4: false
      dhcp6: false
      addresses:
        - 192.168.3.160/24
      nameservers:
        addresses:
          - 192.168.3.1
          - 114.114.114.114
      routes:
        - to: default
          via: 192.168.3.1
  version: 2
EOF
# Netplan配置文件不应该对其他用户开放访问权限 过于开放的权限，这可能会导致安全风险
sudo chmod 600 /etc/netplan/00-installer-config.yaml
# 生成和应用更改
sudo netplan generate
sudo netplan apply
```

## 克隆出现的UUID相同问题

kubernetes以UUID区分集群机器标识, 相同的UUID的虚拟机/机器不能加入集群

1. 参考[CSDN](https://blog.csdn.net/weixin_41806245/article/details/114581018)
2. 列出虚拟机:
```shell
prlctl list -a
```
3. 把重复的UUID的虚拟机的UUID取消注册
```shell
prlctl unregister 14182a5e-8a9e-4bfe-94cd-ac807bb40fa4
```
4. 重新注册生成新的UUID. 在mac主机上的终端执行以下命令:
把`/Users/lisa/Public/Linux/Ubuntu/master/master1.pvm/`替换为你要更改的UUID虚拟机的pvm路径
```shell
prlctl register --regenerate-src-uuid /Users/lisa/Public/Linux/Ubuntu/master/master1.pvm/
```

## clash代理

### 设置代理
#### HTTP(S)
当前会话:

```shell
export MAC_IP="192.168.3.101"
export http_proxy="http://$MAC_IP:7890"
export https_proxy="https://$MAC_IP:7890"
```

别名
```shell
USER_PATH="/root"
SHELL_FILE="${USER_PATH}/.bashrc"
#export SHELL_FILE="~/.zshrc"
#MAC_IP="192.168.3.220"
MAC_IP="192.168.3.111"

sudo cat >> $SHELL_FILE <<EOF
alias vpnon="export http_proxy='http://$MAC_IP:7890';export https_proxy='https://$MAC_IP:7890'"
EOF

source $SHELL_FILE
cat $SHELL_FILE
```

## 设置使用代理
alias setproxy="export http_proxy=http://127.0.0.1:1087; export https_proxy=$http_proxy; export all_proxy=socks5://127.0.0.1:1080; echo 'Set proxy successfully'"
## 设置取消使用代理
alias unsetproxy="unset http_proxy; unset https_proxy; unset all_proxy; echo 'Unset proxy successfully'"
#### socket5协议

```shell
export MAC_IP="192.168.3.220"

cat >> ~/.bashrc <<EOF
export http_proxy="socks5://$MAC_IP:7890"
export https_proxy="socks5://$MAC_IP:7890"
EOF

source ~/.bashrc
cat ~/.bashrc
```

### 取消代理
当前会话取消代理:
```shell
unset http_proxy
unset https_proxy
```

别名:
```shell
USER_PATH="/root"
SHELL_FILE="${USER_PATH}/.bashrc"
cat >> $SHELL_FILE <<EOF
alias vpnoff="unset http_proxy;unset https_proxy"
EOF

source $SHELL_FILE
cat $SHELL_FILE
```

Clash的Tun模式 与 WireGuard冲突
一份参考: `https://github.com/MetaCubeX/mihomo/blob/Alpha/docs/config.yaml`
打开clash的配置文件`config.yaml`, 添加:
```yaml
...
interface-name: en0
...
```