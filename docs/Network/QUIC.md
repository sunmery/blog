# UDP 缓冲区大小

有些公有云的机器的配置没有对 UDP 进行特别优化, 在 Linux 上，缓冲区大小这个值相当小，对于高带宽 QUIC 传输来说太小了。
为了保证能够最大化利用 QUIC 的特性, 参考[quic-go](https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes)
推荐手动设置如下配置:

```bash
sysctl -w net.core.rmem_max=7500000
sysctl -w net.core.wmem_max=7500000
```
