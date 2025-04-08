架构：

```mermaid
flowchart LR
	subgraph Kubernetes
	kubectl ==> API-Server
	Controller-Manager --- API-Server
	Cloud-Controller-Manager --- API-Server
	cloud --- Cloud-Controller-Manager
		subgraph cloud
		Google-GKE
		Microsoft-AKS
		Amazon-EKS
		end
	etcd --- API-Server
	sched调度器 --- API-Server

	API-Server --> Node1
	API-Server --> Node2
	API-Server --> Node3
	end

	subgraph Node1
	kubelet1
	kube-proxy1
		subgraph ctr-runtime1
		pod1-1
		pod1-2
		end
	end

	subgraph Node2
	kubelet2
	kube-proxy2
		subgraph ctr-runtime2
		pod2-1
		pod2-2
		end
	end

	subgraph Node3
	kubelet3
	kube-proxy3
		subgraph ctr-runtime3
		pod3-1
		pod3-2
		end
	end
	
```

## 作用

### 权限认证

当kubectl或者类似外部的UI界面的控制器等需要对Pod等资源进行管理时， 必须经过API-Server， 检查kubectl等工具是否有权限创建、删除等操作Pod的权限

### 网关

当kubectl等工具有权限对Pod等资源进行创建、删除等操作时， 会将转发这些操作给Sched调度器组件进行处理，
根据算法策略把Pod调度到合适的节点，也可以对Pod限制节点亲和性之类进行有权重调度
