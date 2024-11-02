## 图标

- [simpleicons](https://simpleicons.org/)

1. 文字图标
2. 图片图标
    1. 从[shields](https://shields.io/)图标网站生成你的图标
       ![[Pasted image 20221026132649.png]]
       label: 左边的文本
       message: 右边文本
       color: 右边文本背景颜色
       图片图标需要填写`message`文本即可，点击`Make badge`生成：下图是`message`为`as`,`color`选择`yellow`的结果
       ![[Pasted image 20221026132937.png]]
2. 阅读[DenverCoder1](https://github.com/DenverCoder1/custom-icon-badges/blob/main/README.md)的`GitHub`博客, 将刚刚的生成图片地址复制下来,
   将`img.shields.io`替换成`custom-icon-badges.demolab.com`, 填写图标`MarkDown`地址， 语法:
   `<message>` ： 图像的描述
   `<URI>`： 图标地址
   `<ICON-NAME>`: [simpleicons](https://simpleicons.org/)的图标名

> 	如果有空格，在插入的时候需要去掉空格,例如`Apache ECharts` 替换成`ApacheECharts`

	![[Pasted image 20221026135020.png]]

```
![<message>](<URI>?logo=<ICON-NAME>)
```

将`<URI>`替换成你刚刚生成的图标地址，例如`https://img.shields.io/badge/-as-yellow`

完整示例：

```
![echarts](https://custom-icon-badges.demolab.com/badge/-Apache%20ECharts-AA344D.svg?logo=## ApacheECharts&logoColor=white)
```

4. 版本图标