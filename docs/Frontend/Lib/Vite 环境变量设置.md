## 设置环境变量

Vite的环境变量分为4种

1. release 发行
2. beta 预发布
3. test 测试
4. local 本地

## 配置

1. 在`package.json`配置开发环境,优先级比`vite.config.ts`文件高
   使用: `--mode <环境>` 来定义当前的环境,例如使用`dev:local`代表本地的开发环境
   关键代码:
    ```json
    {
    "scripts": {
        "dev:local": "vite --port 3000 --mode _local",
        "dev:produ": "vite --port 3000 --mode release"
      }
    }
    ```

例:
`VITE_`开头
`.env.local` 本地开发文件

```env
VITE_URI=https://localhost:4000
```

`.env.production` 生产环境文件

```env
VITE_URI=https://lookeke.com:4000
```

## 使用:

使用关键字`import.meta.env.<env变量名>`

`import.meta.env`有几种模式:

1. import.meta.env.MODE: 应用运行的模式
2. import.meta.env.BASE_URL 部署应用时基本URI. 由`vite.config.ts`的`base`配置项决定
3. import.meta.env.PROD 应用是否运行在生产环境中
4. import.meta.env.SSR 应用是否运行在服务器渲染环境

例子:

```ts
console.log(import.meta.env.VITE_URI)
```