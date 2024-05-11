ice2.x默认不支持pnpm,需要在下载`node_modules`之前添加配置

1. 新建`.npmrc`
2. `.npmrc`添加内容

```txt
shamefully-hoist=true
```