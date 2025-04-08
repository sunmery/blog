[官方文档](https://typicode.github.io/husky/guide.html#custom-directory)

### 作用

Git hooks工具，通过配置一系列钩子，可以在git操作的不同阶段执行相应的命令

[官方文档](https://typicode.github.io/husky/guide.html)

### 安装

如果`.git`目录不是在前端项目里,如:

```
. 
├── .git/ 
├── backend/ # No package.json 
└── frontend/ # Package.json with husky
```

则需要修改`prepare`的内容, 不使用`pnpm exec husky init`, 需要手动在`package.json`修改为:

```
"prepare": "cd .. && husky frontend/.husky"
```

如果手动修改了`scripts`的`prepare`,需要重新执行一次

```
pnpm prepare
```

> 注意, 如果`.git`目录不是在前端项目里, 那么`pre-commit`也要修改进入到对应的目录, 例如:

有这样的目录结构:

```
. 
├── .git/ 
├── backend/ # No package.json 
└── frontend/ # Package.json with husky
```

那么, 对应的`pre-commit`文件内容就应该这样写:

```
cd frontend

pnpm test
```
