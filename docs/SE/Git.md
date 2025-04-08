#工程化

## 推荐配置

全局配置：

- 默认的主分支名称为main, 统一

```bash
git config --global init.defaultBranch main 
```

- 提交时转换为 LF，检出时不转换

```bash
git config --global core.autocrlf input
```

- 避免不必要的合并提交
  当你执行 `git pull` 时，Git 默认会执行 `fetch` 和 `merge` 操作，这可能会导致本地分支的合并冲突或其他变化

```bash
git config pull.rebase true
```

### Git 的 `core.autocrlf` 配置

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

验证设置

```bash
git config pull.rebase
```

## 最佳实践

不要直接把代码推送到主分支, 先创建一个新的分支, 在经过review之后, 确认无误之后在合并代码到主分支

```bash
git checkout -b beta

git add .
git commit -m "feat: "
git push main beta
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
