## Search
只需要在proto定义Search变量即可, 例如search为`http://localhost:3000/?name=lixia`, 那么在message定义相同名称的字段即可:
```protobuf
// 定义相同的名称, 会自动映射前端search参数
message QueryRequest {
  string name = 1;
}

service GreeterService {
  // Sends a greeting
  rpc SayHello (HelloRequest) returns (HelloReply) {
    option (google.api.http) = {
      get: "/api/v1/hello/{name}"
    };
  }

  rpc Query (QueryRequest) returns (QueryReply) {
    option (google.api.http) = {
      get: "/api/v1/query",
    };
  }
}
```

## Body
在body体定义需要接收的前端参数, 接收全部参数使用`*`
```protobuf
service GreeterService {
  rpc Query (QueryRequest) returns (QueryReply) {
    option (google.api.http) = {
      post: "/api/v1/query",
      body: "*"
    };
  }
}
```

