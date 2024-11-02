## Module
模块, IOC控制反转, 将所有的模块集中到AppModule中进行统一管理, 减小`new Class`的性能开销

## Constrller
控制器, 管理`Request`, `Response`请求

## Service
业务

## 安装
### CLI

推荐全局安装:
```shell
npm i -g @nestjs/cli
pnpm add -g @nestjs/cli
yarn add -g @nestjs/cli
```

## CLI指令行

### [CLI](https://docs.nestjs.com/cli/overview)
- nest new `<project>` 创建nest项目, `new`可替换为缩写`n`
- nest g resource `<file-name>` 创建`DTO`,`Test`,`Module`,`Service`,`input`,`entity`文件
- nest g mo `<file-anme>` 创建module.ts
- nest g mi `<file-name>` 创建中间件
- nest g co `<file-anme>` 创建constroller.ts
- nest g s `<file-anme>` 创建service.ts
- nest g d `<file-anme>` 创建decorator.ts
- nest start 编译并运行应用
- nest info 查看nest信息 `info`可替换为`i`
- 
### 选项
`--no-spec` 不生成测试文件

## 问题
Q: `nest Failed to execute command: node`
A:删除项目`src`目录下所有`.js`文件