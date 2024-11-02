# Vue

#Vue #Script #Lib

# 生命周期

1. new Vue()
2. 实例创建
3. 创建前
4. 实例化
5. 创建后
6. 是否有el
    1. 否: 则使用vnode生成一个代替el
    2. 是: 将el内容进行渲染
7. 是否有templatye选项
    1. 否: 将内容编译成template
    2. 是: 将template进行渲染
8. 挂载前钩子函数
9. 将el进行渲染
10. 挂载后
11. 遇到虚拟DOM更新
    1. 否: 更新前
    2. 是: 更新后
12. 销毁前
12. 销毁
13. 销毁后

Vue2获取DOM

```HTML
<div ref="dom"></div>
```

```js
mounted(){
	console.log(this.$refs.dom)
}
```

Vue3获取DOM

```HTML
<div ref="dom"></div>
```

```js
const dom = ref(null)

onmounted(){
	console.log(this.$refs.dom)
}
```

or

```js
// 等所有元素完成加载再进入nextTick钩子函数
nextTick(()=>{
	console.log(dom.value)
})
```