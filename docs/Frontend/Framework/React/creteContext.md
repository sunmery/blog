A要给C传递数据:
通过props:
A -> B-> C
通过createContext:
A -> C

思路:

1. 在A组件中使用createContext的`Pro`对象传递数据
2. 在C组件中使用`createContext`的`Comser`对象接受数据

示例:

```jsx
import React, { createContext } from 'react'  
  
const { Provider, Consumer } = createContext()  
  
const CompC = () => {  
 return (  
   <Consumer>  
    { (msg) => <span>{ msg }</span> }  
   </Consumer>  
 )}  
  
const CompA = () => {  
  
 return (<>  
  <CompC></CompC>  
 </>)  
}  
  
  
class App extends React.Component {  
 state = {  
  list: 'this is comp a',  
 }  
  
 render() {  
  return (  
    <Provider value={ this.state.list }>  
     <CompA></CompA>  
    </Provider>  
  ) }  
}

```
注意点: `Consumer` 组件能在`{}`插值外部添加内容, 必须在`{}`插值表达式书写`JSX`