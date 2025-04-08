# Git

#Git #命令

## 基本配置

配置用户和邮件

```shell
git config --global user.name "Your Name Comes Here"
git config --global user.email you@yourdomain.example.com
```

彩色输出

```shell
git config --global color.ui true
git config --global core.pager more
```

### 克隆

拉取指定分支

```git
git clone -b 指定分支 `git地址`
```

浅克隆(只克隆最新的提交)
number: 最近的第 n 次提交, 例如1, 表示最新的一次提交
repo: 远程仓库 url

```shell
git cone --depth number repo
```

## 缓存区

```git
git add `filename` 单个文件
git add . 监控工作区的状态树，使用它会把工作时的所有变化提交到暂存区，包括文件内容修改(modified)以及新文件(new)，但不包括被删除的文件
git add -u | --update 仅监听已经被添加的文件,将被修改的文件提交到暂存区.不会提交新文件
git add -A | --all：是上面两个功能的合集（git add --all的缩写）
```

### 多账号和多仓库

1. 在`~/.ssh/`创建config文件

- Windows Powershell

```shell
New-Item -ItemType File config
```

- pwsh

```shell
type nul  config
```

- bash

```
 config
```

2. 生成不同git repo的rsa密钥
   example@xx.com: 邮箱
   path: 生成的文件名, 例如`gitlab_lisa`
   -t : 加密方式
    - ed25519

```shell
ssh-keygen -t rsa -C -b 4096 "example@xx.com" -f path
ssh-keygen -t ed25519 -C // gitlab
```

3. 根据样板输入

- Host: 主机
    - GitHub: github.com
    - Gitlab: gitlab测试不通过,不推荐使用
    - Gitee: gitee.com
- HostName: 主机名, 与`Host`相同
- PreferredAuthentications: 首选身份验证
    - publickey: 使用公钥,不用修改
      IdentityFile: repo文件路径 把repo_id_rsa修改成对应文件

```config
Host gitrepo
    HostName gitrepo
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/repo_id_rsa
```

示例:

```config
# github rococoya
Host github.com
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/github.rococoya

# github Lookeke
Host github.com
    HostName github.com
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/github.lookeke

# GitLab
Host gitlab.com
    HostName gitlab.com
    IdentityFile ~/.ssh/gitlab_lisa

# Gitee
Host gitee.com
    HostName gitee.com
    IdentityFile ~/.ssh/gitee_id_rsa
```

### 一个项目提交到多个仓库

