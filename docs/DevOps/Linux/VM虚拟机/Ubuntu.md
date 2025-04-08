## 网络

### 桥接

https://zhuanlan.zhihu.com/p/674760081

1. vm主界面 -> 编辑 -> 编辑虚拟网络
2. Change Setting -> 编辑VMnet0 -> 选择桥接(Bridged)
3. 如果是WIFI, 选择 Intel(R) Wireless-AC 开头的设备
4. 如果是有线网络, 选择 Intel(R) Ethernet 开头的设备
5. 点击apply(应用)
   ![[img/Pasted image 20240226174000.png]]

然后在虚拟机标签页:

1. 虚拟机标签页右键-> 设置
2. 网络适配器 -> 网络连接 -> 自定义 -> 选择刚刚创建的VMnet0
   ![[img/Pasted image 20240226174059.png]]
