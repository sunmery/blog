#工程化

## standard-version

自动推送版本
封装`npm version`: `npm version [<newversion> | major | minor | patch | premajor | preminor | prepatch | prerelease | from-git]`

### 下载

```shell
pnpm i -D standard-version
```

### 配置

> 不配置此文件同样也可以运行, 但只有`feat`提交才会在`changelog`文件显示

**.versionrc.js**: commit 详细说明

```js
module.exports = {
  types: [
    { type: 'feat', section: '✨ Features | 新功能' },
    { type: 'fix', section: '🐛 Bug Fixes | Bug 修复' },
    { type: 'docs', section: '✏️ Documentation | 文档' },
    { type: 'style', section: '💄 Styles | 风格' },
    { type: 'init', section: '🎉 Init | 初始化' },
    { type: 'refactor', section: '♻️ Code Refactoring | 代码重构' },
    { type: 'perf', section: '⚡ Performance Improvements | 性能优化' },
    { type: 'test', section: '✅ Tests | 测试' },
    { type: 'revert', section: '⏪ Revert | 回退', hidden: true },
    { type: 'build', section: '📦‍ Build System | 打包构建' },
    { type: 'chore', section: '🚀 Chore | 构建/工程依赖/工具' },
    { type: 'ci', section: '👷 Continuous Integration | CI 配置' },
  ],
}
```

#### 语法:

- `standard-version` 按照默认的规则提交, `changelog.md`只显示 feat 内容
- `standard-version -- --first-release` 第一次提交
- `standard-version -- --no-verify` 推送时不需要调用 githooks, 在`husky`这种 commit 时就检查的库就需要跳过,以免被再次检查,默认升级`patch`
- `standard-version --release-as major` 大版本更新,例如`v1.0.0` -> `v2.0.0`
- `standard-version --release-as minor` 大版本更新,例如`v1.1.0` -> `v1.2.0`
- `standard-version --release-as patch` 大版本更新,例如`v1.0.0` -> `v2.0.0`
- `standard-version --release-as <version>` 自定义版本更新,例如`v1.0.0` -> `v1.3.1`

#### 指令:

```json
"scripts": {
	"release": "standard-version -- --no-verify",
	"release:major": "standard-version --release-as major -- --no-verify",
	"release:minor": "standard-version --release-as minor -- --no-verify"
},
```

## ESLint

语法:
- `eslint <file>` 检测文件是否符合规范
- `eslint <file> --fix` 尝试对文件进行修复
- `--ext ts,tsx`：表示只对扩展名为 `.ts` 和 `.tsx` 的文件进行分析。
- `--report-unused-disable-directives`：表示报告未使用的 ESLint 禁用指令（注释中的 `eslint-disable`）。
- `--max-warnings 0`：表示如果发现任何警告，不会停止分析，但退出状态码将为非零，以表示有问题。
```json
"scripts": {
	 "lint": "eslint src --ext ts,tsx --report-unused-disable-directives --max-warnings 0",
    "lint:fix": "eslint --cache src --ext ts,tsx --fix",
}
```

```json
{
  "name": "feishu_vpn",
  "private": true,
  "version": "0.0.2",
  "type": "module",
  "description": "feishu-vpn single page web application",
  "author": {
    "name": "Rococo",
    "email": "xiconz@qq.com",
    "url": "https://github.com/lookeke"
  },
  "engines": {
    "node": ">=14",
    "npm": ">=8",
    "yarn": ">=1",
    "pnpm": ">=6"
  },
  "keywords": ["vpn"],
  "main": "./src/main.tsx",
  "homepage": "https://github.com/lookeke/feishu_vpn",
  "repository": {
    "type": "git",
    "url": "https://github.com/lookeke/feishu_vpn.git"
  },
  "bugs": {
    "url": "https://github.com/lookeke/feishu_vpn/issues"
  },
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "tauri": "tauri"
  },
  "dependencies": {
    "@babel/core": "^7.20.2",
    "@emotion/react": "^11.10.5",
    "@emotion/styled": "^11.10.5",
    "@mui/icons-material": "^5.10.14",
    "@mui/material": "^5.10.14",
    "@tauri-apps/api": "^1.1.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@tauri-apps/cli": "^1.1.0",
    "@types/node": "^18.7.10",
    "@types/react": "^18.0.15",
    "@types/react-dom": "^18.0.6",
    "@vitejs/plugin-react": "^2.0.0",
    "eslint": "^8.27.0",
    "prettier": "^2.7.1",
    "typescript": "^4.6.4",
    "vite": "^3.0.2"
  }
}
```

## 参考

1. [NPM DOCS](https://docs.npmjs.com/cli/v8/commands/npm-version)
2. [掘金](https://juejin.cn/post/7020289124993073189)
