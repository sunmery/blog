# 部署Kubernetes最新版v 1.27.1
|CreateDate|UpdateDate|Author|
|--|--|--|
|2023/04/27|2023/04/29|LisaSummer

## 前置
1. 清醒的脑子
2. 不要无脑复制
3. 灵活的双手
4. 搭配文中链接配合官网教程查阅
5. 查阅本文所使用配置清单的各种组件是否符合你的期望
6. 本文使用基于RPM的基于Red Hat Linux发行版的RockyLinux 8.0及9.1的amd64位版本部署
7. Linux基础知识
8. vi/vim基本的使用

> 截至`2023/04/27`本文基于Kubernetes最新版`v1.27.1`的版本进行部署

### 配置清单

#### 集群创建
使用`kubeadm`管理kunernets集群

#### 容器运行时(CRI)
使用`containerd`, 二进制文件使用Ubuntu和RockyLinux动态生成,其它发行版不保证

#### 容器网络接口(CNI)
使用`CNI plugins`

为什么需要?
在网络语境中，容器运行时（Container Runtime）是在节点上的守护进程， 被配置用来为 kubelet 提供 CRI 服务。具体而言，容器运行时必须配置为加载所需的 CNI 插件，从而实现 Kubernetes 网络模型

### 机器要求
- 至少2台兼容 deb/rpm 的 Linux 操作系统的计算机, 如：Ubuntu 或 CentOS, Rocky Linux
- 每台机器 2 GB 或更多的 RAM
- CPU 2 核心及以上。
- 集群中的所有机器的网络彼此均能相互连接（公网和内网都可以）。
- 节点之中不可以有重复的主机名、MAC 地址或 product_uuid。请参见[这里](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#verify-mac-address)了解更多详细信息。
- 开启机器上的某些端口。请参见[这里](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports)了解更多详细信息。
- 禁用交换分区。为了保证 kubelet 正常工作，你**必须**禁用交换分区。
  - 例如，`sudo swapoff -a`将暂时禁用交换分区。要使此更改在重启后保持不变，请确保在如`/etc/fstab`、`systemd.swap`等配置文件中禁用交换分区，具体取决于你的系统如何配置
- 有一个以上的网络适配器时你的 Kubernetes 组件通过默认路由不可达，添加 IP 路由规则， Kubernetes 集群就可以通过对应的适配器完成连接

### 搭建基础环境

#### 配置源
> 仅针对RockyLinux发行版

[RockyLinux换源参考](https://mirrors.ustc.edu.cn/help/rocky.html)

##### 替换默认的配置
对于 Rocky Linux 8，使用以下命令

```sh
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/Rocky-AppStream.repo \
    /etc/yum.repos.d/Rocky-BaseOS.repo \
    /etc/yum.repos.d/Rocky-Extras.repo \
    /etc/yum.repos.d/Rocky-PowerTools.repo
```

对于 Rocky Linux 9，使用以下命令

```sh
sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.ustc.edu.cn/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/rocky-extras.repo \
    /etc/yum.repos.d/rocky.repo
```

##### 更新缓存
```sh
dnf makecache
```

##### (可选) 删除并更新缓存
```
sudo yum clean all && dnf makecache
```

#### (可选)升级内核

##### 检查Linux 内核版本
```sh
uname -a
```

示例: `6.3.0-1.el8`为Linux内核版本
```
6.3.0-1.el8.elrepo.x86_64 #1 SMP PREEMPT_DYNAMIC Sun Apr 23 17:54:58 EDT 2023 x86_64 x86_64 x86_64 GNU/Linux
```

##### 添加ELRepo软件源
```sh
sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org 
sudo rpm -Uvh https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
```

##### 安装内核

> Q & A
> Q: error: Failed dependencies: system-release < 9 is needed by elrepo-release-8.3-1.el8.elrepo.noarch
> A: yum install -y elrepo-release

```sh
sudo yum --enablerepo=elrepo-kernel install kernel-ml
```

##### 重启系统
```sh
sudo shutdown -r now
```

#### 查看Linux主机架构

查看Linux主机架构, 并使用你架构所对应的软件包, 本文所使用系统是`x86_64`架构

```sh
uname -m
```

#### 设置主机名
主节点: 任意名. 推荐`master`作为控制平面节点名称
```sh
#master节点
hostnamectl set-hostname master
```

node节点, 任意名
```sh
hostnamectl set-hostname <node-name>
```

#### 建立虚拟机网卡

所有节点添加修改以下网卡配置

1. 将`<公网IP>`替换为你当前节点的公网IP
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

2. 重启网卡
    ```
    ifdown eth0  && ifup eth0
    ```

3. 重启网络
    ```sh
    systemctl restart network.service
    ```

4. 确认是否添加成功
    ```sh
    ip a
    ```

5. 修改kubelet启动参数文件（所有节点）
   修改kubeadm配置, 替换`<公网IP>`为当前节点公网IP

```
echo >> /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS --node-ip=<公网IP>
```

#### 添加hosts映射

格式:
```sh
echo "<master-IP>" master >> /etc/hosts
echo "<node1-IP>" node1 >> /etc/hosts
echo "<nodeN-IP>" nodeN >> /etc/hosts
```

示例:
```sh
echo "192.168.1.1" master >> /etc/hosts
echo "192.168.1.2" node1 >> /etc/hosts
echo "192.168.1.3" node2 >> /etc/hosts
```

#### 禁用交换分区

```shell
swapoff -a
sed -i 's/.*swap.*/#&/' /etc/fstab
```

#### 开放端口
查看并开启Kubernetes的端口使用[列表](https://kubernetes.io/zh-cn/docs/reference/networking/ports-and-protocols/)

或者: 关闭防火墙
```sh
systemctl stop firewalld
systemctl disable firewalld
```

#### 关闭SELinux
将 SELinux 设置为 permissive 模式（相当于将其禁用）

```bash
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

Q: 为什么?
A: 这是允许容器访问主机文件系统所必需的，而这些操作是为了例如 Pod 网络工作正常.直到 kubelet 做出对 SELinux 的支持进行升级为止
如果你知道如何配置 SELinux 则可以将其保持启用状态，但可能需要设定 kubeadm 不支持的部分配置
如果由于该 Red Hat 的发行版无法解析`basearch`导致获取`baseurl`失败，请将`\$basearch`替换为你计算机的架构。 输入`uname -m`以查看该值。 例如，`x86_64`的`baseurl`URL 可以是：`https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64`。

#### tc

`tc` 是 Linux 下用于 Traffic Control (流量控制) 的工具，通常用于网络带宽限制。

检查是否安装:

```
yum install -y which
which ts
```

如果`tc` 未安装:

```sh
sudo yum install iproute-tc -y
```

#### (可选)配置时间同步

```shell
yum install ntpdate -y
ntpdate ntp1.aliyun.com
```

## 部署

### 转发 IPv4 并让 iptables 看到桥接流量
```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 设置所需的 sysctl 参数，参数在重新启动后保持不变
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# 应用 sysctl 参数而不重新启动
sudo sysctl --system
```

#### 检查
1. 通过运行以下指令确认`br_netfilter`和`overlay`模块被加载：

    ```bash
    lsmod | grep br_netfilter
    lsmod | grep overlay
    ```

2. 通过运行以下指令确认`net.bridge.bridge-nf-call-iptables`、`net.bridge.bridge-nf-call-ip6tables`和`net.ipv4.ip_forward`系统变量在你的`sysctl`配置中被设置为 1：

    ```bash
    sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward
    ```


### 安装containerd

[参考](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)

> 二进制文件适用于Ubuntu和RockyLinux

因为将`systemd`配置为 `kubelet` 的 `cgroup` 驱动,`kubeadm` 把 `kubelet` 视为一个系统服务来管理,为了保持`kubelet`与`containerd`使用同一个系统服务器，所以也必须修改容器运行时(本文使用`containerd`)的配置, 让他们保持使用同一个
`cgroup`

1. 创建一个用于保存Kubernetes所需要的组件目录
    ```
    mkdir -p /k8s
    ```

2. 从[github](https://github.com/opencontainers/runc/releases) 下载最新版
示例: 下载最新版1.7.0,选择一种方法即可

- 在Linux主机使用`wget`安装
```sh
yum install -y wget
wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz
```

- 在Windows或Mac下载,然后上传至Linux主机
 语法:
```sh
scp <file> <username>@IP:<path>
```
    
示例:  将`k8s/`目录下所有的文件上传至`root`用户主机`192.168.0.24`的`/k8s`目录下
```sh
 scp ./k8s/* root@192.168.0.24:/k8s
```

3. 解压
    ```sh
    tar Cxzvf /usr/local /k8s/containerd-1.7.0-linux-amd64.tar.gz
    ```

4. 生成配置文件
    ```sh
    mkdir -p /etc/containerd
    containerd config default > /etc/containerd/config.toml
    systemctl daemon-reload 
    systemctl restart containerd
    ```

5. 检查安装
    ```sh
    ctr -v
    ```

#### 使用`systemd`作为启动containerd的系统组件
1. 新建`containerd.service`文件, 复制[配置文件](https://raw.githubusercontent.com/containerd/containerd/main/containerd.service)服务单元文件内容到`containerd.service`中
    ```sh
    vi containerd.service
    ```

2. 移动至`/usr/local/lib/systemd/system/containerd.service`
    ```sh
    mkdir -p /usr/local/lib/systemd/system/
    mv containerd.service /usr/local/lib/systemd/system/containerd.service
    ```

##### 添加国内源
###### kubernetes v.125.0版本之后
参考[发布说明](https://kubernetes.io/blog/2022/11/28/registry-k8s-io-faster-cheaper-ga/)
无需配置, 跳过此步骤

kubernetes v.125.0版本之后容器映像注册表已经从`k8s.gcr.io`到`registry.k8s.io`。这个新的注册表将负载分散到多个云提供商和区域，作为Kubernetes容器映像的一种内容交付网络(CDN)。这一变化减少了项目对单个实体的依赖，并为大量用户提供了更快的下载体验

###### kubernetes v.125.0版本之前配置
在`/etc/containerd/config.toml`的大致所在的`168`行处添加镜像配置:
在`[plugins."io.containerd.grpc.v1.cri".registry]`字段的`[plugins."io.containerd.grpc.v1.cri".registry.mirrors]`下添加

```sh
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
    endpoint = ["registry.aliyuncs.com/google_containers"]
 ```

 如图
![[Pasted image 20230427172338.png]]

将`sandbox_image`字段的值修改为`registry.aliyuncs.com/google_containers/pause:3.9`
大约在`66行处`,进行修改
```
    #sandbox_image = "registry.k8s.io/pause:3.8"
    sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
 ```

重启读取配置文件
 ```sh
    systemctl daemon-reload
    systemctl enable --now containerd
```

#### runc

1. 访问[github](https://github.com/opencontainers/runc/releases/download/)下载
示例: 下载最新版1.1.6,选择一种方法即可

- 在Linux主机使用`wget`安装
 ```sh
 yum install -y wget
 wget https://github.com/opencontainers/runc/releases/download/v1.1.6/runc.arm64
 ```

- 在Windows或Mac下载,然后上传至Linux主机

语法:
```
scp <file> <username>@IP:<path>
```

示例:  将`k8s/`目录下所有的文件上传至`root`用户主机`192.168.0.24`的`/k8s`目录下
```sh
scp ./k8s/* root@192.168.0.24:/k8s
```

```sh
install -m 755 /k8s/runc.amd64 /usr/local/sbin/runc
#验证, 有输出runc,commit,spec,go,libseccomp信息即为安装成功
runc -v
```

#### CNI plugins
1. 下载[cni](https://github.com/containernetworking/plugins/releases)
2. 创建`/opt/cni/bin`目录
3. 解压[cni](https://github.com/containernetworking/plugins/releases)到`/opt/cni/bin`

示例:
```sh
wget https://github.com/containernetworking/plugins/releases/download/v1.2.0/cni-plugins-linux-amd64-v1.2.0.tgz

mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin /k8s/cni-plugins-linux-amd64-v1.2.0.tgz
```

所有节点操作

```shell
#参考：https://github.com/containerd/containerd/blob/main/docs/cri/config.md#registry-configuration
#添加 config_path = "/etc/containerd/certs.d"
sed -i 's/config_path\ =.*/config_path = \"\/etc\/containerd\/certs.d\"/g' /etc/containerd/config.toml

mkdir /etc/containerd/certs.d/docker.io -p

cat > /etc/containerd/certs.d/docker.io/hosts.toml << EOF
server = "https://docker.io"
[host."https://vh3bm52y.mirror.aliyuncs.com"]
  capabilities = ["pull", "resolve"]
EOF
  
systemctl daemon-reload && systemctl restart containerd
```

#### cgroup
[配置cgroup](https://kubernetes.io/zh-cn/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/)

在 Linux 上，[控制组（CGroup）](https://kubernetes.io/zh-cn/docs/reference/glossary/?all=true#term-cgroup)用于限制分配给进程的资源.
kubelet 和容器运行时需使用相同的 cgroup 驱动并且采用相同的配置
由于 kubeadm 把 kubelet 视为一个系统服务来管理，基于 kubeadm 的安装推荐使用`systemd`驱动，

> 不推荐`cgroupfs`驱动。`cgroupfs`也是 `cgroup` 的管理器
> [参考](https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/)
> 因为某些Linux发行版,例如RockyLinux, CentOS使用`systemd`作为初始化系统的工具,初始化进程会生成一个root控制组(`cgroup`)充当`cgroup管理器`
> 导致systemd与`cgroupfs`会存在互相竞争的一个关系. 将造成系统中针对可用的资源和使用中的资源出现两个视图。某些情况下， 将 kubelet 和容器运行时配置为使用 `cgroupfs`、但为剩余的进程使用 `systemd` 的那些节点将在资源压力增大时变得不稳定

##### containerd配置cgroup的驱动

[配置systemdcgroup 驱动](https://kubernetes.io/zh-cn/docs/setup/production-environment/container-runtimes/#containerd-systemd)

结合`runc`使用`systemd`cgroup 驱动，在`/etc/containerd/config.toml`中设置：

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

或者: 将`SystemdCgroup`的`false` 替换为`true` 此方法需要自行查看, 可能会随着版本更新而变动, 谨慎使用
```sh
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
```

重启`containerd`读取配置文件
```sh
sudo systemctl restart containerd
```

#### 重载沙箱（pause）镜像
在你的[containerd 配置](https://github.com/containerd/containerd/blob/main/docs/cri/config.md)中， 你可以通过设置以下选项重载沙箱镜像：

###### 替换源
1. 将`sandbox_image`字段值修改为国内源, 例如将`registry.k8s.io/pause:3.2`改为`registry.aliyuncs.com/google_containers/pause:3.8`

> 官网默认为3.2的版本, 最新是3.9,containerd默认使用的是官网的3.8

```toml
[plugins."io.containerd.grpc.v1.cri"]
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.8"
```

2. 重启containerd
```sh
sudo systemctl restart containerd
```

#### 显式声明
初始化时显式声明使用`systemd`管理器

需要在使用`kubeadm init`管理初始化时使用配置文件或yml配置文件来显式声明
在`kubeadm-config.yaml`末尾添加如下内容, 本操作在后续步骤已添加
```yml
---
# 配置kubelet的CGroup为systemd
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd # 指定kubelet的CGroup为systemd, 搭配containerd使用
```

### 配置Kubernetes
基于Red Hat的发行版安装`kubelet`, `kubeadm` ,`kubectl`: 

**国内服务器**
1. 替换`baseurl`字段为国内源,例如`https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/`
2. 替换`gpgkey`字段的值为国内源,例如: `https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg

#### 替换源
国内源文件替换示例:
[参考](https://developer.aliyun.com/mirror/kubernetes/?spm=a2c6h.25603864.0.0.5124368fdag4jZ)
```shell
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
```

源文件:
```toml
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
```

#### 安装并加入到自启列表

> 由于官网未开放同步方式, 可能会有索引gpg检查失败的情况, 这时请用`yum install -y --nogpgcheck kubelet kubeadm kubectl`安装, [参考](https://developer.aliyun.com/mirror/kubernetes/?spm=a2c6h.25603864.0.0.55e253c3otrnFQ)

```sh
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet --now
systemctl start kubelet 
```

#### 检查安装
```sh
kubectl version --output=yaml
kubeadm version
kubelet --version
```

### 初始化

#### 初始化的阶段
1.  preflight 运行安装前检查
2. Certificate generation 生成证书
3. Generate all kubeconfig files necessary to establish the control plane and the admin kubeconfig file 生成建立控制平面所需的所有kubecconfig文件和admin kubecconfig文件
4. kubelet-start  Write kubelet settings and (re)start the kubelet 启动`kubelet`
5. etcd 生成建立控制平面所需的所有静态Pod清单文件
6. 更新kubeadm与kubelet的配置文件
7. 上传证书到kubeadm-cert
8. 将节点标记为控制平面
9. 生成token,用于将节点加入到集群
10. TLS引导后更新kubelet相关的设置
11. 安装通过一致性测试所需的附加组件
12. 显示控制与工作节点连接的指令

#### 初始化前运行检查

> 仅在master主节点操作

1. 生成默认的配置文件
```
kubeadm config print init-defaults > kubeadm-init.yml
```

2. 根据你的熟练情况编辑`kubeadm.yaml`文件, 注释处为基本需要修改的地方
`kubeadm.yml`内容大致如下:
```yml
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
  advertiseAddress: 192.168.58.131  # 修改为宿主机ip
  bindPort: 6443 # API 服务器绑定的端口
nodeRegistration:
  criSocket: unix:///var/run/containerd/containerd.sock
  imagePullPolicy: IfNotPresent
  name: master   # 修改为宿主机名
  taints: null
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
#imageRepository: registry.aliyuncs.com/google_containers # v.1.25.0版本以下修改为阿里镜像
kind: ClusterConfiguration
kubernetesVersion: 1.27.1  # 你安装kubeadm时的版本
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.244.0.0/16   ## 设置pod网段
scheduler: {}

###添加内容：配置kubelet的CGroup为systemd
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
```

3. 使用配置文件对 kubeadm init 进行启动检查。
语法:
```sh
kubeadm init phase preflight [flags]
```
选项:
- `--config` stringkubeadm 配置文件的路径。
- `--dry-run` 不做任何更改；只输出将要执行的操作。
- `-h`, --help
- `preflight` 操作的帮助命令
- `--ignore-preflight-errors strings` 错误将显示为警告的检查列表：例如：'IsPrivilegedUser,Swap'。取值为 'all' 时将忽略检查中的所有错误

```sh 
kubeadm init phase preflight --config kubeadm-init.yml --dry-run
```

#### 创建集群
1. 运行
```sh
kubeadm init --config kubeadm.yaml
```

或者:
```sh
kubeadm init \
  --apiserver-advertise-address="0.0.0.0" \ # 指定 kube-apiserver 组件对外广播的 IP 地址。这里设置为 0.0.0.0，表示监听所有网络接口
  --apiserver-cert-extra-sans=127.0.0.1,139.198.165.102,139.198.172.110 \ # 用于在生成 kube-apiserver 证书时添加额外的 Subject Alternative Names (SANs)
  --service-cidr="10.96.0.0/16" \ # 指定 Service 网络的地址段
  --pod-network-cidr="10.244.0.0/16" \ # 指定 Pod 网络的地址段
  --image-repository="registry.k8s.io" \ #镜像
  --kubernetes-version="1.27.1" \ # kubernetes版本
  --upload-certs --control-plane-endpoint="127.0.0.1" \ # 在初始化期间将证书和 kubeconfig 文件上传到 etcd 中
  --cri-socket="unix:///var/run/containerd/containerd.sock" # 指定容器运行时的地址
```

2. 把`containerd`加入到系统环境变量

```sh
export PATH=$PATH:/usr/local/bin/containerd
```

3.  将集群配置文件拷贝到当前用户的 .kube 目录下，并授权给当前用户使用
```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

(可选）从控制平面节点以外的计算机控制集群
[参考](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#optional-controlling-your-cluster-from-machines-other-than-the-control-plane-node)

为了使 kubectl 在其他计算机（例如笔记本电脑）上与你的集群通信， 你需要将管理员 kubeconfig 文件从控制平面节点复制到工作站，如下所示：

```bash
scp root@<control-plane-host>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf get nodes
```

(可选）将 API 服务器代理到本地主机
[参考](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#optional-proxying-api-server-to-localhost)

如果要从集群外部连接到 API 服务器，则可以使用 `kubectl proxy`：

```bash
scp root@<control-plane-host>:/etc/kubernetes/admin.conf .
kubectl --kubeconfig ./admin.conf proxy
```

你现在可以在本地访问 API 服务器 `http://localhost:8001/api/v1`

## 网络插件
安装网络插件(master节点)

**必须部署一个基于 Pod 网络插件的 [容器网络接口](https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/) (CNI)，以便你的 Pod 可以相互通信。 在安装网络之前，集群 DNS (CoreDNS) 将不会启动。**
-   注意你的 Pod 网络不得与任何主机网络重叠： 如果有重叠，你很可能会遇到问题。 （如果你发现网络插件的首选 Pod 网络与某些主机网络之间存在冲突， 则应考虑使用一个合适的 CIDR 块来代替， 然后在执行 `kubeadm init` 时使用 `--pod-network-cidr` 参数并在你的网络插件的 YAML 中替换它）。
-   默认情况下，`kubeadm` 将集群设置为使用和强制使用 [RBAC](https://kubernetes.io/zh-cn/docs/reference/access-authn-authz/rbac/)（基于角色的访问控制）。 确保你的 Pod 网络插件支持 RBAC，以及用于部署它的清单也是如此。
-   如果要为集群使用 IPv6（双协议栈或仅单协议栈 IPv6 网络）， 请确保你的 Pod 网络插件支持 IPv6。 IPv6 支持已在 CNI [v0.6.0](https://github.com/containernetworking/cni/releases/tag/v0.6.0) 版本中添加

根据自己的选择去安装网络插件。选择一种即可

### calico

```shell
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
```

重启containerd

```shell
systemctl restart containerd
```

### Flannel
通过此 [k8s](https://kubernetes.io/docs/concepts/cluster-administration/addons/)链接的README找到`Deploying Flannel with kubectl`字段的值
```sh
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

#### 其他指令

显示token列表
```sh
kubeadm token list
```

重新获取token：
```sh
kubeadm token create --print-join-command
```

获取`--discovery-token-ca-cert-hash`
```bash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```


### (可选)安装crictl

所有节点安装

[crict](https://kubernetes.io/zh-cn/docs/tasks/debug/debug-cluster/crictl/)
CRI-Tools是实现了CRI(容器运行时接口)的工具, 是kubernetes的kubelet管理和维护Pod所使用的默认工具

1. [下载地址](https://github.com/kubernetes-sigs/cri-tools/releases), 找到你对应kubernetes的版本, 例如版本为v.1.27.1的就去下载v1.27.0这个tag的软件包

2. 上传到服务器

```shell
tar -vzxf /crictl-v1.27.0-linux-amd64.tar.gz -C /usr/local/bin/

cat >>  /etc/crictl.yaml << EOF
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: true
EOF

systemctl restart containerd
```

### 配置ipvs

所有节点配置
从k8s的1.8版本开始，kube-proxy引入了IPVS模式，IPVS模式与iptables同样基于Netfilter，但是ipvs采用的hash表，iptables采用一条条的规则列表。iptables又是为了防火墙设计的，集群数量越多iptables规则就越多，而iptables规则是从上到下匹配，所以效率就越是低下。因此当service数量达到一定规模时，hash查表的速度优势就会显现出来，从而提高service的服务性能

[参考](https://cloud.tencent.com/developer/article/1717552#:~:text=%E5%9C%A8%E6%89%80%E6%9C%89%E8%8A%82%E7%82%B9%E4%B8%8A%E5%AE%89%E8%A3%85ipset%E8%BD%AF%E4%BB%B6%E5%8C%85%20yum%20install%20ipset%20-y,%E4%B8%BA%E4%BA%86%E6%96%B9%E4%BE%BF%E6%9F%A5%E7%9C%8Bipvs%E8%A7%84%E5%88%99%E6%88%91%E4%BB%AC%E8%A6%81%E5%AE%89%E8%A3%85ipvsadm%20%28%E5%8F%AF%E9%80%89%29%20yum%20install%20ipvsadm%20-y)

```shell
#安装ipset和ipvsadm
yum install ipset ipvsadm -y
#由于ipvs已经加入到了内核的主干，所以为kube-proxy开启ipvs的前提需要加载以下的内核模块
mkdir -p /etc/sysconfig/modules/
cat > /etc/sysconfig/modules/ipvs.modules << EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
#执行加载模块脚本
/bin/bash /etc/sysconfig/modules/ipvs.modules
#查看对应的模块是否加载成功
lsmod | grep -e ip_vs -e nf_conntrack_ipv4

#配置kubelet
cat >>  /etc/sysconfig/kubelet << EOF
# KUBELET_CGROUP_ARGS="--cgroup-driver=systemd"
KUBE_PROXY_MODE="ipvs"
EOF
```


## 启用 shell 自动补全功能
[参考](https://kubernetes.io/zh-cn/docs/tasks/tools/install-kubectl-linux/#optional-kubectl-configurations)
- yum:
```sh
yum install bash-completion -y
```

- apt-get
```sh
apt-get install bash-completi
```

检查安装
```sh
type _init_completion
```

不成功则使用需要手动添加内容到`bashrc`文件 
```sh
source /usr/share/bash-completion/bash_completion
```

## 启用 kubectl 自动补全功能

当前用户:
```sh
echo 'source <(kubectl completion bash)' >>~/.bashrc
```

或:

系统全局
```bash
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl
```

如果kubectl 有关联的别名，你可以扩展 Shell 补全来适配此别名：
示例: 
```bash
echo 'alias ct=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl ct' >> ~/.bashrc
source ~/.bashrc
```

## 清理集群

### 重新初始化集群
[参考](https://kubernetes.io/zh-cn/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tear-down)

在删除节点之前，请重置 `kubeadm` 安装的状态：

#### 语法: 
```sh
kubeadm reset [flags]
```

#### 选项:
- `--cert-dir string`     默认值："/etc/kubernetes/pki" 存储证书的目录路径。如果已指定，则需要清空此目录。
- `--cleanup-tmp-dir` 清理 "/etc/kubernetes/tmp" 目录
- `--cri-socket string` 要连接的 CRI 套接字的路径。如果为空，则 kubeadm 将尝试自动检测此值；仅当安装了多个CRI 或具有非标准 CRI 插槽时，才使用此选项。
- `--dry-run` 不做任何更改；只输出将要执行的操作。
- `-f`, `--force` 在不提示确认的情况下重置节点。
- `-h`, `--help` reset 操作的帮助命令
- `--ignore-preflight-errors strings` 错误将显示为警告的检查列表；例如：'IsPrivilegedUser,Swap'。取值为 'all' 时将忽略检查中的所有错误。
- `--kubeconfig string`     默认值："/etc/kubernetes/admin.conf" 与集群通信时使用的 kubeconfig 文件。如果未设置该标志，则可以在一组标准位置中搜索现有的 kubeconfig 文件。
- `--skip-phases strings` 要跳过的阶段列表

示例: 
```bash
kubeadm reset --cert-dir /etc/kubernetes/pki --cleanup-tmp-dir -f
rm -rf /etc/cni/net.d # 网络
rm -rf $HOME/.kube 
rm -rf /etc/kufebernetes/pki/* # 证书
rm -rf /var/etcd
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm --clear
rm -rf /var/lib/kubelet/kubeadm-flags.env # kubelet environment file with flags
rm -rf /etc/kubernetes/ # kubeconfig 文件
rm -rf /var/lib/kubelet/config.yaml # kubelet configuration
rm -rf /etc/kubernetes/manifests # control plane as static Pods
```

#### 重置iptables 
重置过程不会重置或清除 iptables 规则或 IPVS 表。如果你希望重置 iptables，则必须手动进行：

```bash
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
```

#### 重置 IPVS 表
如果要重置 IPVS 表，则必须运行以下命令：

```bash
ipvsadm -C
```

#### 删除节点

```bash
kubectl delete node <节点名称>
```

### 清除集群
```sh
rm -rf /etc/cni/net.d
rm -rf $HOME/.kube
rm -rf /etc/kufebernetes/pki/*
rm -rf /var/etcd
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
ipvsadm --clear
```
![[II74`B0FZ0AJLEX[0O3_(`B.jpg]]

<a name="1">asdasd</a>

## 异常参考
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

## 参考
1. [CentOS换源](https://developer.aliyun.com/mirror/centos?spm=a2c6h.13651102.0.0.534d1b11Nur8R4)
2. [阿里云.RockyLinux换源](https://developer.aliyun.com/mirror/rockylinux?spm=a2c6h.13651102.0.0.732c1b11ZpJVoU)
