
使用`nhooyr.io/websocket`, 而不是`gorilla/websocket`
nhooyr/websocket 支持gzip
gorilla/websocket 已经停止维护了

`gorilla/websocket` 有缺点。
它对 context 的支持不好。

它还有一个坑。websokcet 协议里有 close 命令
用于关闭 websocket。
但 gorilla 的 conn.Close 是关闭底层 tcp 链接。

虽然它有发送 close 命令的方法。
但是这个 conn.Close 的方法迷惑性太大了，
一不小心就用错了。
用错的话导致客户端会报 close pipe 错误。