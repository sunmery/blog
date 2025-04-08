## 参数

-p 密码 密码在命令行中给出。
-f 文件名 密码是文件名的第一行。
-d number number是sshpass从运行程序继承的文件描述符。从打开的文件描述符中读取密码。

-e 密码来自环境变量"SSHPASS"

```
SSHPASS='4u2tryhack'
sshpass -e ssh username@rumenz.com
```
