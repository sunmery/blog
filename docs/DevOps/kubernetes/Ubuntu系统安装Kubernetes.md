## 更新说明

- 2024/01/02:

1. 添加更具体的说明, 默认使用`v1.29.0`版本部署
2. 添加rpm/apt的Kubernetes组件的安装说明

- 2023/12/28:

1. Kubernetes版本选择: 截止目前, `Kubernetes`最新版本为`v1.29.0`, 使用最新的版本进行安装
2. 容器运行时: 使用`containerd`作为`CRI`截止目前, `containerd`最新版本为`v1.7.11`
3. 本文的Shell操作仅支持在类Unix的机器环境执行, 带有RedHat和Ubuntu仅适合该类发行版的机器执行

## 前置

### 检查

#### [验证每个节点的 MAC 地址和product_uuid是否唯一](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address)

- 您可以使用以下命令`ip link`获取网络接口的 MAC 地址，或者`ifconfig -a`
- 可以使用以下命令`sudo cat /sys/class/dmi/id/product_uuid`检查product_uuid

It is very likely that hardware devices will have unique addresses, although some virtual machines may have identical
values. Kubernetes uses these values to uniquely identify the nodes in the cluster. If these values are not unique to
each node, the installation process may[fail](https://github.com/kubernetes/kubeadm/issues/31).  
硬件设备很可能具有唯一的地址，尽管某些虚拟机可能具有相同的值。Kubernetes 使用这些值来唯一标识集群中的节点。如果这些值对于每个节点不是唯一的，则安装过程可能会失败。

#### [检查网络适配器](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-network-adapters)

If you have more than one network adapter, and your Kubernetes components are not reachable on the default route, we
recommend you add IP route(s) so Kubernetes cluster addresses go via the appropriate adapter.  
如果你有多个网络适配器，并且你的 Kubernetes 组件在默认路由上无法访问，我们建议你添加 IP 路由，以便 Kubernetes 群集地址通过相应的适配器。

#### [检查所需的端口](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports)

These[required ports](https://kubernetes.io/docs/reference/networking/ports-and-protocols/)need to be open in order for
Kubernetes components to communicate with each other. You can use tools like netcat to check if a port is open. For
example:  
这些必需的端口需要打开，以便 Kubernetes 组件相互通信。您可以使用 netcat 等工具检查端口是否打开

## 概念/名词解释

本文有对英文使用的专业名词的个人理解翻译, 当然在网络中也有对原英文有不同的理解翻译, 这里使用英文的中文对照:

1. master节点, 即控制平面(control-plane)所在的节点, 负责控制/管理Pod的机器, master节点默认不会运行Pod(污点)
2. workernode/工作节点/node节点, 即工作节点, 负责运行Pod的机器
3. Kubeadm: Kubernetes的官方工具，用于快速部署Kubernetes集群
4. Kubelet: Kubernetes节点上的主要组件，负责管理节点上的Pod和容器。它负责与Master节点通信，接收集群中的Pod创建请求，并确保Pod和容器在节点上正确运行
5. kubectl: Kubernetes的命令行工具，用于与Kubernetes集群进行交互。通过kubectl，用户可以管理集群、部署应用、查看日志等
6. containerd: 一个面向容器的运行时管理器，负责管理容器的生命周期，包括镜像、容器、快照等。它是Kubernetes
   v12.24.x版本之后默认的容器运行时
7. crictl:
   一个用于与Kubernetes容器运行时接口（CRI）进行交互的命令行工具,是Kubernetes与容器运行时之间的接口规范，用于定义容器运行时如何与Kubernetes进行通信和交互。CRI定义了一组API，使Kubernetes能够管理容器的生命周期、调度和资源管理等操作.
   在Kubernetes集群中，当容器出现问题时，crictl可以帮助你进行调试和故障排除
8. CNI(Container Network Interface/容器网络接口):
   Kubernetes网络插件的标准接口，用于配置容器之间的网络连接。它定义了一组API，允许不同的网络插件与Kubernetes集成，实现容器之间的通信和网络隔离.
   在安装CNI之后, 会添加类似`cni0`的网卡
9. Flannel/Calico: Kubernetes集群的网络解决方案之一，用于提供容器之间的网络通信。它通过为每个节点分配子网来创建覆盖整个集群的容器网络，实现了跨节点的容器通信.
   在安装之后, 会添加类似`flannel.1`的网卡

## 准备环境

机器配置至少为2C+2G的机器, 以下是本人配置

> Ubuntu和RedHat系列(Centos/RockyLinux)操作系统是最受欢迎的Linux发行版之一, 此示例加入不同的操作系统作为工作节点,
> 方便使用者参考

| 节点类型    | 角色            | IP            | 操作系统        | 推荐内存 | 包管理器    |
|---------|---------------|---------------|-------------|------|---------|
| master1 | control-plane | 192.168.0.151 | Ubuntu22.04 | 8Gi  | apt     |
| master2 | control-plane | 192.168.0.152 | Ubuntu22.04 | 8Gi  | apt     |
| node1   | worknode      | 192.168.0.153 | Ubuntu22.04 | 24Gi | apt     |
| node2   | worknode      | 192.168.0.154 | RedHat9     | 24Gi | yum/dnf |
| node3   | worknode      | 192.168.0.155 | RedHat9     | 24Gi | yum/dnf |
| node4   | worknode      | 192.168.0.156 | RedHat9     | 24Gi | yum/dnf |

如果是只有一个机器, 也可以作为控制平面和工作节点使用,
参考[控制平面节点上调度 Pod](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation)

## 基础环境配置

## [开发Kubernetes端口](https://kubernetes.io/zh-cn/docs/reference/networking/ports-and-protocols)

控制节点需要开启以下下端口:

| 协议	 | 方向	 | 端口范围	       | 目的	                      | 使用者                  |
|-----|-----|-------------|--------------------------|----------------------|
| TCP | 	入站 | 	6443	      | Kubernetes API server	   | 所有                   |
| TCP | 	入站 | 	2379-2380	 | etcd server client API	  | kube-apiserver, etcd |
| TCP | 	入站 | 	10250	     | Kubelet API	             | 自身, 控制面              |
| TCP | 	入站 | 	10259	     | kube-scheduler	          | 自身                   |
| TCP | 	入站 | 	10257	     | kube-controller-manager	 | 自身                   |

```shell
sudo ufw allow 6443/tcp
sudo ufw allow 2379:2380/tcp
sudo ufw allow 10250/tcp
sudo ufw allow 10259/tcp
sudo ufw allow 10257/tcp
```

工作节点需要开启以下下端口:

| 协议	  | 方向	 | 端口范围        | 	目的	                | 使用者     |
|------|-----|-------------|---------------------|---------|
| TCP	 | 入站	 | 10250       | 	Kubelet API	       | 自身, 控制面 |
| TCP	 | 入站	 | 30000-32767 | 	NodePort Services† | 	所有     |

```shell
sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp
```

**控制平面和工作节点都需要进行设置**

### 修改hostname(可选)

方便区分node节点, 节点数量多推荐
`master`节点命名为`master1`,以此类推

```shell
hostnamectl set-hostname master1
```

`workernode1`命名为`node1`,以此类推

```shell
hostnamectl set-hostname node1
```

### 时间同步(推荐, 非必须)

```shell
yum install ntpdate -y # RedHat
apt install ntpdate -y # Ubuntu
ntpdate time.windows.com
```

### 修改 hosts(推荐, 非必须)

所有节点都修改 hosts
示例:

```shell
cat >> /etc/hosts << EOF
192.168.0.151 master1
192.168.0.152 master2
192.168.0.153 node1
192.168.0.154 node2
192.168.0.155 node3
192.168.0.156 node4
EOF
```

or

```shell
vi /etc/hosts
```

添加

```
192.168.0.151 master1
192.168.0.152 master2
192.168.0.153 node1
192.168.0.154 node2
192.168.0.155 node3
192.168.0.156 node4
```

重启systemd-resolved
systemd-resolved这个服务负责系统的 DNS 解析。`/etc/hosts`文件包含了主机名与 IP 地址的映射关系。这两者之间的关系在于
systemd-resolved 服务会读取`/etc/hosts`文件中的内容来解析主机名。当你执行`systemctl restart systemd-resolved`命令时，它会重新加载
`/etc/hosts`文件中的内容，以确保系统能够正确解析主机名

```shell
systemctl restart systemd-resolved
systemctl status systemd-resolved
systemctl enable systemd-resolved
```

### 关闭 SELinux

所有节点关闭 SELinux

> 负载均衡机器必须要关闭,因为6443不是nginx的标准端口,会被selinux拦截, 防火墙也需要放行6443端口, 可以考虑直接关闭

SELINUX有三种状态:

1. permissive: 不阻止任何操作, 但会记录潜在的危险操作. 会打印警告，但不会强制执行安全策略
2. disabled: 完全关闭
3. enforcing: 启用SELinux安全保护状态

#### RedHat

```shell
sudo systemctl disable --now firewalld
setenforce 0 # 临时禁用, 重启变回
sed -i "s/^SELINUX=.*/SELINUX=permissive/g" /etc/selinux/config # 禁用
```

#### Ubuntu

```shell
sudo setenforce 0 # 临时禁用, 重启变回
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config # 禁用
```

使用命令`sestatus`来检查 SELinux 的状态。状态为`disabled`/`permissive`即可

```
SELinux status:                 disabled
```

### swap交换分区

kubelet 的默认行为是: 如果在节点上检测到交换内存，则无法启动。自 v1.22 起支持 Swap。从 v1.28 开始，只有 `cgroup v2` 支持
Swap, 如果你想检查或升级到`cgroup v2`, 参阅本文的 [[#配置cgroup]]
kubelet 的 NodeSwap 特性门控是 beta 版，但默认处于禁用状态。

如果 kubelet 未正确配置为使用 swap，则必须禁用swap

#### 禁用swap

1. 关闭swap: 将禁用系统上的所有活动 swap 分区, 系统重启后会自动重新启用 swap 分区

```shell
sudo swapoff -a
```

2. 禁用swap:

```shell
sed -i '/^\/.*swap/s/^/#/' /etc/fstab

sudo mount -a
```

3. 重启机器

```
reboot
```

#### 检查是否禁用

1. 确保`/swap.img	none	swap	sw	0	0` 被`#`注释

```shell
cat /etc/fstab
```

2. 使用终端命令查看分区信息：如果显示了交换分区的信息和类型，则表示已启用交换分区。

```shell
sudo blkid | grep swap
```

3. 显示了交换分区的信息和类型，则表示已启用交换分区

```shell
cat /proc/swaps
```

4. 查看当前系统的 `vm.swappiness` 值

> 将 `vm.swappiness` 设置为一个适中的值，例如 `vm.swappiness=10` 或 `vm.swappiness=60`
> ，以在内存不足时允许一些数据被移到交换分区，但不会过于积极。这可以在内存和性能之间找到一个平衡点，使系统在内存使用高峰时能够正常运行而不会过度依赖交换空间

```shell
cat /proc/sys/vm/swappiness
```

### [转发IPv4并让iptables看到桥接的流量](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#forwarding-ipv4-and-letting-iptables-see-bridged-traffic)

```shell
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

通过运行以下命令验证是否加载了`br_netfilter`，`overlay`模块：

```bash
lsmod | grep br_netfilter
lsmod | grep overlay
```

运行以下命令，验证配置中是否将`net.bridge.bridge-nf-call-iptables`、`net.bridge.bridge-nf-call-ip6tables`和
`net.ipv4.ip_forward`系统变量设置为：`1`

```shell
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
```

### 配置IPVS(可选)

[我该使用iptables还是IPVS?](https://www.tigera.io/blog/comparing-kube-proxy-modes-iptables-or-ipvs/)
IPVS（IP Virtual Server）是Linux内核中的一个负载均衡器。它提供了一种高性能的负载均衡解决方案，用于将入站的网络流量分发到后端的多个服务器上，以实现高可用性和性能优化。

在Kubernetes中，IPVS被广泛用于负载均衡服务。它可以作为Kubernetes集群中的网络代理(kube-proxy)
，将流量分发到后端的Pod实例上。IPVS可以根据预定义的负载均衡算法（如轮询、加权轮询、最少连接等）智能地将请求分发到可用的Pod实例上，从而实现负载均衡和优化资源利用。

- `ip_vs`: IP 虚拟服务器核心模块，用于实现负载平衡。
- `ip_vs_rr`: 轮询（Round Robin）调度算法
- `ip_vs_wrr`: 加权轮询（Weighted Round Robin）调度算法
- `ip_vs_sh`: 源散列（Source Hashing）调度算法。
- `nf_conntrack`: 用于跟踪网络连接的状态。
- `ip_tables`, `ipt_REJECT`: 与 iptables 相关，用于网络地址转换（NAT）和数据包过滤。
- `ip_set`, `xt_set`, `ipt_set`: 与 IP 集合相关，用于实现复杂的网络过滤规则。
- `ipt_rpfilter`: 反向路径过滤，用于防止 IP 伪装。
- `ipip`: 用于 IP-in-IP 封装，一种隧道协议

> 注意：使用`nf_conntrack`而不是`nf_conntrack_ipv4`用于 Linux 内核 4.19 及更高版本）

您如果需要更广泛的网络功能和过滤能力:

```
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
```

只关注IPVS最基本的核心负载均衡功能:

```shell
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack_ipv4
```

```
ip_vs  
ip_vs_rr  
ip_vs_wrr  
ip_vs_sh  
nf_conntrack  
```

#### RedHat

设置下次开机自动加载

```shell
yum install ipvsadm ipset sysstat conntrack libseccomp -y 
cat >> /etc/modules-load.d/ipvs.conf <<EOF 
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
ip_tables
ip_set
xt_set
ipt_set
ipt_rpfilter
ipt_REJECT
ipip
EOF

systemctl restart systemd-modules-load.service

lsmod | grep -e ip_vs -e nf_conntrack
# or
cut -f1 -d " "  /proc/modules | grep -e ip_vs -e nf_conntrack
```

#### Ubuntu

```shell
apt install ipset ipvsadm -y

cat > /etc/modules-load.d/ipvs.conf << EOF  
ip_vs  
ip_vs_rr  
ip_vs_wrr  
ip_vs_sh  
nf_conntrack  
EOF

systemctl restart systemd-modules-load.service

lsmod | grep -e ip_vs -e nf_conntrack
# or
cut -f1 -d " "  /proc/modules | grep -e ip_vs -e nf_conntrack
```

> 如果不满足这些要求，Kube-proxy 将回退到 IPTABLES 模式

#### 内核参数(仅适用于RedHat)

```shell
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
fs.may_detach_mounts = 1
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_watches=89100
fs.file-max=52706963
fs.nr_open=52706963
net.netfilter.nf_conntrack_max=2310720

net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_intvl =15
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 327680
net.ipv4.tcp_orphan_retries = 3
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.ip_conntrack_max = 65536
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_timestamps = 0
net.core.somaxconn = 16384

net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
EOF

sysctl --system
```

### 安装配置容器运行时

所有节点均需安装与配置, 根据实际需求, 推荐Kubernetes安装v1.24版本以上使用containerd. 本教程只使用containerd

```shell
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf  
overlay  
br_netfilter  
EOF  
  
sudo modprobe overlay  
sudo modprobe br_netfilter  
  
# 设置必需的 sysctl 参数，这些参数在重新启动后仍然存在。  
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf  
net.bridge.bridge-nf-call-iptables  = 1  
net.ipv4.ip_forward                 = 1  
net.bridge.bridge-nf-call-ip6tables = 1  
EOF  
  
# 应用 sysctl 参数而无需重新启动  
sudo sysctl --system
```

##### 二进制方式(版本最新, 推荐)

使用二进制`containerd`, 也可以使用其他方式安装, 安装配置即可

1. 下载, 如果机器无法访问github, 请自行下载并上传

```shell
export VERSION="1.7.11"
mkdir -p /home/containerd
cd /home/containerd

wget https://github.com/containerd/containerd/releases/download/v${VERSION}/containerd-${VERSION}-linux-amd64.tar.gz

tar -xzvf containerd-1.7.11-linux-amd64.tar.gz -C /usr/local/
```

2. 创建systemd service:

```
cat > /etc/systemd/system/containerd.service << EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=infinity
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF
```

启动和加入自启:

```shell
systemctl start containerd
systemctl enable containerd
```

#### Ubuntu

##### apt方式安装(版本可能不是最新, 但是方便)

```shell
apt install containerd
```

#### 创建配置文件

```shell
mkdir -p /etc/containerd/
containerd config default | tee /etc/containerd/config.toml
```

#### 修改配置文件

1. 修改镜像拉取的默认地址(可选,推荐国内服务器使用)
2. 配置`cgroup drivers`为`systemd`,
   RedHat与Ubuntu均使用[systemd](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver)
   管理,
   了解详情请参考[cgroup drivers](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#cgroup-drivers)

配置文件默认在`/etc/containerd/config.toml` 这里仅修改两处配置, 读者可以修改自己想要的配置

1. 修改`registry.k8s.io/pause:3.8`为`registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9`
2. 修改`SystemdCgroup = false`为`SystemdCgroup = true`

> ! 必须注意, 截止2023.10.21,
> containerd版本`1.7.x`的`registry.k8s.io/pause`的版本是`3.8`
> containerd版本`1.6.25`的`registry.k8s.io/pause`的版本是`3.6`
> 请将shell命令修改你自己的版本所对应的版本
> 如果你跟着本教程的版本, 直接执行以下命令, 否则你需要手动修改配置文件

```shell
sed -i 's#registry.k8s.io/pause:3.8#registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9#g' /etc/containerd/config.toml 

sed -i 's#SystemdCgroup = false#SystemdCgroup = true#g' /etc/containerd/config.toml

systemctl restart containerd
```

#### 校验配置文件

1. sandbox_image参数大概在61行位置
2. SystemdCgroup参数大概在125行位置
   使用`cat -n`命令校验是否设置正确:

```shell
cat -n /etc/containerd/config.toml
```

修改`crictl`配置文件，获得`containerd`的`sock`信息
containerd的socket有两个路径,
第一个是`unix:///run/containerd/containerd.sock`
第二个是`unix:///var/run/containerd/containerd.sock`, 在Kubernetes多数版本中使用
`unix:///var/run/containerd/containerd.sock`,但在containerd可能是`unix:///run/containerd/containerd.sock`

```shell
cat << EOF > /etc/crictl.yaml 
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false 
EOF
```

### [配置cgroup](https://kubernetes.io/zh-cn/docs/concepts/architecture/cgroups/#using-cgroupv2)

查看cgroup

```shell
stat -fc %T /sys/fs/cgroup
```

对于 cgroup v2，输出为`cgroup2fs`。
对于 cgroup v1，输出为`tmpfs`。

更新到 cgroup2(Ubuntu20.x)

```shell
sudo grubby \
  --update-kernel=ALL \
  --args="systemd.unified_cgroup_hierarchy=1"

sudo reboot
```

重启containerd

```shell
sudo systemctl restart containerd
```

## 安装Kubernetes组件

这里分为三种安装方式, 选择一种方案安装即可:

1. 二进制安装, 这种方式需要从github下载, 适合大多数操作系统, 版本最新, 安装和配置最麻烦
2. rpm/dnf: 一键安装所需的组件, 适用于搭载了yum/dnf等包管理器的发行版, 例如RedHat, RockyLinux
3. apt/apt-get: 一键安装所需的组件, 适用于搭载了apt/apt-get等包管理器的发行版, 例如Ubuntu, Debian

### [二进制安装](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

需要安装:

1. CNI
2. Kubelet
3. Kubeadm
4. Kubectl
5. crictl
   需要配置:
1. Containerd相关配置
2. Kubelet的systemd service

#### 安装CNI插件(控制节点安装)

CNI(容器网络接口)是大多数Pod的网络都需要的(只需要控制节点安装)

访问 https://github.com/containernetworking/plugins/releases/ 查看最新版本的CNI

1. 将`CNI_PLUGINS_VERSION`替换为最新版或者指定版本
2. 将`ARCH`替换为你当前服务器的架构

命令解释: 从GitHub上下载crictl工具的压缩文件,并将其解压缩到指定的目录中

- |: 管道符号,它将curl命令的输出传递给下一个命令
- tar: 解压工具 对crictl工具的压缩文件进行解压缩
- -C `DOWNLOAD_DIR`: 指定了解压缩后的文件应该存储的目录
- -xz: 表示解压缩的操作包括解压缩和解压缩的过程

```shell
CNI_PLUGINS_VERSION="v1.4.0"
ARCH="amd64"
DEST="/opt/cni/bin"
sudo mkdir -p "$DEST"
curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_PLUGINS_VERSION}/cni-plugins-linux-${ARCH}-${CNI_PLUGINS_VERSION}.tgz" | sudo tar -C "$DEST" -xz
```

#### 安装crictl

kubeadm / Kubelet CRI 需要

访问`https://github.com/kubernetes-sigs/cri-tools/releases`将`RELEASE_VERSION`变量的值替换为最新版或者你喜欢的版本

```shell
export DOWNLOAD_DIR="/usr/local/bin"
sudo mkdir -p "$DOWNLOAD_DIR"
CRICTL_VERSION="v1.28.4"
ARCH="amd64"
curl -L "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-${ARCH}.tar.gz" | sudo tar -C $DOWNLOAD_DIR -xz
```

3. 访问 https://githubu.com/kubernetes/release/ 查看`RELEASE_VERSION`的版本, 将`RELEASE_VERSION`变量的值替换为最新版或者你喜欢的版本

下载kubelet和kubeadm的服务文件,并将它们安装到systemd的相关目录中.同时,它还会创建必要的目录和配置文件

1. 使用curl命令从GitHub上下载kubelet.service文件.

下载kubelet和kubeadm的服务文件(kubelet.service, 10-kubeadm.conf).并将它们安装到systemd的相关目录(/etc/systemd/system)
与kubeadm服务配置目录(/etc/systemd/system/kubelet.service.d/)中.以确保Kubernetes服务能够正常运行
文件作用:

- kubelet.service: 用于启动/重启/停止kubelet服务的systemd服务文件
- 10-kubeadm.conf: 用于在运行时动态地配置kubelet的参数.以便适应不同的环境和需求.这种灵活性使得kubeadm能够更好地管理和配置Kubernetes集群中的节点

命令解释:

- curl
  -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service"
  从kubernetes的GitHub上下载的kubelet的systemd服务文件

- tee /etc/systemd/system/kubelet.service 将替换后的kubelet.service文件输出到/etc/systemd/system/kubelet.service文件中
- sudo mkdir -p /etc/systemd/system/kubelet.service.d 创建/etc/systemd/system/kubelet.service.d目录
- curl
  -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf"
  从kubernetes的GitHub上下载的kubeadm的systemd服务文件

- tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
  将替换后的10-kubeadm.conf文件输出到/etc/systemd/system/kubelet.service.d/10-kubeadm.conf文件中

```shell
RELEASE_VERSION="v0.16.2"
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubelet/kubelet.service" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service
sudo mkdir -p /etc/systemd/system/kubelet.service.d
curl -sSL "https://raw.githubusercontent.com/kubernetes/release/${RELEASE_VERSION}/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf" | sed "s:/usr/bin:${DOWNLOAD_DIR}:g" | sudo tee /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
```

#### 安装kubectl

安装对应架构的Kubectl和校验文件完整性:

```shell
ARCH="amd64"
curl -LO "https://dl.k8s.io/release/$(curl -L -s ${CRICTL_VERSION})/bin/linux/${ARCH}/{kubectl,.sha256}"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
```

如果有效,则输出为:

```
kubectl: OK
```

> 注意:
>
> 如果您在目标系统上没有 root 访问权限,您仍然可以将 kubectl 安装到该 ~/.local/bin 目录中:

```shell
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
# and then append (or prepend) ~/.local/bin to $PATH
```

测试以确保您安装的版本是最新的:

```shell
kubectl version --client
```

或者使用它来查看版本的详细视图:

```shell
kubectl version --client --output=yaml
```

### [rpm/dnf包管理器](https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/#how-to-migrate-rpm)

使用`rpm`/`dnf`的操作系统, 例如CentOS、Fedora、RHEL

1. 添加`Kubernetes源`

- 官方源(适用于国外服务器)

```shell
export VERSION="v1.29.0"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$VERSION/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
```

- 阿里源(适用于国内服务器)
  该方式未经本人验证, 可能没有新版(v1.29.0)版本

```shell 
cat <<EOF > /etc/yum.repos.d/kubernetes.repo  
[kubernetes]  
name=Kubernetes  
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/  
enabled=1  
gpgcheck=0  
repo_gpgcheck=0  
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg  
EOF
```

2. 安装`Kubernetes`, 默认为安装最新版.
   最新版:

```shell
yum install -y kubelet kubeadm kubectl
```

如果想指定版本:

```shell
yum install -y --nogpgcheck kubelet-1.21.10-0 kubeadm-1.21.10-0 kubectl-1.21.10-0
```

3. 把`kubelet`加入到自启列表并启动

```shell
systemctl enable kubelet && systemctl start kubelet
```

### [apt/apt-get包管理器](https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/#how-to-migrate)

该方式适合搭载了`apt`/`apt-get`包管理工具的发行版, 例如`Ubuntu`/`Debian`

1. 添加`Kubernetes源`
2. 安装`Kubernetes组件`
3. 把`kubelet`加入到自启列表并启动

```shell
apt update && apt-get install -y apt-transport-https
export VERSION="v1.29"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://pkgs.k8s.io/core:/stable:/$VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

apt update

apt install -y kubelet kubeadm kubectl

sudo systemctl enable --now kubelet
```

## 创建集群

### 将镜像拉取到本地

#### 官方源(推荐国外服务器)

选项:
`--kubernetes-version  1.29.1`: 可选, 指定Kubernetes的组件版本, 这里为`1.29.1`

```shell
kubeadm config images pull --kubernetes-version 1.29.1
```

`apiserver-advertise-address`需要使用本机上网卡的ip，否则的话会导致`etcd`绑定ip失败启动不了，从而`apiserver`也启动不了,
选择一个初始化方式执行即可

#### 阿里源(推荐国内服务器)

选项:
`--image-repository`: 第三方源地址

```shell
kubeadm config images pull \
--image-repository registry.cn-hangzhou.aliyuncs.com/google_containers
```

### 初始化第一个控制节点

#### [预检](https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-init-phase/#cmd-phase-preflight)

在初始化前检查集群必要的配置是否完成, 提高安全性

- 命令行

```shell
kubeadm init phase preflight --dry-run
```

- 配置文件对 kubeadm init 进行预检

```shell
kubeadm init phase preflight --dry-run --config kubeadm-config.yaml
```

**在一个控制平面节点执行, 推荐master1**, **Shell指令生成**和**文件配置方式**只需要执行一种即可!

#### Shell指令生成

[kubeadm init的运行流程](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#init-workflow)

所用到的参数,
完整的参数请参考[kubeadm init args](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node):

- --kubernetes-version: Kubernetes版本
- --control-plane-endpoint: 为控制平面指定稳定的 IP 地址或 DNS 名称, 例如:`192.168.0.152`, `cluster-endpoint`
- --apiserver-bind-port: apiserver要绑定到的端口
- --image-repository: 镜像仓库的地址, 国内服务器推荐替换为阿里云源:`registry.cn-hangzhou.aliyuncs.com/google_containers`
- --service-cidr: Use alternative range of IP address for service VIPs
- --[pod-network-cidr](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network):
  指定容器网络的 IP 地址范围。如果设置，控制平面将自动为每个节点分配 CIDR
- --upload-certs:用来将在所有控制平面实例之间的共享证书上传到集群. 相反，你更喜欢手动地通过控制平面节点或者使用自动化工具复制证书，
  请删除此参数并参考如下部分[证书分配手册](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/high-availability/#manual-certs)
- --cri-socket: CRI(容器网络接口)的socket地址, 本文使用`containerd`作为容器运行时,默认是
  `/run/containerd/containerd.sock`, 但有时候是`/var/run/containerd/containerd.sock`, 如果出现异常,
  参考常见问题和该[issues](https://github.com/kubernetes/kubernetes/issues/110383)
- --v=5 详细的输出
- --ignore-preflight-errors=all: 忽略所有的异常, 除非你知道你在做什么,否则不要使用

```shell
kubeadm init \
--kubernetes-version=1.28.4 \
--control-plane-endpoint="192.168.0.152" \
--apiserver-bind-port="6443" \
--image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers \
--service-cidr=10.96.0.0/12 \
--pod-network-cidr=10.244.0.0/16 \
--upload-certs \
--cri-socket=unix:///run/containerd/containerd.sock \
--v=5
```

#### 文件配置方式

##### [在 IPVS 模式下运行 kube-proxy](https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/ipvs/README.md#run-kube-proxy-in-ipvs-mode)

1. 生成默认的初始化配置的文件信息,
   详情参考[kubeadm config print init-defaults](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/#cmd-config-print-init-defaults)

```shell
kubeadm config print init-defaults > kubeadm-init-conf.yaml
```

2. 修改默认的初始化配置的文件信息, 根据实际需要修改, **包含注释的参数是建议修改项**
   重点项: nodeRegistration.criSocket: 默认socket的地址是`unix:///var/run/containerd/containerd.sock`,
   但有时候containerd(例如二进制方式安装时)的socket是`unix:///run/containerd/containerd.sock`, 出现了
   `validate service connection: validate CRI v1 runtime API for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unimplemented desc = unknown service runtime.v1.RuntimeService"`
   的问题时尝试替换, 这是可能的[解决方案的参考](https://github.com/kubernetes/kubernetes/issues/110383)
   , error: exit status 1`

```yaml
# Source: kubeadm-init-conf.yaml
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
  - groups:
      - system:bootstrappers:kubeadm:default-node-token
    token: abcdef.0123456789abcdef
    ttl: 24h0m0s
    usages:
      - signing
      - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.0.152 # 改为你的Master IPv4或者IPv6地址
  bindPort: 6443
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: master-152 # 建议不使用与/etc/hostst的自定义的域名相同的名称
  taints: null
---
apiVersion: kubeadm.k8s.io/v1beta3
apiServer:
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: 1.28.4 # 当前安装的Kubernetes版本
controlPlaneEndpoint: kube-apiserver:6443 # 控制节点的IP或者apiserver的负载均衡的地址, 例如kube-apiserver:6443
networking:
  dnsDomain: cluster.local # 集群DNS地址
  serviceSubnet: 10.96.0.0/12 # Svc的网段地址配置
  podSubnet: 10.244.0.0/16 # Pod的网段地址配置
scheduler: {}
# 以下是KubeProxy的配置, 如果是使用IPVS模式就进行如下配置, 如果不是, 删除---下的内容
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs # 使用IPVS模式
```

#### 下载所需的镜像(可选)

**该步骤可以跳过, 但推荐国内服务器采用该步骤, 默认在加入集群时下载, 可提前使用国内源下载**

1. 在需要加入集群的控制节点上查询需要的镜像

```shell
kubeadm config images list
```

2. 选择一个源进行拉取镜像(可选)

- 阿里云源:

> registry.k8s.io/coredns/coredns:v1.10.1 该镜像可能在阿里云的源不存在, 需要从官方源单独pull

```shell
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.28.2
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.28.2
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.28.2
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.28.2
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.9-0
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns/coredns:v1.10.1
ctr images pull registry.k8s.io/coredns/coredns:v1.10.1
```

- 官方源:

```shell
ctr images pull registry.k8s.io/kube-apiserver:v1.28.2
ctr images pull registry.k8s.io/kube-controller-manager:v1.28.2
ctr images pull registry.k8s.io/kube-scheduler:v1.28.2
ctr images pull registry.k8s.io/kube-proxy:v1.28.2
ctr images pull registry.k8s.io/pause:3.9
ctr images pull registry.k8s.io/etcd:3.5.9-0
ctr images pull registry.k8s.io/coredns/coredns:v1.10.1
```

3. [验证 kubeadm配置API文件](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-config/#cmd-config-validate)
   并报告任何警告和错误。如果没有错误，则退出状态将为零，否则为非零。任何解封问题（例如未知的 API 字段）都会触发错误。未知的
   API 版本和具有无效值的字段也会触发错误。根据输入文件的内容，可能会报告任何其他错误或警告。

```shell
kubeadm config validate --v=5 --config=kubeadm-init-conf.yaml
```

#### 执行初始化

```shell
kubeadm init --v=5 --config kubeadm-init-conf.yaml
```

初始化成功一般有如下输出:

```
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.0.152:6443 --token mv274d.pnyhrlx36y6dle1b \
        --discovery-token-ca-cert-hash sha256:59b2b7da05ffe85d0686595a1a3e388f1bd403e045e85712c5884faf6cdf0ea7
```

如果没有令牌，可以通过在控制平面节点上运行以下命令来获取它：

```bash
kubeadm token list
```

复制`kubeadm join ...`整段, 保存到方便记忆的地方, 下文需要使用

> 默认的token为24小时过期, 过期可重新创建一个

```shell
kubeadm token create --print-join-command
```

如果没有`--discovery-token-ca-cert-hash`的值，可以通过在控制平面节点上运行以下命令链来获取它：

```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

> 注意：由于集群节点通常按顺序初始化，因此 CoreDNS Pod 很可能都运行在第一个控制平面节点上。
> 为了提供更高的可用性，请在至少加入一个新节点`kubectl -n kube-system rollout restart deployment coredns`后重新平衡
> CoreDNS Pod。

#### master

1. 要重新上传证书并生成新的解密密钥，请在已加入集群节点的控制平面上使用以下命令:
   记录`certificate key`

```shell
kubeadm init phase upload-certs --upload-certs
```

2. 获取加入命令

```shell
kubeadm token create --print-join-command
```

上面命令可以简化:

```shell
echo "$(kubeadm token create --print-join-command) --control-plane --certificate-key $(kubeadm init phase upload-certs --upload-certs | tail -1)"
```

#### 创建配置文件

```shell
mkdir -p $HOME/.kube 
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

如果你只想初始化某一个步骤,
参考[kubeadm init phase kubeconfig](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init-phase/#cmd-phase-kubeconfig)

### 安装网络插件

目前有两个热门的网络插件

- flannel
- Calico

在选择网络插件时，应根据您的具体需求和环境特点进行选择。例如，对于需要高级网络策略和安全性的大型企业环境，Calico
可能是更好的选择。对于小型或中型集群，尤其是在易用性和快速部署方面有更高要求的情况下，Flannel 可能更合适。

#### 优点与缺点:

##### Calico

1. **网络模型**：Calico 使用纯三层路由（Layer 3）而不是覆盖网络，这意味着它可以提供近乎本地网络的性能。它支持
   BGP（边界网关协议），允许直接与物理网络交互。
2. **网络策略**：Calico 提供丰富的网络策略选项，允许细粒度的访问控制，这对于安全性要求较高的环境非常重要。
3. **灵活性和扩展性**：由于其使用的是标准的 IP 路由，Calico 在大规模和多云环境中表现良好。
4. **对 iptables 和 IPVS 的支持**：Calico 主要使用 iptables 来实现网络策略。尽管它支持 IPVS，但它的主要用途是在 Kubernetes
   中作为 kube-proxy 的替代方案，用于负载均衡而不是网络策略。

##### Flannel

1. **网络模型**：Flannel 主要提供一个简单的覆盖网络，通常使用 VXLAN 或 UDP 来封装 Pod 流量。这使得 Flannel
   在不同的环境中更易于部署，尤其是在不需要复杂路由策略的场景中。
2. **性能**：虽然 Flannel 的性能对于大多数应用来说已经足够，但它的覆盖网络模型可能在高吞吐量场景下比 Calico 稍逊一筹。
3. **简易性**：Flannel 的设计目标是简单易用，因此在配置和管理方面相对简单。

4. **对 iptables 和 IPVS 的支持**：Flannel 主要依赖于 iptables 来管理其网络流量。它不直接与 IPVS 交互，但可以在 Kubernetes
   使用 IPVS 作为 kube-proxy 模式时与之协同工作。

综合对比

- **性能**：Calico 通常提供更高的网络性能和更低的延迟，尤其是在需要直接路由而不是覆盖网络的场景中。
- **安全性和策略**：Calico 提供更高级的网络策略功能，适合需要复杂安全规则的环境。
- **简易性和易用性**：Flannel 在易用性方面占优，特别是在小型或简单的集群中。
- **可扩展性**：Calico 在大规模部署和复杂环境中表现更好。

#### Calico

#### flannel

分为两种情况: 选择最贴切你的实际, 选择一种进行安装

1. 如果机器有很多网卡的情况, 顾名思义, 网卡多需要单独下载文件修改配置
2. 普通创建

#### 如果机器有很多网卡的情况

1. 查看网卡, 网卡一般以`ens`开头

```shell
ip a
```

2. 拉取配置文件

```shell
wget https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

3. 修改配置
   在`kube-flannel.yml`编辑

```shell
vi kube-flannel.yml
```

在`containers`的`args`指定参数为你的网卡
参数说明: 选择一个即可

- --iface-regex="ens*" 正则匹配, 匹配ens开头的网卡
- --iface="ens160" 指定网卡, 指定ens160的网卡
  示例:

```
...
containers:
      - args:
        - --ip-masq
        - --kube-subnet-mgr
        - --iface-regex="ens*"
...
```

3. 应用配置

```shell
kubectl apply -f kube-flannel.yml
```

> 如果在此前已经安装了flannel, 先移除该flannel网卡

1. 安装网卡管理工具
2. 查看flannel的网卡
3. 关闭flannel的网卡
4. 移除flannel的网卡
   示例, 假设flannel的网卡为`flannel.1`

```shell
apt install net-tools # Ubuntu
yum install net-tools # RedHat

ip a
ifconfig flannel.1 down
ip link delete flannel.1
```

#### 普通创建

访问`https://kubernetes.io/docs/concepts/cluster-administration/addons/` 获取`flannel`配置文件

> 如果访问不了`github`, 手动下载`yaml配置文件`并`上传`再`使用` `kubectl apply -f <filename>` 命令

```shell
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

## 加入集群

### 工作节点加入集群

分为两种情况:

1. 此前没有使用`kubeadm join ...`的行为, 运行**全新配置并加入集群**步骤
2. 此前有使用`kubeadm join ...`的行为, 出现错误并解决的, 运行**重置之前配置并重新加入集群**步骤

#### 全新配置并加入集群

> 默认的token为24小时过期, 过期可在master节点上重新创建一个

```shell
kubeadm token create --print-join-command
```

复制master节点的`kubeadm init`生成输出的`kubeadm join ...`整段代码到**工作节点**上执行:

```shell
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

> 注意：由于集群节点通常按顺序初始化，因此 CoreDNS Pod 很可能都运行在第一个控制平面节点上。

为了提供更高的可用性，请在至少加入一个新节点后重新平衡 CoreDNS Pod:

```shell
kubectl -n kube-system rollout restart deployment coredns
```

#### 重置之前配置并重新加入集群

如果执行`kubeadm join ...`出现错误, 并解决错误后, 不能直接执行`kubeadm join ...` 必须使用 `kubeadm reset`
命令来完成。这个命令会清理当前节点上的所有 Kubernetes 相关配置，使其恢复到未加入集群的状态。执行完 `kubeadm reset -f`
后，你就可以再次尝试使用 `kubeadm join` 命令将节点加入集群

重置节点加入状态:

> 重置操作会删除集群的各种组件和配置，包括删除 etcd 数据库、删除 kubelet 和 kube-proxy 的配置，以及清理各种网络规则和
> iptables 规则等。

`kubeadm reset` 命令将首先检查当前集群状态，并在集群状态处于正常时执行重置操作。如果集群状态不正常，例如某些组件已经丢失或不可用，那么命令可能会拒绝执行重置并显示相关错误或警告信息。

`-f` 标志，强制执行重置操作，即使存在某些问题或警告，也会继续执行。

```shell
kubeadm reset -f
```

#### 加入集群:

##### 命令行

```shell
kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

> 注意：由于集群节点通常按顺序初始化，因此 CoreDNS Pod 很可能都运行在第一个控制平面节点上。

##### 配置文件

输出默认内容到标准文件[配置](https://kubernetes.io/zh-cn/docs/reference/setup-tools/kubeadm/kubeadm-config/#cmd-config-print-init-defaults):

```shell
kubeadm config print init-defaults > kube-join-default.yaml
```

编辑文件, 替换控制平面输出的值到配置文件中. 然后加入:

```shell
kubeadm join --conf=kube-join.yaml
```

### 优化配置

为了提供更高的可用性，请在至少加入一个新节点后重新平衡 CoreDNS Pod:

```shell
kubectl -n kube-system rollout restart deployment coredns
```

### 多控制节点加入集群

#### 生成新的证书

1. 备份旧证书

```sehll
mv /etc/kubernetes/pki/apiserver.{crt,key} .
```

2. 生成新的证书

```shell
kubeadm init phase certs apiserver --config kubeadm.yaml
```

3. 验证证书，确定包含新添加的SAN列表

```shell
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text 
```

如下输出:

```
DNS:apiserver-endpoint, DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, DNS:kubernetes.default.svc.cluster.local, DNS:m1, DNS:m2, DNS:m3, IP Address:10.96.0.1, IP Address:10.0.0.11, IP Address:10.0.0.3, IP Address:10.0.0.12, IP Address:10.0.0.13
```

4. 获取api-server的Pod名

```shell
kubectl get pods -n kube-system | grep kube-apiserver
```

5. 重启api-server
   将`<api-server>`替换为`kube-apiserver`的Pod名

```shell
kubectl delete pod/<api-server> -n kube-system
```

6. 保存新的配置

这步操作其实是把kubeadm的配置给保存在集群中， 以后添加新的节点就会读取这个配置

```shell
kubeadm init phase upload-config kubeadm --config kubeadm.yaml
```

当然你也可以手动编辑configmap

7. 生成证书的解密密钥, 将生成的解密密钥保存下来

```shell
kubeadm init phase upload-certs --upload-certs
```

#### 下载所需的镜像(可选)

**该步骤可以跳过, 但推荐国内服务器采用该步骤, 默认在加入集群时下载, 可提前使用国内源下载**

1. 在需要加入集群的控制节点上查询需要的镜像

```shell
kubeadm config images list
```

2. 选择一个源进行拉取镜像(可选)

- 阿里云源:

> registry.k8s.io/coredns/coredns:v1.10.1 该镜像可能在阿里云的源不存在, 需要从官方源单独pull

示例:
containerd:

```shell
ctr images pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.28.2
```

crictl:

```shell
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.28.2
```

- 官方源:

```shell
ctr images pull registry.k8s.io/kube-apiserver:v1.28.2
ctr images pull registry.k8s.io/kube-controller-manager:v1.28.2
ctr images pull registry.k8s.io/kube-scheduler:v1.28.2
ctr images pull registry.k8s.io/kube-proxy:v1.28.2
ctr images pull registry.k8s.io/pause:3.9
ctr images pull registry.k8s.io/etcd:3.5.9-0
ctr images pull registry.k8s.io/coredns/coredns:v1.10.1
```

#### 加入集群

1. 使用已存在master生成token

```shell
kubeadm token create --print-join-command
```

2. 需要加入集群的控制节点执行
   把上一步`kubeadm token create --print-join-command`生成的`kubeadm join`的代码和 **生成新的证书** 第7步骤生成的解密密钥填写到
   `<certificate-key>`中
   格式:

```shell
kubeadm join <control-plane-host>:<control-plane-port> \
--token <token>  \
--discovery-token-ca-cert-hash sha256:<hash> \
--control-plane \
--certificate-key <certificate-key> \
--v=5
```

示例:

```shell
kubeadm join 192.168.0.152:6443 \
--token hmhji2.plgsl2ahuz46jrwy \
--discovery-token-ca-cert-hash \sha256:e73311c1e5c5d17344e6b8850222d9d77c918dc28cfa7f660fa2adebc94fb060 \
--control-plane \
--certificate-key 3d4b444290e47ab8d019434c8c8127e0cd83b723b5fe719ebe626d8b10f0caeb \
--v=5
```

kubeadm init做的工作:

1. [preflight] 环境检查和拉取镜像(kubeadm config images pull)
2. [certs] 创建证书目录/etc/kubernetes/pki, 生成证书
3. [kubeconfig] 创建连接apiserver的配置文件目录/etc/kubernetes
4. [kubelet-start] 生成kubelet配置文件和启动
5. [control-plane] 使用静态pod启动master组件 /etc/kubernetes/manifests
6. [upload-config/upload-certs/kubelet] 使用 configMap 存储kubelet配置
7. [mark-control-plane] 给master节点添加标签
8. [bootstrap-token] kubelet 自动申请证书机制
9. [addons] 安装插件CoreDNS kubeproxy

### 检查集群状态

1. `master`执行, 检查全部Pod的状态, 着重检查CoreDNS与网络插件的状态

```shell
kubectl get no -owide
```

2. [检查机器是否使用了ipvs模式](https://github.com/kubernetes/kubernetes/blob/master/pkg/proxy/ipvs/README.md#cluster-created-by-kubeadm)

## 负载均衡(多平面控制节点推荐)

1. 编辑nginx配置文件

```shell
vi /path/to/nginx.conf
```

2. 添加负载均衡的配置

```
stream {
    include stream.conf;
}
```

3. 添加负载均衡配置文件

```shell
vi /path/to/nginx/conf.d/stream.conf
```

4. 根据实际情况修改如下内容:

```
upstream k8s-apiserver {  
    server master1:6443;  
    server master2:6443;  
}  
server {  
    listen 6443;  
    proxy_connect_timeout 1s;  
    proxy_pass k8s-apiserver;  
} 
upstream ingress-http {  
    server 10.0.0.21:30080;   # 这里需要更改成ingress的NodePort  
    server 10.0.0.22:30080;   # 这里需要更改成ingress的NodePort  
}  
server {  
    listen 80;  
    proxy_connect_timeout 1s;  
    proxy_pass ingress-http;  
}  
upstream ingress-https {  
    server 10.0.0.21:30443;   # 这里需要更改成ingress的NodePort  
    server 10.0.0.22:30443;   # 这里需要更改成ingress的NodePort  
}  
server {  
    listen 443;  
    proxy_connect_timeout 1s;  
    proxy_pass ingress-https;  
}
```

## 查看证书

1.检查apiserver证书信息

```shell
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text
```

2.
获取kubeadm生成的证书的[密钥](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/high-availability/#%E6%8E%A7%E5%88%B6%E5%B9%B3%E9%9D%A2%E8%8A%82%E7%82%B9%E7%9A%84%E7%AC%AC%E4%B8%80%E6%AD%A5)
证书密钥是一个十六进制编码的字符串，它是一个 32 字节大小的 AES 密钥。
`kubeadm-certs`Secret 和解密密钥会在两个小时后失效。

```shell
kubeadm certs certificate-key
```

## 优化设置

### [Kube-Proxy中启用 IPVS 模式](https://stackoverflow.com/questions/56493651/enable-ipvs-mode-in-kube-proxy-on-a-ready-kubernetes-local-cluster)

1. 编辑ConfMap:

```shell
kubectl edit configmap kube-proxy -n kube-system
```

2. 改成ipvs

```
...
mode: "ipvs"
...
```

3. 重启/删除kube-proxy的Pod

```
kubectl get po -n kube-system | grep kube-proxy # 列出kube-proxy的所有Pod

kubectl delete po -n kube-system | <kube-proxy Pod> # 删除列出的kube-proxy的所有Pod
```

4. 验证

```shell
kubectl logs [kube-proxy pod] | grep "Using ipvs Proxier"
```

### [Shell自动完成](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#enable-shell-autocompletion)

```shell
apt-get install bash-completion
or
yum install bash-completion


type _init_completion

source /usr/share/bash-completion/bash_completion
```

### [命令补全](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#enable-kubectl-autocompletion)

```shell
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl
```

如果您有 kubectl 的别名，则可以扩展 shell 补全以使用该别名：

```shell
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc
source ~/.bashrc
```

### 添加镜像加速(推荐国内服务器配置)

containerd推荐的镜像加速是以加速镜像网站(例如docker.io)作为目录形式

1. 添加镜像加速的路径
   修改containerd的配置文件(默认在/etc/containerd/), 找到大概在159行的`[plugins."io.containerd.grpc.v1.cri".registry]`
   选项, 添加

```shell
config_path = "/etc/containerd/certs.d"
```

2. 创建`/etc/containerd/certs.d/`作为被镜像网站的替代

```shell
mkdir -p /etc/containerd/certs.d
```

3. [参考](https://blog.csdn.net/IOT_AI/article/details/131975562)
   和[阿里云](https://help.aliyun.com/zh/acr/user-guide/accelerate-the-pulls-of-docker-official-images)配置加速镜像

### [控制平面节点以外的计算机控制集群](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#optional-controlling-your-cluster-from-machines-other-than-the-control-plane-node)

为了在其他计算机（例如笔记本）上获取 kubectl 以与您的集群通信，您需要将管理员 kubeconfig 文件从您的控制平面节点复制到您的工作站，如下所示：

```bash
scp root@<control-plane-host>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
```

示例: 在非控制平面的机器执行, 192.168.0.152为控制节点IP

```bash
scp root@192.168.0.152:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
```

通过brew安装的kubectl, 在zsh设置别名:

```zshrc
vi ~/.zshrc


# kubernetes
alias kubectl="/opt/homebrew/Cellar/kubernetes-cli/1.28.4/bin/kubectl --kubeconfig /Users/art/kubernetes/admin.conf"
```

### [控制平面节点上调度 Pod](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation)

出于安全原因，您的集群不会在控制平面节点上调度 Pod。如果您希望能够在控制平面节点上调度 Pod，例如对于单机 Kubernetes 集群，请运行：

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

输出将如下所示：

```
node "test-01" untainted
...
```

这将从任何拥有污点的节点（包括控制平面节点）中移除污`node-role.kubernetes.io/control-plane:NoSchedule`点，这意味着调度器将能够在任何地方调度
Pod。

### CoreDNS Pod优化

由于集群节点通常按顺序初始化，因此 CoreDNS Pod 很可能都运行在第一个控制平面节点上。
为了提供更高的可用性，请在至少加入一个新节点后重新平衡 CoreDNS Pod:

```shell
kubectl -n kube-system rollout restart deployment coredns
```

查看CoreDNS Pod 状态:

```shell
kubectl get pods -n kube-system

kubectl logs <Pod-Name> -n kube-system
```

## 集群稳定性

### [高可用Etcd集群](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/)

### [高可用集群](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)

## 重置/移除Kubernetes与组件

### [移除节点](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#remove-the-node)

仅在需要的时候操作

#### 移除workernode

在控制平面节点运行
在删除节点之前，请重置以下安装`kubeadm`状态：

- --delete-emptydir-data: 选项告诉 Kubernetes 在排空节点时删除使用 emptyDir 存储卷的 Pod 的数据。emptyDir
  存储卷是一种临时存储卷，它的数据只存在于节点上，而不会被迁移到其他节点。使用这个选项可以确保在排空节点时，与 emptyDir
  存储卷相关的数据也会被删除
- --force: 这个选项告诉 Kubernetes 强制执行排空操作，即使有一些 Pod 无法被控制器管理。这样可以确保即使有一些特殊情况出现，排空操作也能够继续进行
- ----ignore-daemonsets: 个选项告诉 Kubernetes 在排空节点时忽略 DaemonSet 管理的 Pod。DaemonSet 是一种保证在集群中每个节点上都运行一个
  Pod 的控制器。使用这个选项可以确保排空操作不会影响 DaemonSet 管理的 Pod

```shell
kubeadm reset -f

# 停止kubelet (workernode)
systemctl stop kubelet

# 排除<node-name>工作节点
kubectl drain <node name> --delete-emptydir-data --force --ignore-daemonsets
```

重置过程不会重置或清理 iptables 规则或 IPVS 表。如果你想重置 iptables，你必须手动重置:

```shell
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

如果要重置 IPVS 表，必须运行以下命令：

```bash
ipvsadm -C
```

删除`<node name>`工作节点

```shell
kubectl delete node worker2
```

移除安装的CNI

```shell
apt install net-tools # Ubuntu
yum install net-tools # RedHat

ip a

# CNI
ifconfig cni0 down
ip link delete cni0

# flannel
ifconfig flannel.1 down
ip link delete flannel.1

```

#### [移除master](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#clean-up-the-control-plane)

在控制平面节点运行

```shell
kubectl exec -it -n kube-system etcd-master1 -- /bin/sh  
  
# 查看etcd member list  
etcdctl --endpoints 127.0.0.1:2379 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key member list  
  
# 通过ID来删除etcd member  
etcdctl --endpoints 127.0.0.1:2379 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key member remove 12637f5ec2bd02b8
```

### 重置控制节点

#### 控制节点的Kubernetes集群信息

```shell
# Clean up CNI configuration
sudo rm -rf /etc/cni/net.d/*

# 清空集群配置
kubeadm reset -f

# Clean up kubeconfig files
rm -rf $HOME/.kube/config

# 删除etcd.yaml/kube-apiserver.yaml/kube-controller-manager.yaml/kube-scheduler.yaml配置信息
rm -rf /etc/kubernetes/manifests/*
```

#### 重置iptables规则

```shell
# Reset iptables
sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT
```

### Reset IPVS tables (if applicable)

```shell
sudo ipvsadm --clear
```

#### 重置工作节点的CNI网卡

```shell
apt install net-tools # Ubuntu
yum install net-tools # RedHat

ip a

# flannel
ifconfig flannel.1 down
ip link delete flannel.1

# CNI
ifconfig cni0 down
ip link delete cni0
```

### 删除Kubernetes

```shell
sudo rm -rf /opt/cni/bin/ # CNI网卡的路径

sudo rm -rf /etc/kubernetes/ # Kubernetes的安装位置
```

### 卸载CNI/网络插件的网卡

```
ip a
apt install net-tools # ubuntu
yum install net-tools # redhat

# 卸载移除CNI容器网络接口的网卡
ifconfig cni0 down
ip link delete cni0

# 卸载移除flannel容器网络接口的网卡
ifconfig flannel.1 down
ip link delete flannel.1

# 卸载移除kube-ipvs0容器网络接口的网卡
ifconfig kube-ipvs0 down
ip link delete kube-ipvs0

ip a
```

### 卸载删除Kubernetes

#### Ubuntu

#### 通过apt安装的Kubernetes

```shell
sudo apt-mark unhold kubeadm
sudo apt-mark unhold kubelet
sudo apt-mark unhold kubectl
apt remove -y kubeadm kubelet kubectl
```

#### RedHat

#### 通过yum安装的Kubernetes

```shell
yum uninstall -y kubeadm kubelet kubectl
```

### 删除crictl 镜像/容器

- 停止正在运行的容器和删除这些容器的镜像

```shell
crictl images | awk '{print $3}' | xargs -n 1 crictl rmi
```

- 用crictl命令停止和删除不存在的容器

```shell
running_containers=$(crictl ps -q)

# Check if there are running containers
if [ -n "$running_containers" ]; then
    # Stop and remove running containers
    echo "Stopping and removing running containers..."
    echo "$running_containers" | xargs -n 1 crictl stop
    echo "$running_containers" | xargs -n 1 crictl rm
else
    echo "No running containers found."
fi
```

- 删除未使用(非正在运行的)的镜像

```shell
crictl rmi --prune
```

## 常见问题

### 自诊断

rockyLinux系列错误: kubelet错误日志: 打开`/run/systemd/resolve/resolv.conf`DNS文件失败
解决方案1: 修改`kubeadm init`的文件的`KubeletConfiguration`Kind配置信息, 路径为你操作系统的文件路径

```yaml
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
resolvConf: /run/systemd/resolve/resolv.conf
```

解决方案2:

```shell
mkdir /run/systemd/resolve/
cp /etc/resolv.conf /run/systemd/resolve/resolv.conf
```

```shell
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a

crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock \
	--debug=true info -o go-template --template '{{.config.sandboxImage}}'
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock \
        --debug=true pull registry.aliyuncs.com/google_containers/etcd:3.5.10-0
crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock \
        --debug=true pull registry.k8s.io/etcd:3.5.10-0

ctr -n k8s.io images list
crictl -v
ctr -v
socat -h
runc -h
conntrack -h
ipvsadm -h
systemctl status kubelet
systemctl status kubeadm
systemctl status containerd
```

#### crictl

```shell
sudo crictl --runtime-endpoint unix:///var/run/crio/crio.sock version
```

可能的错误: `DEBU[0000] get runtime connection
FATA[0000] validate service connection: validate CRI v1 runtime API for endpoint "unix:///var/run/crio/crio.sock": rpc error: code = Unavailable desc = connection error: desc = "transport: Error while dialing: dial unix /var/run/crio/crio.sock: connect: no such file or directory"`
问题原因: crictl依次查找容器运行时，当查找第一个 unix:///var/run/dockershim.sock 没有找到，所以报错了，需要你手动指定当前kubernetes的容器运行时
[解决方案](https://www.cnblogs.com/LILEIYAO/p/17169234.html): 手动指定当前kubernetes的容器运行时, 例如`containerd`:

```shell
crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
```

检查: 会列出`/etc/crictl.yaml`的文件内容

```shell
crictl config --list


-> /etc/crictl.yaml
KEY                    VALUE
runtime-endpoint       unix:///var/run/containerd/containerd.sock
image-endpoint         unix:///var/run/containerd/containerd.sock
timeout                10
debug                  false
pull-image-on-create   true
disable-pull-on-run    false
```

### 基础环境问题

问题: `ebtables not found in system path`
解释: ebtables用于在Linux内核中设置以太网帧的过滤规则
解决:

```shell
apt install -y ebtables
```

错误原因: 没有安装`conntrack`这个包
解决方案: 下载`conntrack`这个包
Ubuntu:

```shell
sudo apt update
sudo apt install conntrack
```

2. `WARNING FileExisting-socat: socat not found in system path`

```shell
apt install socat -y
```

2. runc缺失
   runc是一个轻量级的容器运行时，用于生成和运行符合OCI（Open Container
   Initiative）规范的容器。它是一个命令行工具，用于根据OCI格式运行打包的应用程序，并且是符合OCI规范的实现。runc的目标是提供一个标准化的容器运行时，以便在不同的容器平台上实现容器的创建、配置和管理
   解决方案: 下载
   Ubuntu:

```
apt apt install runc
```

### kubeadm join

#### 连接控制节点失败

错误:
`Get "https://kube-apiserver:6443/api/v1/namespaces/kube-public/configmaps/cluster-info?timeout=10s": dial tcp 192.168.0.152:6443: connect: connection refused`
原因: 控制节点的网络出现问题, 需要解决网络问题
排查点1: 检查网络配置文件
Ubuntu22.04: 编辑网络配置文件, 查看是否存在问题:

```shell
vi /etc/netplan/00-installer-config.yaml
```

如果修改了网络配置文件, 需要应用, 无需重启:

```shell
netplan apply
```

### containerd

#### 缺少containerd.sock

错误原因:
`validate CRI v1 runtime API for endpoint \"unix:///var/run/containerd/containerd.sock\": rpc error: code = Unavailable desc = connection error: desc = \"transport: Error while dialing: dial unix /var/run/containerd/containerd.sock: connect: no such file or directory\"`

解决方式: 重启containerd

```shell
systemctl restart containerd
```

校验:

```shell
ls /var/run/containerd/
ls /run/containerd/
```

错误原因2: containerd的socket不是`unix:///var/run/containerd/containerd.sock`,而是
`unix:///run/containerd/containerd.sock`,
解决方案: 尝试在相关的(例如kubeadm init的containerd地址)重新替换路径

### 排除kubelet的配置文件问题

问题: /etc/systemd/system/kubelet.service.d/kubelet.conf:16: Assignment outside of section. Ignoring.

kubelet的默认配置文件在[github](https://github.com/kubernetes/release/releases) 查找到最新的版本,然后替换下面的`v0.16.4`
即可得到最新的配置文件
示例: https://raw.githubusercontent.com/kubernetes/release/v0.16.4/cmd/krel/templates/latest/kubeadm/10-kubeadm.conf.
参考[安装Kubelet](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/setup-ha-etcd-with-kubeadm/#setting-up-the-cluster)

```shell
systemctl status kubelet
```

out:

```
 Drop-In: /etc/systemd/system/kubelet.service.d
             └─10-kubeadm.conf, 20-etcd-service-manager.conf, kubelet.conf
```

查看配置文件是否正确

```shell
rm -rf /etc/systemd/system/kubelet.service.d
```

重载服务

```shell
systemctl daemon-reload
```

### 使用crictl排除Pod问题

- 重建kubeadm init所需的Pod

```shell
kubeadm config images list

# 重新安装, 根据上个命令复制替换镜像名已经对应的版本, 此示例为v1.28.4版本的Kubernetes所需Pod列表
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.28.4
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.28.4
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.28.4
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.28.4
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.9
crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.5.9-0
crictl pull registry.k8s.io/coredns/coredns:v1.10.1
```

- 停止正在运行的容器和删除这些容器的镜像

```shell
crictl images | awk '{print $3}' | xargs -n 1 crictl rmi
```

- 用crictl命令停止和删除不存在的容器

```shell
running_containers=$(crictl ps -q)

# Check if there are running containers
if [ -n "$running_containers" ]; then
    # Stop and remove running containers
    echo "Stopping and removing running containers..."
    echo "$running_containers" | xargs -n 1 crictl stop
    echo "$running_containers" | xargs -n 1 crictl rm
else
    echo "No running containers found."
fi
```

- 删除未使用(非正在运行的)的镜像

```shell
crictl rmi --prune
```

### [我该使用iptables还是IPVS](https://www.tigera.io/blog/comparing-kube-proxy-modes-iptables-or-ipvs/)

在群集中运行大约 1000 个服务和 10000 个 POD 之前，性能不会有太大变化。如果您在该级别运行带有 Kube-proxy的 IPVS
可能会对您有所帮助并提高性能。

如果您不确定 IPVS 是否会成为最终工具，那么请在 iptables 模式下坚持使用 kube-proxy。它有更多的生产环境的经验

### 节点NotReady

1. 节点NotReady
   检查所有Pod是否成功启动

```shell
kubectl get po -A
```

使用`kubectl describe po/<pod-name>` 查看Pod的具体问题, 具体问题具体处理

2. 节点NotReady情况2:
   查看cni插件是否安装完成:

```shell
kubectl get all -n kube-flannel
```

![[images/Pasted image 20231205232333.png]]
检查Pod情况, 如果依旧出现问题, 排除容器运行时与kubelet, 或者移除节点, 重新加入集群

3. 节点NotReady情况3:
   重新检查SeLinux是否为禁用状态!

4. CoreDNS Pod报错信息: had untolerated taint node.kubernetes.io/not-ready
   部署完K8S集群后，使用如下命令测试集群，进入pod中发现无法解析k8s默认域名和无法ping通外网，宿主机主机是可以ping通外网的

```shell
kubectl run busybox --image busybox:1.28 --restart=Never --rm -it busybox -- sh
```

out:

```
If you don't see a command prompt, try pressing enter.
/ # nslookup kubernetes.default
```

报错原因：k8s节点不可调度/有污点, Pod无法调度到当前Pod
解决方案: 移除污点

1. 获取污点信息

```shell
kubectl get nodes -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}: {.spec.taints[*].key}={.spec.taints[*].value}:{.spec.taints[*].effect}{end}'
```

将有如下输出

将`<node-name>`替换为工作节点名称, 例如`node1`
将`key`替换为实际的污点键, 例如`node.kubernetes.io/not-ready`

```bash
# 1、
kubectl taint nodes <node-name> key-

# 2、删除coredns
kubectl delete pod -n kube-system coredns-7f74c56694-24wql
kubectl delete pod -n kube-system coredns-7f74c56694-hsvpk
```

检查是否解决:
如下所示，则表示正常
下载网络调试的镜像, 检查Pod内是否可以进行正常的DNS通信:

```bash
kubectl run busybox --image busybox:1.28 --restart=Never --rm -it busybox -- sh
```

进入到容器后检查Pod内是否可以进行正常的DNS通信, 执行以下命令:

```
If you don't see a command prompt, try pressing enter.
/ # nslookup kubernetes.default
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      kubernetes.default
Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
/ # 
/ # ping www.baidu.com
PING www.baidu.com (14.119.104.189): 56 data bytes
64 bytes from 14.119.104.189: seq=0 ttl=56 time=18.861 ms
64 bytes from 14.119.104.189: seq=1 ttl=56 time=9.493 ms
64 bytes from 14.119.104.189: seq=2 ttl=56 time=26.687 ms
64 bytes from 14.119.104.189: seq=3 ttl=56 time=25.154 ms
```

### Kubelet

#### 无法读取/etc/kubernetes/manifests

错误: `Unable to read config path" err="path does not exist, ignoring" path="/etc/kubernetes/manifests"`
原因: 可能是由于Kubernetes工作节点在执行kubeadm join时未能创建所需的文件夹导致的
解决方案:

```shell
# 创建缺失的文件夹
sudo mkdir -p /etc/kubernetes/manifests

# 重启相关服务
sudo systemctl restart containerd
sudo systemctl restart docker #如果有
sudo systemctl restart kubelet
```

#### 无法打开/etc/resolv.conf文件

错误1: `Could not open resolv conf file." 和 "Failed to generate sandbox config for pod`
错误2: `Failedtocreatepodsandbox:open/run/systemd/resolve/resolv.conf:nosuchfileordirectory`
原因:DNS解析工具出现问题
解决方案: 参考[Failed to create pod sandbox](https://blog.csdn.net/zl8751/article/details/126308198)
与[安装systemd-resolved](https://zhuanlan.zhihu.com/p/560560443)
原因: 负责管理`/etc/resolv.conf`的工具(例如`systemd-resolved`)可能没启动, 尝试启动它
解决方案:

```shell
systemctl status systemd-resolved # 查看状态
systemctl start systemd-resolved # 启动

systemctl enable systemd-resolved # 加入自启列表
```

#### Nameserver超出限制

错误: `Nameserverlimitswereexceeded,somenameservershavebeenomitted,theappliednames`
原因: `/etc/resolv.conf`中超过3个`nameserver`, 默kubelet认的支持最大nameserver是3个
解决方案: 删除或注释掉`/etc/resolv.conf`中过多的`nameserver`

[缺少 Kubelet 配置 yaml](https://stackoverflow.com/questions/60297810/kubelet-config-yaml-is-missing-when-restart-work-node-docker-service)
错误:
`failed to load kubelet config file, path: /var/lib/kubelet/config.yaml, error: failed to load Kubelet config file /var/lib/kubelet/config.yaml, error failed to read kubelet config file`
原因: 使用kubeadm时因为某些错误原因没有生成kubelet的配置文件

1. 重新进行重置集群信息(worknode)

```shell
kubeam reset -f
```

2. 生成加入集群代码(master)

```shell
kubeadm token create --print-join-command 
```

3. 重新加入集群(worknode)

```shell
kubeadm join ...
```

### E1103 13:53:16.014716 3681399 memcache.go:265] couldn't get current server API group list: Get "https://192.168.0.152:6443/api?timeout=32s": net/http: request canceled (Client.Timeout exceeded while awaiting headers)

排查kubectl:

```bash
journalctl -u kubelet -f
or
journalctl -xeu kubelet -n 100
```

遇到
`"rpc error: code = Unavailable desc = connection error: desc = 'transport: Error while dialing: dial unix /run/containerd/containerd.sock: connect: no such file or directory'"`
可能是更新升级了`containerd`导致配置文件被覆盖, 检查`containerd`配置文件, 配置文件默认位置在`/etc/containerd/`, 检查是否被覆盖,
重写

```
cat /etc/containerd/config.toml
```

如果被覆盖, 把原本的换回去, 重新加载即可

```shell
systemctl restart containerd
```

### err="open /run/systemd/resolve/resolv.conf:nosuchfileordirectory"

错误原因: 禁用了`systemd-resolved`系统进程或者删除了`/run/systemd/resolve/resolv.conf`这个文件, 使用

```shell
systemctl status systemd-resolved
```

查看状态
解决方案: 尝试启用`systemd-resolved`, 它会自动创建`/run/systemd/resolve/resolv.conf`, 使用`/etc/resolv.conf`链接到该文件

```shell
systemctl start systemd-resolved
systemctl ebable systemd-resolved
```

### 排查apiserver

```shell
journalctl -u kube-apiserver -f
or
journalctl -xeu kube-apiserver
```

参考可能的解决[方案](https://www.cnblogs.com/gaorong/p/10925480.html)```

排查etcd:

```shell
journalctl -u etcd -f
or
journalctl -xeu etcd -n 100
```

参考可能的解决[方案](https://blog.csdn.net/weixin_48360967/article/details/130519929)

### kube-system

错误:
`flannel" failed (add): failed to delegate add: failed to set bridge addr: "cni0" already has an IP address different from xxx`
原因: cni0`的`inet`字段与coredns的ip网段不一致
解决方案:

```shell
apt install net-tools # Ubuntu
yum install net-tools # RedHat

ifconfig cni0 down
ip link delete cni0
```

### mktemp: 无法通过模板 "/tmp/tmp.XXXXXXXXXX" 创建文件: 只读文件系统

检查根路径/挂载的情况
检查挂载到根路径的硬件是否为rw(读写)权限, 如果设计到写权限的每条shell都有这个输出, 说明挂载到根路径的硬件可能是ro(只读,
read only)权限,
![[images/Pasted image 20231201201126.png]]

解决方案:

1. 临时:修改为根路径/为读写权限, 重启消失

```shell
mount -o remount,rw /
```

2. 永久修改
   使用`df -Th && mount`获取根路径的挂载点(上图下划线部分), 然后复制该路径, 编辑`/etc/fstab`, 将
   `/dev/mapper/ubuntu--vg-ubuntu--lv`替换为你的挂载点

```shell
df -Th && mount

sudo vi /etc/fstab

/dev/mapper/ubuntu--vg-ubuntu--lv / ext4 rw,relatime 0 1 # 示例, 不要直接复制, 根据你的时间挂载路径来填
```

## 资料

1. [更新证书](https://zahui.fan/posts/34d8fad0/)
2. https://zahui.fan/posts/b86d9e9f/
3. https://zahui.fan/posts/34d8fad0/
4. https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join-phase/#cmd-join-phase-kubelet-start
5. https://kubernetes.io/docs/setup/best-practices/node-conformance/
6. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm
7. http://lihuaxi.xjx100.cn/news/1484898.html?action=onClick
8. https://stackoverflow.com/questions/70558119/k8s-ingress-and-ipvs
