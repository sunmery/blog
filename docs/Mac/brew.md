1. https://mac.install.guide/homebrew/4.html
https://blog.csdn.net/qq_39636712/article/details/116210586

- `brew install node` 默认安装最新版
- `brew install node@14.16.8` 安装指定版本
- `brew switch node 16.0.0` 切换版本

### **4.2 更新软件**

- `brew upgrade name` 更新安装过的软件(如果不加软件名，就更新所有可以更新的软件)

### **4.3 卸载软件**

- `brew uninstall node` 卸载node

### **4.4 服务相关**

- `brew services list` 获取services列表
- `brew services start/stop/restart serverName`

- `brew services start mysql` 启动mysql服务
- `brew services restart mysql` 重启mysql服务
- `brew services stop mysql` 停止mysql服务

### **4.5 其他常用命令**

- `brew config` 查看brew配置
- `brew info node` 查看node安装信息
- `brew list` 查看已安装软件
- `brew list --versions` 查看已安装软件版本号
- `brew search node` 搜索可用node相关软件
- `brew update` brew自身更新
- `brew cleanup` 清除下载的缓存
- `brew doctor` 诊断brew，并给出修复命令