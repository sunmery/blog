# 中间件

> 又名为消费者, 中间层

## 原理

- 客户端 -> 中间件 -> 路由
- 客户端发送`HTTP`到达路由之前经过中间件处理
- 类似于`express`的中间件, 使用`next()`, 客户端发送HTTP先经过这个中间件处理,之后在`next`下一步到达路由

## 使用

0. 创建`file.middleware.ts`文件
1. 使用`@Injectable`装饰
2. 需要实现中间件类型(class)`implements NestMiddleware`
3. 使用关键字`use`定义中间件
4. 使用`next`到达下一个路由
5. 中间件在`app.module`中使用
6. `app.module`需要继承`NestModule`
7. 使用关键字`configure`配置中间件
8. 使用关键字`apply()` 参数为定义的中间件, 例如`loggerMiddleware`
9. 使用`forRoutes`配置需要处理路由

- forRoutes()
- 参数为字符串时: 路由路径, 不带`/`
- 参数为控制器时: 与字符串处理相同, 处理控制器的路由, 例如`CatController`
- 参数为对象时:
- path 路由路径, 不带`/`
- method 处理请求方法的某一个
    - GET: RequestMethod.GET, 从`@nestjs/common`导入
    - ALL: RequestMethod.ALL

可选链:
exclued() 排除路由
inclued()

1. `forRoutes`例子

```js
configure (consumer: MiddlewareConsumer) {
		consumer
		.apply(LoggerMiddleware)
		.forRoutes({
			path: 'cat',
			method: RequestMethod.GET,
		})
	}
```
