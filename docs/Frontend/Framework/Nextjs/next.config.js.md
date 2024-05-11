[next](https://nextjs.org/docs/api-reference/next.config.js/runtime-configuration)仅服务器运行时配置放在`serverRuntimeConfig`下。

```js
 publicRuntimeConfig: {
    // Will be available on both server and client
    staticFolder: '/static'
  }
```

客户端和服务器端代码都可以访问的任何内容都应位于 publicRuntimeConfig:

```js
 publicRuntimeConfig: {
    // Will be available on both server and client
    staticFolder: '/static'
  }
```

React 严格模式

```js
// next.config.js
module.exports = {
  reactStrictMode: true,
}
```

配置构建 ID

next.js使用在生成时生成的常量 id 来标识正在提供的应用程序版本。当在每台服务器上运行时，这可能会导致多服务器部署出现问题。为了在构建之间保持一致的构建
ID，您可以提供自己的构建 ID。`next build`

打开并添加函数：`next.config.js``generateBuildId`

```js
module.exports = {
  generateBuildId: async () => {
    // You can, for example, get the latest git commit hash here
    return 'my-build-id'
  },
}
```