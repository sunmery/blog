## 为什么需要环境变量?
1. 统一配置
2. 去除一个个文件替换

## 设置环境变量
我的最佳实践是在项目跟目录创建环境变量文件, 然后定义不同环境下的环境变量,例如, 通用环境变量, 开发环境变量, 生产环境变量

环境变量语法:
**一行一个`key`与`value`**

> `VITE_APP_`开头的环境可以被浏览器捕获到, 不安全

示例:
```
VITE_APP_BASE_URL=http://localhost:4000
key1=value1
keyN=valueN
```

1. 在项目根目录创建文件`.env`
```shell
cd <project>
echo > .env VITE_APP_BASE_URL=http://localhost:4000
```

2. 测试读取, 在任意的`vite`项目下执行
```js
console.log(import.meta.env.VITE_APP_BASE_URL)
```

## 环境变量模式
### 模式

.env                # 所有情况下都会加载
.env.local          # 所有情况下都会加载，但会被 git 忽略
.env.[mode]         # 只在指定模式下加载
.env.[mode].local   # 只在指定模式下加载，但会被 git 忽略

语法: `vite --mode <mode>`
```json
{
	"scripts": {
		"dev:local": "vite --mode <mode>"
	}
}
```

#### 开发环境: `local`
vite会读取根目录下的`.env.local`文件

示例: 配置开发模式`script`
package.json
```json
{
	"scripts": {
		"dev:local": "vite --mode _local"
	}
}
```

#### 生产环境: `release`
生产模式下 vite会读取根目录下的`.env.release`文件

示例: 配置生产模式`script`
package.json
```json
{
	"scripts": {
		"dev:produ": "vite --mode release"
	}
}
```

## 环境变量类型
在定义好环境时, 通过输入`import.meta.env.`时是没有变量提示的, 需要配置类型提示

> 注: 仅在TS项目环境下测试, JS项目未经测试

在`vite-env.d.ts`定义`ImportMetaEnv`接口, 其字段为你的环境变量文件所定义的值
示例: 
```ts
/// <reference types="vite/client" />
interface ImportMetaEnv {
	readonly VITE_APP_BASE_URL: string;
}
```

测试样本:
![[Pasted image 20230227174853.png]]
![[Pasted image 20230227174836.png]]

## 参考
[Vite](https://cn.vitejs.dev/guide/env-and-mode.html)