[参考](https://segmentfault.com/a/1190000011294144)
语法：

```git
git remote set-url --add branch git_uri git_uri2
```

branch： 已经添加的分支
git_uri： 仓库URI
实例：

```git
git remote set-url --add github https://git.oschina.net/zxbetter/test.git
```

### Gitlab与Github共享一个git仓库

在你项目根目录创建`.gitmodules`文件
格式:

```
[submodule "Repo"]
	path = path
	url = git_https_path

[submodule "Repo"]
	path = path
	url = git_https_path
```

解析:
`Repo`: 共享git仓库的名称, 例如`web`
Gitlab: 如果该共享git仓库在同一个服务器下,则使用相对路径`user/repo`, 如共享git仓库在
`http://192.168.0.152:7000/root/sub`路径下, 主git仓库在`http://192.168.0.152:7000/root/edu-system`下,相对路径为`../../`
GitHub: 直接使用HTTPS的git链接

示例:

```gitmodules
[submodule "web"]
  url = https://github.com/lookeke/edu-management-system-client.git

[submodule "web"]
  path = web
  url = ../../root/edu-system-client.git
```

一个项目包含多个子仓库

```git
git submodule add URI
```

## 修改和提交

git status 查看状态
git diff 查看变更内容
git mv `old` `new` 文件改名
git rm `file`      删除文件
git rm --cached `file`  停止跟踪文件但不删除
git commit --amend 重新填写commit message内容
git restore --staged 撤销已经commit的文件
git reset --soft HEAD~commit,1表示最后一次 软撤销,不撤销添加的文件
git reset --hard HEAD~1 恢复到了上一次的commit状态。
git push --follow-tags 本地分支 远程分支 将本次提交的内容的`注释`创建为`tag`分支推送至远程

## 查看提交历史

git log 查看提交历史
git log -p `file`   查看指定文件的提交历史
git blame `file`    以列表方式查看指定文件的提交历史

## 撤销

git remote remove `branch`        撤销链接远程仓库
git reset `file` 撤销已经添加的`file`文件
git reset 撤销已经添加的全部文件
git revert `commit`   撤消指定的提交

## 分支与标签

git branch -m `原分支名` `新分支名`
git push --force `本地分支` `远程分支` 本地分支覆盖远程分支
git pull --force `本地分支` `远程分支` 远程分支覆盖本地分支
git branch 显示所有本地分支
git checkout `branch/tag`          切换到指定分支或标签
git branch `new-branch`            创建新分支
git branch -d `branch`            删除本地分支
git tag 列出所有本地标签
git tag `tagname`                 基于最新提交创建标签
git tag -d `tagname`              删除标签

**分支操作示例**
重命名一个分支，将本地分支与远程分支关联，并确保远程仓库的 HEAD 能够跟踪所有分支的最新提交

1. 将本地分支名为`main`的分支更名为`lixia`(与远程分支名对应)
2. 获取远程更新
3. 将本地分支与远程分支建立关联, 该分支就可以跟踪远程分支的更改
4. 将远程仓库 "origin" 的 HEAD 设置为 "a"，这表示远程仓库的 HEAD 将跟踪所有分支的最新提交

- 远程有分支的情况下:

```shell
git checkout -b 远程分支名 本地分支名
git branch -u 本地分支名 远程分支名
git remote set-head 远程主分支名 -a
```

示例:

```shell
git init
git remote add main git@github.com:lookeke/tiktok.git
git fetch main
git checkout -b lixia main
git branch -u main lixia
git remote set-head main -a
```

遇到**error: The following untracked working tree files would be overwritten by checkout:**问题:

这个错误表示你正在尝试检出一个新的分支，但是这个操作会覆盖工作目录中一些未跟踪的文件。Git 为了保护这些文件不被覆盖，因此终止了操作。

**3 种解决方案**:

1. **暂存并提交当前的更改**： 如果这些文件是你新增或修改的，你可以选择提交它们。

```shell
git add . 
git commit -m "Add new files and changes"
```

然后再次尝试检出新的分支。

2. **使用stash保存工作进度**： 如果你还不想提交这些更改，但希望临时存储它们以便稍后恢复，可以使用`git stash`。

```shell
git stash
```

它将会保存你的工作进度。之后，之后可以使用`git stash apply`来恢复这些更改。

3. **删除或移动这些文件**： 如果你确定不需要这些文件，可以删除或移动它们到其他地方。

谨慎使用这个命令，它会删除所有未跟踪的文件。

```shell
git clean -fd
```

完成上述操作之后，你可以再次尝试创建并切换到`main/远程仓库`分支。
记住，创建新的分支前，最好确保工作目录是干净的，这样可以避免此类冲突。

- 示例 2: 远程没有分支, 需要本地创建分支情况下:

git fetch main 的`main`为可选, 如果`git fetch main` 无反应, 尝试执行`git fetch`

```shell
git fetch [main]
git branch -u main lixia
git remote set-head main -a
```

## 合并与

git merge `branch`     合并指定分支到当前分支

## 远程操作

git ls-remote 查看远程仓库的分支
git remote -v 查看远程版本库信息
git remote show `remote`   查看指定远程版本库信息
git remote add `remote` `url`  添加远程版本库
git fetch `remote`      从远程库获取代码
git pull`remote``branch`# 下载代码及快速合并
git push `remote``branch`    上传代码及快速合并
git push `remote``branch/tag-name` 删除远程分支或标签
git push--tags 上传所有标签
git log 提交信息

提交所有`tag`到远程

```shell
git push -u 分支 --tags
```

高级
工程化操作
[文章](https://www.cnblogs.com/sexintercourse/p/15491447.html)

```shell
git config --global core.autocrlf false
```
