业务层, 所有的业务逻辑, 以及数据库模型(Model)都在在此写的

`XxxUseCase`业务场景集合, 对应 DDD 的领域

例如: `userUseCase` 用户的业务场景: 操作数据库, 日志服务
```go
type UserUseCase struct {
	repo UserRepo
	log *log.Helper
}
```