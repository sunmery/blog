## 谨慎使用JWT

JWT的作用其实很小, 仅适合:
1. 短期使用
一般生命周期很小, 例如告诉服务器A我需要服务器B的资源, 限制为短期, 例如5分钟之后过期, 过期无法继续使用服务器B的资源
2. 单次使用

## 特性

- Tokens 生命期较短。它们只需在几分钟内可用
- Tokens 仅单次使用。应用服务器应当在每次下载时颁发新的 Token。所以任何 Token 只用于一次请求就会被抛弃，不存在任何持久化的状态。
- 应用服务器依旧使用 Sessions。仅仅下载服务器使用 Tokens 来授权每次下载，因为它不需要任何持久化状态。
## 应用场景
有个文件服务，用户必须认证后才能下载文件，但文件本身存储在一台完全分离且无状态的「下载服务器」内。在这种情况下，你可能想要「应用服务器（服务器A）」颁发一次性的「下载Tokens」，用户能够使用它去「下载服务器（服务器B）」获取需要的文件
## 参考
[微信](https://mp.weixin.qq.com/s?__biz=MzAwMTE3MDY4MQ==&mid=2652471891&idx=1&sn=794dcf2609c55ed15673c00e646fa4ed&chksm=8130efc5b64766d363201de78dedc42edbf50628db10f4f945be5d15f6ab903de07f6a77cca9&mpshare=1&scene=23&srcid=1002dpwtSk1wb1S4YrYL7K8R&sharer_shareinfo=77032d11c0e9775438119da71f9bb4eb&sharer_shareinfo_first=77032d11c0e9775438119da71f9bb4eb#rd)
[0](https://learnku.com/go/t/52399)
[1](https://blog.csdn.net/qq_43035350/article/details/126036651)
[2](https://cloud.tencent.com/developer/article/1770768)