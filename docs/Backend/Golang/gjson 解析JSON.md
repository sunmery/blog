## install
```shell
go get -u "github.com/tidwall/gjson"
```

## Use
```go
value := gjson.Get(json, "data.name").String()
```

其他库推荐:https://github.com/valyala/fastjson

## 参考

1. [掘金](https://juejin.cn/post/7150651352057249822)