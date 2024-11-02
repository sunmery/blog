查询node_module使用情况的库

1. 安装

```shelll
pnpm i -g shell
```

- 分析依赖

```shell
qnm <module>
```

- 分析空间占用

//在需要分析的node_module的父级目录上

```shell
qnm doctor
```

- 查看重复依赖占用的空间

```shell
qnm doctor --sort duplicates
```

- 分析所有模块

```shell
qnm list
```

- 模糊匹配

```shell
qnm match <module>
```