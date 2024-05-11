#工程化

## Git 的 `core.autocrlf` 配置

- `true`： 提交时转换为 `LF`，检出时转换为 `CRLF`

```shell
 git config --global core.autocrlf true
```

- `input`： 提交时转换为 LF，检出时不转换

```shell
git config --global core.autocrlf input
```

- `false`： 提交检出均不转换

```shell
git config --global core.autocrlf false
```

git commit 模板

> 提交时显示 commit 模板

1. 创建`.gitmessage`文件, 填写内容

```gitmessage
# head: <type>(<scope>): <subject>
# - type: feat, fix, docs, style, refactor, test, chore
# - scope: can be empty (eg. if the change is a global or difficult to assign to a single component)
# - subject: start with verb (such as 'change'), 50-character line
#
# body: 72-character wrapped. This should answer: # * Why was this change necessary? # * How does it address the problem?
# * Are there any side effects?
#
# footer:
# - Include a link to the ticket, if any.
# - BREAKING CHANGE
#
```

2. 创建`.gitconfig`文件, 填写映射

```gitconfig
[commit]
	template = ./.gitmessage
```

参考

1. [掘金](https://juejin.cn/post/6844904085779382280)
2. [GitGuide](https://zjdoc-gitguide.readthedocs.io/zh_CN/latest/message/gitmessage.html)
