
## DTO
kratos的service业务服务层与api层:
以下例子是常见的service层的定义,在定义biz(业务逻辑)层结构体, 而不是直接使用proto的message?, 为什么kratos官方要这样做?

答: 因为proto定义的字段不一定全部给前端, 例如密码字段, 在返回给前端的时候不需要携带, 而在存储到数据时就需要用到, 通过两个struct隔离, 可以很好的做到前端需要什么就才返回什么. 例如类型不一致的问题, 通过DTO来转换前端需要的类型

DTO: 数据传输对象, 这里泛指API层与service层直接的数据传输对象, 通过deep copy,引用类型拷贝到那个对象去,
然后序列到api或者前端
```go
// CreateGoodsType 创建商品类型
func (g *GoodsServices) CreateGoodsType(ctx context.Context, r *v1.GoodsTypeRequest) (*v1.GoodsTypeResponse, error) {
	// DTO -> PO
	// 数据传输对象, 将proto转成go的结构体(deep copy)
	id, err := g.gu.GoosTypeCreate(ctx, &biz.GoodsType{
		ID:        r.Id,
		Name:      r.Name,
		TypeCode:  r.TypeCode,
		NameAlias: r.NameAlias,
		IsVirtual: r.IsVirtual,
		Desc:      r.Desc,
		Sort:      r.Sort,
	})
	if err != nil {
		return nil, err
	}
	return &v1.GoodsTypeResponse{
		Id: id,
	}, err
}

```
