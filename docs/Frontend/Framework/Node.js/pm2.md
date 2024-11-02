# pm2

#Lib #PM2 #Node

> Node.js 进程管理

## 安装

> 推荐全局安装

```shell
npm i -g pm2 
yarn global add  pm2
```

## 使用

### 指令

+ 启动

```
pm2 start <file>
```

+ 停止

```shell
pm2 stop <app_name|namespace|id|'all'|json_conf>
```

+ 重启

```shell
pm2 restart <app_name|namespace|id|'all'|json_conf>
```

+ 查看列表

```shell
pm2 ls 
pm2 list
```

+ 查看日志

```
pm2 log
pm2 logs
```