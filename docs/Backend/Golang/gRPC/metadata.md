# gRPC Metadata 使用核心指南

## 一元 RPC (Unary RPC)

### 客户端发送 Metadata

```go
// 创建初始 Metadata
md := metadata.Pairs("client-id", "12345", "auth-token", "bearer xyz")

// 方式1: 创建新上下文 
ctx := metadata.NewOutgoingContext(context.Background(), md)

// 方式2: 向现有上下文追加
ctx = context.Background()
ctx = metadata.AppendToOutgoingContext(ctx, "client-id", "12345")
ctx = metadata.AppendToOutgoingContext(ctx, "auth-token", "bearer xyz")

// 发起调用
response, err := client.UnaryRPC(ctx, request)
```
### 服务器接收 Metadata
```go

func (s *server) UnaryRPC(ctx context.Context, req *pb.Request) (*pb.Response, error) {
    // 获取客户端 Metadata
    md, ok := metadata.FromIncomingContext(ctx)
    if ok {
        // 获取特定值
        clientID := md.Get("client-id")
        authToken := md.Get("auth-token")
    }
    
    // 发送 Header Metadata
    header := metadata.Pairs("server-header", "value")
    grpc.SendHeader(ctx, header)
    
    // 设置 Trailer Metadata
    trailer := metadata.Pairs("server-trailer", "value")
    grpc.SetTrailer(ctx, trailer)
    
    return response, nil
}
```
### 客户端接收 Metadata

```go

response, err := client.UnaryRPC(ctx, request)

// 接收 Header
header, err := grpc.Header(ctx)

// 接收 Trailer
trailer := grpc.Trailer(ctx)
```
## 流式 RPC (Streaming RPC)

### 客户端发送 Metadata

```go

// 创建带 Metadata 的上下文
md := metadata.Pairs("stream-id", "stream-001")
ctx := metadata.NewOutgoingContext(context.Background(), md)

// 创建流
stream, err := client.StreamRPC(ctx)

// 追加额外 Metadata
ctx = metadata.AppendToOutgoingContext(ctx, "additional-data", "extra")
```
### 服务器接收 Metadata

```go

func (s *server) StreamRPC(stream pb.Service_StreamRPCServer) error {
    // 获取客户端 Metadata
    md, ok := metadata.FromIncomingContext(stream.Context())
    if ok {
        streamID := md.Get("stream-id")
    }
    
    // 发送 Header Metadata
    header := metadata.Pairs("stream-header", "value")
    stream.SendHeader(header)
    
    // 处理流...
    
    // 设置 Trailer Metadata
    trailer := metadata.Pairs("stream-trailer", "value")
    stream.SetTrailer(trailer)
    
    return nil
}
```
### 客户端接收 Metadata

```go

// 创建流后立即接收 Header
header, err := stream.Header()

// 流结束后接收 Trailer
trailer := stream.Trailer()
```
## 核心方法对比

### `NewOutgoingContext` vs `AppendToOutgoingContext`

|方法|用途|示例|
|---|---|---|
|**NewOutgoingContext**|创建新的带 Metadata 的上下文|`ctx := metadata.NewOutgoingContext(baseCtx, md)`|
|**AppendToOutgoingContext**|向现有上下文追加 Metadata|`ctx = metadata.AppendToOutgoingContext(ctx, "key", "value")`|

```go

// 组合使用示例
func prepareContext() context.Context {
    // 初始 Metadata
    baseMD := metadata.Pairs("request-id", "req-123")
    ctx := metadata.NewOutgoingContext(context.Background(), baseMD)
    
    // 动态追加 Metadata
    if authRequired {
        ctx = metadata.AppendToOutgoingContext(ctx, "authorization", token)
    }
    
    // 添加时间戳
    ctx = metadata.AppendToOutgoingContext(ctx, "timestamp", time.Now().Format(time.RFC3339))
    
    return ctx
}
```
## 最佳实践

1. **键命名规范**：

```go 
// 推荐小写 + 连字符格式
 metadata.Pairs("client-id", "123", "auth-token", "xyz")
```
2. **二进制数据**：
```go
// 使用 -bin 后缀标识二进制数据
 binData := []byte{0x01, 0x02}
md := metadata.Pairs("binary-header-bin", string(binData))
```
2. **错误处理中的 Metadata**：

```go
    // 服务器端
    if err != nil {
        trailer := metadata.Pairs("error-details", "Invalid input")
        stream.SetTrailer(trailer)
        return status.Errorf(codes.InvalidArgument, "invalid request")
    }
```
2. **客户端接收错误详情**：
    
```go
    
    if err != nil {
        st, _ := status.FromError(err)
        details := st.Details()
        trailer := grpc.Trailer(ctx)
    }
```

## 关键点总结

1. **客户端发送**：使用 `NewOutgoingContext` 或 `AppendToOutgoingContext`
    
2. **服务器接收**：使用 `metadata.FromIncomingContext`
    
3. **服务器发送**：
    
    - Header: `grpc.SendHeader()` (Unary) 或 `stream.SendHeader()` (Stream)
        
    - Trailer: `grpc.SetTrailer()` (Unary) 或 `stream.SetTrailer()` (Stream)
        
4. **客户端接收**：
    
    - Header: `grpc.Header()` (Unary) 或 `stream.Header()` (Stream)
        
    - Trailer: `grpc.Trailer()` (Unary) 或 `stream.Trailer()` (Stream)