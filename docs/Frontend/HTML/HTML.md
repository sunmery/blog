## 基本布局

#HTML

## head

> 元数据\<meta\>常用属性和属性值
> link标签

```html
<meta charset="utf-8" />

<!-- 作者 -->
<meta name="author" content="LisaSummer<xiconz@qq.com>" />

<!-- 页面内容的描述  -->
<meta name="description" content="#[[$Title$]]#" />

<!-- 页面关键字 -->
<meta name="keywords" content="" />

 <!-- Internet Explorer浏览器浏览时使用最高级模式渲染,使用Google Chrome Frame内核渲染 2014/2/25不支持 -->
<meta name="http-equiv" content="IE=edge,chrome=1" />

<!-- 移动端适配 width 属性指的是视口宽度，现在视口的宽度被设置为了设备的屏幕宽度，即文档视口宽度大小与设备宽度大小 100% 对应（转换为 CSS 像素值相同） -->
<meta name="viewport" content="width=device-width, initial-scale=1.0" />

<!-- https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CSP -->
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self'" />
<meta http-equiv="X-Content-Security-Policy" content="default-src 'self'; script-src 'self'" />

<link rel="icon" href="favicon.ico" />
```

header

- nav

main

- article
- aside

footer

## 语义化的好处

- 代码可读性

- 可维护性
- 搜索引擎优化
- 提升无障碍性

## 语义化

- 了解每个标签和属性的含义
- 思考什么标签最适合描述这个内容
- 不使用可视化工具生成代码
