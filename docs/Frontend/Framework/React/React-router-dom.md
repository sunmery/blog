# react-router-dom使用

## 安装

```
pnpm i react-router-dom
```

## 导入

1. 选择一种路由模式
    1. `BrowserRouter` 调用H5的history的路由跳转模式
    2. `HashRouter` 哈希模式的路由跳转模式
    3. ...
2. 链接路由. 使用`Link` 作为一个链接, 使用 `to`属性指向一个地址, 例如
   ```js
   import {Link} from 'react-router-dom';
   
   <Link to="/">Home</Link>
   ```

3. 展示路由. 使用`Routes` 元素包裹`Route`元素, `Route`元素使用`path`属性指向`Link`元素的`to`属性的地址, 这里可以写逻辑. 然后使用`element`指向要渲染的路由组件

```jsx
import {Home} from './Home';

<Routes>
	<Route path="/" element={<Home/>}></Route>
</Routes>
```