错误: md文件找不到链接

1. md 文件放 `docs`
2. [导航栏](https://docusaurus.io/zh-CN/docs/api/docusaurus-config#themeConfig): 添加`docusaurus.config.js`的`themeConfig`的`navbar`的`items`为
```js
 {to: 'docs/css', label: 'CSS', position: 'left'},
 {to: 'docs/css', label: 'CSS', position: 'left'},
```

部署:

文件路径
```js
baseUrl: "./"
```

## 参考
1 [onBrokenLinks](https://docusaurus.io/docs/2.0.1/api/docusaurus-config#onBrokenLinks)
2 [onBrokenMarkdownLinks](https://docusaurus.io/docs/2.0.1/api/docusaurus-config#onBrokenMarkdownLinks)
3 https://docusaurus.io/zh-CN/docs/configuration