## 异常类型：

- `Error: listen EACCES: permission denied 0.0.0.0:3000`
  或者启动 SS 时提示：
- `Shadowsocks Error: Port already in use...`
  又或者启动 Docker 时提示：
- `Error starting userland proxy: Bind for 0.0.0.0:50051: unexpected error Permission denied`

## 可能出现的原因：

1. docker启用`Hyper-V`
2. node程序没有联网权限
3. 电脑经过休眠后的出现的情况

## 解决方案

第一种：禁用 Hyper-V
第二种：添加需要排除的端口范围，如：`netsh int ipv4 add excludedportrange protocol=tcp startport=<PORT> numberofports=1`
第三种：重新启用 Hyper-V
第四种：尝试重启

如果上述的方案不可行，那么就需要自行尝试，以下是可能需要用到的指令

1. 查看端口占用：

> 将3000替换为你的端口

```powershell
netstat -ano | findstr "3000"
```

2. 杀掉进程

## 参考：

1. [文章](https://howiezhao.github.io/2021/06/01/win10-port-is-already-in-use-problem/)