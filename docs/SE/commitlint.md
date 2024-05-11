## 下载
```shell
pnpm add -D lint-staged husky commitlint @commitlint/config-conventional
```

## 配置
1. 先创建`.git`仓库
```git
git init
```

2. `package.json`添加`prepare`指令
```json
{ 
	"scripts": { 
		"prepare": "husky install"
	 }
}
```

> 如果 git 目录不在`.husky`目录同级, 则根据实际情况修改:

```json
{
  "scripts": {
    "prepare": "cd .. && husky install front/.husky"
  }
}
```

3. prepare脚本会在执行npm install之后自动执行。执行npm install安装完项目依赖后会执行 husky install命令。

指令
```shell
pnpm i
```

(可选)命令行
```shell
npm set-script prepare "husky install" && npm run prepare
```

4. 添加`git hooks`, 创建一条 `pre-commit hook`

```shell
npx husky add .husky/pre-commit "pnpm lint"
```

执行该命令后，会看到.husky/目录下新增了一个名为`pre-commit`的`shell`脚本。之后执行`git commit`命令时会先触发`pre-commit`这个脚本。
脚本内容:
```
#!/bin/sh 
. "$(dirname "$0")/_/husky.sh" 
pnpm lint
```

5. 修改`pre-commit`脚本, 改成项目所需的指令, 例如`ESLint`,`Stylelint`,`commitlint`检查
```
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

tsc --noEmit && pnpm stylelint:fix && pnpm dlx lint-staged
```

6. 添加`commitlint`规范

旧版: (windows 可用)
```shell
npx husky add .husky/commit-msg 'npx --no-install commitlint --edit "$1"'
```

新版: (mac 可用)
```shell
npx husky add .husky/commit-msg 'npx --no-install --commitlint --edit "$1"'
```

7. 配置`.commitlintrc`
`.commitlintrc.cjs` or `.commitlintrc.js` or `.commitlintrc.config.js`
```js
module.exports = {
	'extends': ['@commitlint/config-conventional'],
	'type-enum': [
		2,
		'always',
		['feat', 'fix', 'perf', 'style', 'docs', 'test', 'refactor', 'build', 'ci', 'chore', 'revert', 'wip', 'workflow', 'types','release'],
	],
}
```

8. 测试`commitlint`:
```git
git commit -m "test: 测试commitlint"
```

## 参考
1. [掘金](https://juejin.cn/post/6988116616923840549)