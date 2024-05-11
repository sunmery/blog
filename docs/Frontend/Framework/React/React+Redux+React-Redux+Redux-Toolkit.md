# React + Redux + Redux-Toolkit

### 创建一个空的`Redux`存储

src/store/index

```js
import {configurStore} from '@reduxjs/toolkit'
const store = configurStore({

  reducer:{
    
  }
})

export default store.reducer
```

### 与`React`连接

src/main

```js
import {Provider} from 'react-redux'
import {store} from './store/index.js'

ReactDOM.createRoot(document.getElementById('app')).render(
	<Provider store={store}>
  	<App/>
  </Provider>
)

```

### 创建行为

src/actions/index

```js
import {createSlice} from '@reduxjs/toolkit'

// 初始化参数
const initialState = {
	value: 0
}

export const bookSlice = createSlice({
  // redux标识
	name:'booksSlice',
  initiatlState,
  // 存储行为
  reducers:{
    // 行为1
    action1:(state,action)=>{
     state.value += action.payload
    },
    action2:(state)=>{
     state.value += 1
    }
  }
})

export const { action1,action2 } = bookSlice.actions
export default bookSlice.reducer
```

### 将行为存储到Redux存储当中

src/store/index

```js
import booksReducer from '../actions/index'

export const store = configurStore({
	reducer:{
		books: booksReducer
	}
})
```

### React使用

App.jsx

```js
import {useSelector, useDispatch} from 'react-redux'
import {store} from './store/index' 

const books = useSelector(state=>state.books.value)
const dispatch = useDispatch()
```