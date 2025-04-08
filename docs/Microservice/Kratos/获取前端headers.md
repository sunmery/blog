在任意有ctx context的地方使用即可:

1. https://juejin.cn/post/7372863316911226921
2. https://github.com/orgs/go-kratos/discussions/1925

```go
import "github.com/go-kratos/kratos/v2/transport"

func (s *CasdoorService) Userinfo(ctx context.Context, req *pb.UserinfoRequest) (*pb.UserinfoReply, error) {
	tr, ok := transport.FromServerContext(ctx)
	if !ok {
		fmt.Println("获取header失败")
		return nil, errors.New("获取header失败")
	}
	header := tr.RequestHeader()
	authorization := header.Get("Authorization")

	result, err := s.cc.Userinfo(ctx, &biz.UserinfoRequest{
		Authorization: authorization,
	})
}
```
