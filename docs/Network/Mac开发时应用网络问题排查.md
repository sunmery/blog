
最主要的原因是应用在启动时你没有授权应用访问网络权限导致 Mac 防火墙拦截应用端口

**本地防火墙拦截** 

微服务端口（30000-30026）可能被 macOS 防火墙或第三方安全软件拦截：

- 临时禁用防火墙测试：  
  
```
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off  
```

- 永久放行端口：  

```
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --addport 30005/tcp  
```
   
重启网络服务
```bash
sudo networksetup -setv4off Wi-Fi && sleep 5 && sudo networksetup -setdhcp Wi-Fi
```

清理 DNS 缓存
```
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder
```

查看规则

```
sudo pfctl -s rules
```

检查路由表

```
netstat -nr | grep 192.168.3.220 
```

  

检查端口

```
netstat -s | grep -E 'listen|drop'
```

  

检查流量

```
sudo tcpdump -i any port 30005 -vv
```

