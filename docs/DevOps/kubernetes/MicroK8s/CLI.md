- microk8s start 启动
- microk8s stop 停止
- microk8s status --wait-ready 在 Kubernetes 启动时检查状态
- Turn on the services you want  
- microk8s enable --help 获取内置的可用服务列表
打开所需的服务, 完整的[插件列表](https://microk8s.io/docs/addons#heading--list):
- microk8s enable dashboard dns registry istio 或者单独执行:
- microk8s enable dashboard
- microk8s enable dns
- microk8s enable registry
- microk8s enable istio
- microk8s dashboard-proxy WebUI
- microk8s enable cert-manager

开始使用 Kubernetes
microk8s kubectl get all --all-namespaces

## 常见问题
1. warning: "--mem" long option will be deprecated in favour of "--memory" in a future release. Please update any scripts, etc.
launch failed: instance "microk8s-vm" already exists
An error occurred with the instance when trying to launch with 'multipass': returned exit code 2.
Ensure that 'multipass' is setup correctly and try again.

2. [解决方案](https://discuss.kubernetes.io/t/installing-on-macos/24598): 
已经有一个名为 `microk8s-vm` 的多通道 VM，因此安装操作失败。尝试以下操作：

```shell
# delete VM 
multipass delete microk8s-vm 
multipass purge  

# reinstall 
microk8s install
```