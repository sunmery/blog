## 设置对应主机名

每个节点分别设置对应主机名

```sh
主节点
hostnamectl set-hostname master 
从节点
hostnamectl set-hostname node1 
hostnamectl set-hostname node2
hostnamectl set-hostname node3
```

## 修改 hosts

所有节点都修改 hosts

```sh
echo "192.168.58.131 master" >> /etc/hosts
echo "192.168.58.135 node1" >> /etc/hosts
echo "192.168.58.136 node2" >> /etc/hosts
echo "192.168.58.137 node3" >> /etc/hosts
```

## 关闭 SELinux

所有节点关闭 SELinux

```sh
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```

## 添加 k8s 安装源

所有节点

```sh
cat <<EOF > kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
mv kubernetes.repo /etc/yum.repos.d/
```

CentOS7必备前置:

tc 流量转发控制

```sh
sudo yum install -y yum-utils iproute-tc 
sudo yum update -y
sudo yum clean all
sudo yum makecache fast
```

## 安装k8s所需组件

所有节点

### v1.23以上版本

```sh
yum install -y kubectl kubelet kubeadm
or
yum install -y kubectl 
yum install -y kubelet
yum install -y kubeadm

```

### 网络内核模块

```sh
tee /etc/modules-load.d/containerd.conf << EOF 
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
```

### 数据包转发

```sh
tee /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
EOF 
```

重启

```sh
sysctl --system
```

#### 生成containerd的默认配置文件

所有节点

```sh
containerd config default | tee /etc/containerd/config.toml
sed -i 's#registry.k8s.io/pause:3.6#registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9#g' /etc/containerd/config.toml
sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g'  /etc/containerd/config.toml
```

重启containerd

```sh
systemctl restart containerd
```

### v1.23以上版本不包含dockershim, 旧版本如下

yum: 使用`yum list <pack> --showduplicates`查找所有版本

```sh
yum list kubectl --showduplicates
yum list kubeadm --showduplicates
yum list kubelet --showduplicates
```

1.24.0版本带`containerd`

```
yum install -y kubelet-1.24.0 kubectl-1.24.0 kubeadm-1.24.0 containerd
```

1.22.4版本带`docker`

```
yum install -y kubelet-1.22.4 kubectl-1.22.4 kubeadm-1.22.4 docker-ce 
```

#### 添加 Docker 安装源

所有节点

```sh
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
```

## 检查安装

### 启动

启动kubelet、docker，并设置开机启动（所有节点）

```sh
systemctl enable kubelet --now
systemctl start kubelet 
systemctl enable containerd --now
systemctl start containerd
```

(可选) 如果选择的是Docker

```sh
systemctl enable docker --now
systemctl start docker
```

### 检查是否加入自启

kubelet

```sh
systemctl is-enabled kubelet
```

(可选) Docker

```sh
systemctl is-enabled docker
```

查看kubectl版本

```sh
kubectl version --client --output=yaml
```

验证kubectl配置

```sh
kubectl cluster-info
```

查看kubelet版本

```sh
kubelet --version
```

查看kubeadm版本

```sh
kubeadm version
```

## 修改 docker 配置

所有节点都需要 kubernetes 官方推荐 docker 等使用 systemd 作为 cgroupdriver，否则 kubelet 启动不了

```sh
cat <<EOF > daemon.json 
{ 
	"exec-opts": ["native.cgroupdriver=systemd"],
	"registry-mirrors": ["https://ud6340vz.mirror.aliyuncs.com"]
} 
EOF 
mv daemon.json /etc/docker/

# 重启生效 
systemctl daemon-reload 
systemctl restart docker 
```

## 关闭SWAP分区

注释SWAP行

```sh
vi /etc/fstab
```

示例:
![[Pasted image 20230419034510.png]]

## 配置k8s配置

主节点配置kube

> 其他节点需要访问集群，需要从主节点复制这个文件过去其他节点
> 在其他机器上创建 ~/.kube/config 文件也能通过 kubectl 访问到集群

```sh
mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## 初始化集群

根据你的主机类型选择一个方案, 只需要执行其一

### 不同云厂商的公网IP方案

1. 建立虚拟机网卡（所有节点）
   添加修改以下网卡配置

```sh
cat > /etc/sysconfig/network-scripts/ifcfg-eth0:1 <<EOF
BOOTPROTO=static
DEVICE=eth0:1
IPADDR=<公网IP>
PREFIX=32
TYPE=Ethernet
USERCTL=no
ONBOOT=yes
EOF
```

(可选) centos8需要重启网络（所有节点）

```sh
systemctl restart network
```

2. 查看是否生效（所有节点）

```sh
ip addr
```

3. 修改kubelet启动参数文件（所有节点）
   修改kubeadm配置, 替换`<公网IP>`为当前节点公网IP

```
echo >> /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS --node-ip=<公网IP>
```

4. 主节点(master)添加配置文件

```yml

```

### 内网方案

master主节点用[kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/)初始化

```sh
# 初始化集群控制台 Control plane
# 失败了可以用 kubeadm reset 重置
kubeadm init --image-repository=registry.aliyuncs.com/google_containers
```

(可选) 重新获取token：

```sh
kubeadm token create --print-join-command
```

## 自动补全

### yum

```sh
yum install bash-completion
```

### apt-get

```sh
apt-get install bash-completion
```

### 导入

#### bash

```bash
kubectl completion bash
source ~/.bashrc
```

##### (异常时) 失败运行:

```bash
echo >>  ~/.bashrc "source /usr/share/bash-completion/bash_completion"
source ~/.bashrc
```

#### 验证

```sh
type _init_completion
```

### 启动 kubectl 自动补全功能

[k8s](https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#enable-kubectl-autocompletion)

#### Bash

> 确保kubectl 补全脚本已经导入（sourced）到 Shell 会话中。 可以通过以下两种方法进行设置：

- [当前用户](https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#kubectl-bash-autocompletion-0)
- [系统全局](https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#kubectl-bash-autocompletion-1)

```bash
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl
```

如果 kubectl 有关联的别名，你可以扩展 Shell 补全来适配此别名：

```bash
echo 'alias ct=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl ct' >>~/.bashrc
```

重新加载

```sh
source ~/.bashrc
```

## Q&A

Q: `[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1`  因为之前初始化过
A: 修改内核

```sh
vi /etc/sysctl.conf

net.ipv4.ip_forward = 1
```

重启

```sh
sysctl --system
```

Q: `E0419 17:19:24.409506  137577 memcache.go:265] couldn't get current server API group list: Get "http://localhost:8080/api?timeout=32s": dial tcp [::1]:8080: connect: connection refused
The connection to the server localhost:8080 was refused - did you specify the right host or port?`

A:

```sh
mkdir -p $HOME/.kube 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Q:`networkPlugin cni failed to set up pod "test-k8s-68bb74d654-mc6b9_default" network: open /run/flannel/subnet.env: no such file or directory`

A:
在每个节点创建文件`/run/flannel/subnet.env`写入以下内容，配置后等待一会就好了

```sh
mkdir /run/flannel/ && echo > "/run/flannel/subnet.env" \
"FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true"
```


![[II74`B0FZ0AJLEX[0O3_(`B.jpg]]
