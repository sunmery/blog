### [安装](https://stylelint.io/user-guide/get-started)
- pnpm
```shell
pnpm create stylelint
```

- npm
```shell
npm init stylelint
```
### [配置](https://stylelint.io/user-guide/configure/)

在`package.json`的script添加:
```
pnpm pkg set scripts.stylelint="stylelint src/**/**.{css,scss,sass}"
pnpm pkg set scripts.stylelint:fix="stylelint src/**/**.{css,scss,sass} --fix"
```
运行测试:
```
pnpm stylelint:fix
pnpm stylelint
```

如果样式文件有错误的地方, 那么会报错:
![[img/Pasted image 20240318235553.png]]

如何样式文件正常, 那么不会报错:
![[img/Pasted image 20240318235616.png]]
#### ESModule
如果使用Node.js的默认模块系统配置(package.json), 如果使用`"type": "module"`, 那么文件名必须是 `stylelint.config.mjs` 或 `.stylelintrc.mjs`
本文选择ESModule, 文件为`.stylelintrc.mjs`

`package.json`:
```json
{
	"type": "module"
}
```

`.stylelintrc.mjs`, 可直接使用本人的`rules`规则(在文章后面)或者进行个性化的定制, 参考官网[rules](https://stylelint.io/user-guide/rules/):

> `@type` JSDoc 注解使 Typescript 能够自动完成和类型检查。

```js
// Rules: https://stylelint.io/user-guide/rules

/** @type {import('stylelint').Config} */
export default {
	'extends': [
		'stylelint-config-standard',
		'stylelint-config-standard-scss',
		'stylelint-config-recess-order',
	],
	'rules': {},
}
```
#### CommonJS

`package.json`:
```json
{
	"type": "commonjs"
}
```

CommonJS 示例：
```js
module.exports = {  
  'extends': [
    'stylelint-config-standard'
  ],
  'rules': {}
};
```
### 扩展

- SCSS/SASS
如果你在项目使用`SASS`库, 那么还可以安装配套的库
```shell
pnpm i -D stylelint-config-standard-scss
```

- stylelint-config-recess-order
一个 Stylelint 配置，它以 Recess 和 Bootstrap 的方式对 CSS 属性进行排序
```
 pnpm i -D stylelint-config-recess-order
```

然后再stylelint的配置文件:
- `stylelint.config.mjs` 或 `.stylelintrc.mjs` 文件使用 `export default` （ES 模块）
- `stylelint.config.cjs` 或 `.stylelintrc.cjs` 文件使用 `module.exports` （CommonJS） 的文件
上进行添加

`stylelint.config.mjs` 或 `.stylelintrc.mjs` 文件:
```js
export default {
  'extends': [
    'stylelint-config-standard',
    'stylelint-config-standard-scss',
    'stylelint-config-recess-order',
  ],
}
```

`stylelint.config.cjs` 或 `.stylelintrc.cjs` 文件:
```js
module.exports = {  
  'extends': [
    'stylelint-config-standard',
    'stylelint-config-standard-scss',
    'stylelint-config-recess-order',
  ],
}
```