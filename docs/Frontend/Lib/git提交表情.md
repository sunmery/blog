## 作用

代码提交到github上时显示emoji表情

## 原理

github网站解析对应代码展示

## 使用

1. 安装，使用全局安装减少每次下载的麻烦
    ```shell
    pnpm i -g git
    ```

2. 提交时加入表情

语法：

```git
git commit -m <intention> [scope?][:?] <message>
```

- `intention`: 表情代码， 例如`:zap:`
- `scope`: 一个可选字符串，用于添加更改范围的上下文信息。
- `message:`本次提交的注释
  示例：

```git
git commit -m ":memo: 更新文档"
```

## 参考

1. [github](https://github.com/carloscuesta/gitmoji)
2. [官网](https://gitmoji.dev/)