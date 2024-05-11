## 使用
```bash
scp [options] <file> user@host:<path>
```
上传多文件
使用空格隔开
示例:
```bash
sshpass -e scp ./dir.sh ./app ./Dockerfile ./deploy.sh root@192.168.0.158:/temp
```

## 参数

### RSA Key检查信息
-o stricthostkeychecking: RSA Key检查信息
no: 不检查RSA Key检查信息
yes: 默认,检查RSA Key检查信息
示例:
```bash
scp -o stricthostkeychecking=no
```

### 递归复制
#### 包括文件夹本身

格式:
```bash
scp -r <full_path>
```

示例:
```bash
scp -r /home/wwwroot/www/charts/util root@192.168.1.65:/home/wwwroot/limesurvey_back/scp
```

### 排除某个文件/目录
格式
```bash
scp !(<file>/<path>)
```

示例: 发送所有文件(排除file4)
```bash
scp -r !(file4) 192.168.19.142:/sahilfile1
```

#### 不带文件夹

格式:
```bash
scp -r <full_path>/*
```

示例: 发送go项目二进制文件与Dockerfile和deploy.sh
```
scp -o stricthostkeychecking=no -r ./* root@192.168.0.158:/home/nginx/html/web/temp 
```

### 端口
-P 
示例
```bash
scp -P 端口
```

示例: 上传`E:\Downloads\docker-compose-Linux-x86_64`文件到Linux主机`192.168.0.158`的账号为`root`的`home`路径中
```shell
scp E:\Downloads\docker-compose-Linux-x86_64 root@192.168.0.158:\home
```

## 与其他库使用
携带密码
```
sshpass -p 密码 scp -P 端口 文件路径 用户@目标主机:/文件路径
```