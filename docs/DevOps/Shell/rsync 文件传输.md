## 参数
- -e, --rsh=COMMAND 指定使用rsh、ssh方式进行数据同步
- --exclude=PATTERN 指定排除不需要传输的文件模式
例子: 上传并排除目录到服务
```shell
rsync -avz --exclude={client/node_modules/,client/dist-electron/,client/dist-production} -e "ssh -i /Users/art/alicloud.pem" . root@47.120.5:/home/tiktok/web
```
- --include=PATTERN 指定不排除而需要传输的文件模式
- --exclude-from=FILE 排除FILE中指定模式的文件
- --include-from=FILE 不排除FILE指定模式匹配的文件
- --config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件
- -r 递归复制
- -stats 给出某些文件的传输状态
- --progress 在传输时现实传输过程
- -v, --verbose 详细模式输出
- -q, --quiet 精简输出模式
- -R, --relative 使用相对路径信息
- -b, --backup 创建备份，也就是对于目的已经存在有同样的文件名时，将老的文件重新命名为~filename。可以使用--suffix选项来指定不同的备份文件前缀。
- -suffix=SUFFIX 定义备份文件前缀
- -u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)
- -C, --cvs-exclude 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件
- --delete-after 传输结束以后再删除
- -P,--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输