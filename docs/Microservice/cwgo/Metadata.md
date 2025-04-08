为了传grpc的meta, 需要添加

```go
// 为了传grpc的meta, 需要添加
	// Header: client.WithMetaHandler(transmeta.ClientHTTP2Handler),
	// Protocol: client.WithTransportProtocol(transport.GRPC),
	// Metadata: 你想接受的 metadata
	cli, err3 := demoservice.NewClient(
		"demo",
		client.WithResolver(r),
		client.WithMetaHandler(transmeta.ClientHTTP2Handler),
		client.WithTransportProtocol(transport.GRPC),
		client.WithClientBasicInfo(&rpcinfo.EndpointBasicInfo{
			ServiceName: "demo",
		}),
	)
	if err3 != nil {
		panic(err3)
	}
```

传递:

- metainfo.WithPersistentValue: 会一直存在与 metadata 中
- metainfo.WithValue: 只会传递到下一个服务

```go
ctx := metainfo.WithPersistentValue(context.Background(), "CLIENT_NAME", "demo")
	res, err2 := cli.Hello(ctx, &v1.Req{Name: "error"})
	
```

接收:

- metainfo.GetPersistentValue: 会一直存在与 metadata 中
- metainfo.GetValue: 只会传递到下一个服务

```go

clientName, ok := metainfo.GetPersistentValue(s.ctx, "CLIENT_NAME")
	if ok {
		fmt.Println("client name:", clientName)
	}
```

传递错误:
环境错误:

- 网络错误
  业务错误:
- 参数异常, 服务端模拟一个参数异常:
    - 1004001: 业务错误码
    - "client params error": 异常消息

```go
if req.Name =="error" {
		fmt.Printf("name:%s,err:%v\n",req.Name)
		return nil, kerrors.NewGRPCBizStatusError(1004001, "client params error")
	}
```

客户端接收并处理异常:

```go
var bizErr *kerrors.GRPCBizStatusError
	if err2 != nil {
		if ok := errors.As(err, &bizErr); ok {
			fmt.Printf("%#v\n", bizErr)
		}
		klog.Fatal(err2)
		return
	}
```
