# 引入问题
如果旧 Consul 配置中心的机器因为各种原因不使用了, 需要迁移, 那么很多开发者第一时间想到的就是手动去 Consul 去 Consul UI 里一个一个去复制配置文件到新的机器, 这种方式就比较繁琐了, 还浪费大量时间, 而且配置一多, 需要的时间则更长

# 解决问题
使用 Consul 提供的 CLI 即可解决上面提到的问题, 只需要在新机器上安装 Consul CLI 即可, 然后使用两条命令即可完成上面提到的繁杂的步骤

# 使用

## 安装
参考`https://github.com/kubesun/docker-deploy/consul/cli`的 shell 命令
## 使用
导出原配置中心的数据
```bash
consul kv export -http-addr=<IP:PORT> ecommerce/ > consul-kv.json
```

新配置中心导入数据:
方式一: 在按照了 consul cli 的工具导入到新配置中心(快捷)
```bash
cat consul-kv.json | consul kv import -http-addr=<IP:PORT> -
```

方式二: 在新机器按照 consul cli并导入
```bash
consul kv import @consul-kv.json
```

输出:
![[Pasted image 20250413205931.png]]

# 参考
https://developer.hashicorp.com/consul/commands/kv/