# Pug

#Pug #Lib #Node
[Pug](https://pugjs.org/api/getting-started.html)

> 模板渲染引擎,便捷创建出HTML内容

> 应用场景: express

## 安装

```
pnpm i pug
pnpm add pug
yarn add pug
```

## 使用

### node的express环境:

### 示例

1. 导入

`node主文件入口 app.js`

```js
const express = require('express')
const app = express()
const {resolve} = require('path')

// 设置渲染的路径
app.set('view',resolve('views'))
// 设置pug为渲染模板引擎
app.set('view engine','pug')
```

2. 创建 `router` 路由文件夹

> 在根目录创建

```shell
mkdir routes
```

3. 在 `routes`  编写模板

`routes/index.js`

```js
const express = require('express')

const router = express.Router()

router.get('/',(req,res,next)=>{
	res.send('Hello', {title:'Express'})
})
```

4. 在`views` 编写 `pug` 模板

`views/index.pug`

```pug
block content
  h1= title
  p Welcome to #{title}
```