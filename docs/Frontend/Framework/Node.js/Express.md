# Express

#Node #Express
[Express - Node.js Web 应用程序框架 (expressjs.com)](https://expressjs.com/)

> Node环境的网络处理框架

## 安装

> 提供三种包管理器的安装方式,选择一个你喜欢的安装即可

安装`express`

```shell
pnpm i express
yarn add express
npm i express
```

安装`express`依赖的`第三方库`

```shell
npm i http-errors
npm i morgan
npm i cookie-parser
```

可选安装

[type-is]([Express 5.x - API Reference (expressjs.com)](https://expressjs.com/en/5x/api.html#express.urlencoded))

```shell
npm i type-is 1.6.18
```

## 使用

1. 创建`package.json`包

> 可选参数: `-y`  全部设为默认值

```shell
pnpm init
yarn init
npm init
```

2. 创建文件入口,约定为`app.js`

> 项目====根目录====下终端`创建`或者右键`新建文件夹`
> powerShell 创建文件的指令为 `new-item <file>`
> cmd 创建指令为 `type nul> <file>`

```shell
new-item app.js
type nul> <file>
```

3. 配置

```js
//导入核心库 start
const express = require('express') // 核心库
const path = require('path') // Node内置路径库
const createError = require('http-errors') // 网络请求错误处理库
const logger = require('morgan') // 输出
const cookieParser = require('cookie-parser') // cookie 相关
//导入核心库 end

// 导入 用户配置 start
const indexRouter = require('./routes/index') // 首页路由, 手动创建
const userRouter = require('./routes/user')  // 用户路由, 手动创建 访问 /users 时匹配
// 导入 用户配置 end

// 使用 express 其本质是一个函数,封装了Node的网络请求
const app = express()  
  
// view engin setup 设置模pug板引擎  
app.set('views', path.join(__dirname, 'views'))  
app.set('view engine', 'pug')  
//app.set('view engine', 'jade')  
  
// 将中间件库添加到请求处理链  
app.use(logger('dev')) // logger库  
app.use(express.json())  
app.use(express.urlencoded({ extended: false }))  
app.use(cookieParser()) // Cookie处理库
app.use(express.static(path.join(__dirname, 'public'))) // 静态资源文件夹
  
// 导入路由  
app.use('/', indexRouter)  
app.use('/users', userRouter)  
  
// 错误处理器  
app.use((err, req, res, next) => {  
// 只在开发环境提供错误  
 res.locals.message = err.message  
 res.lcoals.error = req.app.get('env') === 'development' ? err : {}  
  
// 渲染出错页面  
 res.status(err.status || 500)  
 res.render('error')  
})  

// port 默认为 3000 端口
app.listen(3000, () => {  
 console.info('create succeed!') // 请求成功的响应消息
})  

// 导出app.js
module.exports = app
```

4. 创建`routes` 文件夹 存放路由相关文件

> 项目==根目录==下终端`创建` 或 右键`新建文件夹`

```
mkdir routes
```

5. 创建一个==首页==路由

```shell
mkdir index.js
```

`routes/index.js`

```js
const express = require('express')

const router = express.Router('/',(req,res,next)=>{
	res.send('Hello Express')
})
```

6. 创建一个==用户==路由

> 项目==根目录==下终端`创建` 或 右键`新建文件夹`

```shell
mkdir user.js
```

`routes/users.js`

```js
const express = require('express')

const router = express.Router('/',(req,res,next)=>{
	res.send('Welcome Back! User')
})
```

7. 启动

> 项目根目录运行

```shell
node app.js
```

## 可选

+ [antfu/esno： TypeScript / ESNext node runtime by esbuild (github.com)](https://github.com/antfu/esno) 在`Typescript`运行`Node`环境
+ [nodemon 保存时自动更新](https://www.npmjs.com/package/nodemon)
+ [pm2](https://www.npmjs.com/package/pm2)