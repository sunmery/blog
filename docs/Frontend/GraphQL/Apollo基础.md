# 基于Node+React的Apollo基础

Apollo 是一个用于构建[**超图**](https://www.apollographql.com/docs/intro/platform)的平台，这是一个由连接到应用程序客户端（如 Web
和本机应用程序）的所有数据、服务和功能组成的统一网络。超图的核心是一种名为**GraphQL**的查询语言。

## Node

### 目录结构:

`schema` : 架构目录
`data` : 数据目录
`app.js` 程序主入口

### 安装

下载`Apollo`后端服务与`Graphql`

```shell
pnpm i apollo-server graphql
```

### 定义架构

```
src/
	schema/
		index.js
		
	data/
		index.js
		
	app.js
```

> Tips
> 类型的命名的最佳实践是`Upper Camel Case`(大驼峰)命名法
> `Graphql`的`SDL`语法是必须要有一个根查询`Query`
> `!` 表示该类型不为空

**该架构有以下功能点**

1. 定义一个查询, 包含书籍`books`相关信息
2. 书籍`Books`的类型包含`id`,该`id`的类型是`ID`,该`id`不为空
3. `Books`包含`name`,`name`的类型是字符串
4. `Books`包含一个作者`author`集合`Author`类型,这个类型不为空
5. `Author`它包含`id`,`name`,`photo`,分别代表`ID`,`作者名称`,`作者照片`

src/schema/index.js

```js
const { gql} = require('apollo-server')
const typeDefs = gql`
	type Query {
		books: [Books]!
	}
	type Books:{
		id: ID!
		name: String!
		author:Author!
	}
	type Author{
		id: ID!
		name: String!
		photo: String
	}
`
```

### 模拟数据

与你的结构所定义的名称一致

1. 将`books`模拟成有`6组`相同的`books`信息
2. `Books`包含`id`,`name`
3. `Books`包含一个`Author`集合类型, 使用`JS`的对象来包含`Author`的属性`id`,`name`,`photo`

src/data/index.js

```js
const mocks = {
	Query :()=>({
		books:()=>[...new Array(6)]
	}),
	Books:()=>{
		id:()=> 'book id'
		name: ()=> 'book name'
		author: () => {
			return {
				id: 'author id',
				name: 'author name',
				photo: 'https://res.cloudinary.com/dety84pbu/image/upload/v1606816219/kitty-veyron-sm_mctf3c.jpg'
			}
		}
	},
	
} 
```

### 使用

1. 将`Apollo`应用连接到`Node`
2. 将架构`./schema`文件与数据`./data`文件导入到`Apollo`中
3. 开启`Node`服务API接口

src/app.js

```js
const {ApolloServer} = require('apollo-server')

const mocks = require('./data')
const typeDefs = require('./schema')

const server = new ApolloServer({
	typeDefs,
	mocks
})

server.listen(()=>{
	console.log('network!')
})
```

## React

### 安装

下载`Apollo`客户端与`Graphql

```shell
pnpm i apollo/client graphql
```

### 连接Apollo客户端

1. 将`Apollo`客户端接替`React`的API状态管理
2.

src/main.js

```js
import React from 'react'  
import ReactDOM from 'react-dom/client'  
import App from './App'
import {ApolloProvider,ApolloClient, InMemoryCache} from '@apollo/client'

const client = new ApolloClient({
	uri:'http://localhost:4000', //替换成你的Node服务的端口,默认4000
	cache: new InMemoryCache()
})

ReactDOM.createRoot(document.getElementById('root')).render(  
  <React.StrictMode>  
   <ApolloProvider client={ client }>  
    <App />  
   </ApolloProvider>  
  </React.StrictMode>,  
)
```

### 使用

1. 使用`Graphql`查询所需的接口
2. 使用`useQuery`API来获取`Graphql`返回的数据
3. 展示数据

src/App.jsx

```jsx
import { useQuery, gql } from '@apollo/client'

const Layout = () =>{
	const ALL_BOOKS = gql`
		query books{
			id
			name
			author{
				id
				name
				photo
			}
		}
	`

	const { data, loading, error } = useQuery(ALL_BOOKS)

	if (loading) return <strong>'Loading...'</strong>
	if (error) return <strong>'Error:'</strong>

	console.log(data)
	return <>code</>
}

function App() {  
 return (<>  
  <Layout />  
 </>)  
}
```