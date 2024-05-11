## 核心
利用`Redux Toolkit`内置的`subscribe`订阅函数来监听`configureStore`的 `reducer`对象的变化, 
如果状态发生改变,那么就存储到浏览器的存储(localStorage本地存储 or sessionStorage会话存储)

## 格式
store总配置文件`index`
```ts
import { configureStore } from '@reduxjs/toolkit'
import { ToolkitStore } from '@reduxjs/toolkit/dist/configureStore'

const reducers: ReducersType = {}

export const store: ToolkitStore = configureStore({
	reducer: reducers,
})

// 状态变化时自动存储到浏览器本地存储,实现刷新时状态不丢失
store.subscribe(() => {
	const state = store.getState()
	localStorage.setItem('state', JSON.stringify(state))
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch
```

`slice`
```ts
import type { PayloadAction } from '@reduxjs/toolkit'
import { createSlice } from '@reduxjs/toolkit'

const initialValue: { value: Users } = {
	value: {},
}

const cache = localStorage.getItem('state') || initialValue
const initialState = typeof cache === 'string' ? JSON.parse(cache).profile : cache

export const profileSlice = createSlice({
	name: 'profile',
	initialState,
	reducers: {}
})

export default profileSlice.reducer
```

## 示例
store总配置文件
```ts
import { configureStore } from '@reduxjs/toolkit'
import { ToolkitStore } from '@reduxjs/toolkit/dist/configureStore'

import messageReducer from '@/features/im/message'
import roomReducer from '@/features/im/room'
import themeReducer from '@/features/theme/mode'
import profileReducer from '@/features/user/profile'
import specialtyReducer from '@/features/user/specialty'
import type { ReducersType } from '@/type'


const reducers: ReducersType = {
	profile: profileReducer,
	room: roomReducer,
	message: messageReducer,
	specialty: specialtyReducer,
	theme: themeReducer,
}

export const store: ToolkitStore = configureStore({
	reducer: reducers,
})

// 状态变化时自动存储到浏览器本地存储,实现刷新时状态不丢失
store.subscribe(() => {
	const state = store.getState()
	localStorage.setItem('state', JSON.stringify(state))
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

```

用户状态 `feat/user/profile`
```ts
import type { PayloadAction } from '@reduxjs/toolkit'
import { createSlice } from '@reduxjs/toolkit'

import type { Users } from '@/type'


const initialValue: { value: Users } = {
	value: {
		role: '',
		account: '',
		username: '',
		avatar: '',
		createdTime: new Date().getTime(),
		updatedTime: new Date().getTime(),
	},
}

const cache = localStorage.getItem('state') || initialValue
const initialState = typeof cache === 'string' ? JSON.parse(cache).profile : cache
export const profileSlice = createSlice({
	name: 'profile',
	initialState,
	reducers: {
		/**
		 * @description 更新个人信息
		 * @since 15/12/2022下午7:12
		 * @param state 状态
		 * @param payload { Users } 修改的内容
		 * @return 更新initialState的全部内容
		 *  */
		updateUserInfo: (state, {payload}: PayloadAction<Users>) => {
			state.value = {...payload}
		},
		/**
		 * @description 替换role内容
		 * @since 15/12/2022下午7:13
		 * @param state 状态
		 * @param payload string  角色权限
		 * @return 更新角色权限
		 *  */
		toggleRole: (state, {payload}: PayloadAction<string>) => {
			state.value.role = payload
		},
	},
})

// Action creators are generated for each case reducer function
export const {updateUserInfo, toggleRole} = profileSlice.actions

export default profileSlice.reducer

```
