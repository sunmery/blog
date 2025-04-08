出现这种情况时候
```
# This is /run/systemd/resolve/resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients directly to
# all known uplink DNS servers. This file lists all configured search domains.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 100.96.0.2
nameserver 100.96.0.3
search .
```

```bash
vi /etc/systemd/resolved.conf
```

示例:
```
[Resolve]
DNS=8.8.8.8 8.8.4.4  # 替换为你需要的 DNS 服务器
FallbackDNS=1.1.1.1  # 备用 DNS
#Domains=yourdomain.com  # 添加搜索域
```