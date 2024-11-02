shopt 命令可以设置 shell 的可选参数.

shopt [-psu] [optname …]

-s 开启某个选项.

-u 关闭某个选项.

-p 列出所有选项的当前生效命令. （不带-p表示列出所有选项的当前状态）

extglob选项
如果开启 extglob 选项, shell 将启用扩展模式匹配

查看 extglob 选项是否开启(默认是off)

$ shopt extglob

extglob off

开启 extglob 选项

$ shopt -s extglob

此时查看 extglob 选项是否开启

$ shopt extglob

extglob on

关闭 extglob 选项

$ shopt -u extglob

开启之后，以下5个模式匹配操作符将被识别：

?(pattern-list)

#所给模式匹配0次或1次*(pattern-list)

#所给模式匹配0次以上包括0次+(pattern-list)

#所给模式匹配1次以上包括1次@(pattern-list)

#所给模式仅仅匹配1次!(pattern-list)

#不匹配括号内的所给模式
