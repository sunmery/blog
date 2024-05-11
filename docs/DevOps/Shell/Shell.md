# Shell

#Linux #Shell

查询RPM安装的包
```
rpm -qa | grep ssh
```

逻辑卷应该已经使用了全部的空间:
1. **查看逻辑卷信息**：首先，使用以下命令查看逻辑卷的信息，包括空间大小和使用情况：
```
sudo lvdisplay
```
2. **扩展逻辑卷**：如果逻辑卷没有使用全部空间，您可以使用以下命令扩展逻辑卷的空间：
```
sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
```
3. **调整文件系统**：扩展逻辑卷后，您需要调整文件系统以便使用新的空间。使用以下命令调整文件系统：
```
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
```
执行完上述步骤后，您的逻辑卷应该已经使用了全部的空间

- watch
	- -n 5 date 每5秒更新
	- -d free 高亮显示差异
	- -g free 单次变化后退出
	- -t free 隐藏命令标题
	- -d 'ls -l | fgrep newuser' 监视文件


- journalctl -xeu your-service-name -n 100 查询最后100条的日志
- journalctl -u your-service-name -f 查询

- ll ls -l的别名, 列出文件权限 硬链接数 文件所有者 所属组 文件大小和修改日志
- du / 列出/下所有文件
	- -sh 查看当前目录的占用的存储
- df -h / 查看存储

umask : 三个参数
- 022 所有者都可以读, 创建者可以写
- 077来说，它的意思是将默认权限中的所有权限都去掉，只保留拥有者的读、写和执行权限。也就是说，新创建的文件只有拥有者有读写权限，其他用户没有任何权限

chmod: 
1. 权限: 1=执行权限，2=写入权限，4=读取权限
2. 角色: 代表用户角色、组角色和其他用户角色
chmod -R 600: root 用户才能读取文件, -R表示该目录下文件所有权限都是600
chmod 644: 默认权限, 文件所有者读写, 其他用户读取
chmod 755: 常见权限, 文件所有者读写执行, 其他用户读取执行
### 解压
-x 解压
-z 有gzip属性的
-v 解压信息
-f 递归解压
-C 解压到指定目录
```bash
tar -xzvf <dir>.tar.gz -C <dir>
```

### 打包
-c 打包
--exclude=`<dir>` 排除的目录
语法
```bash
tar -czvf <file>.tar.gz --exclude=<dir>
```

示例: 打包本目录下的所有文件为`dist.tar.gz`,但排除`node_modules`目录
```bash
tar -czvf dist.tar.gz --exclude=node_modules
```

创建文件, 如果创建带有目录的文件, 则目录必须存在
```bash
> file
echo file
```

切换账号

```shell
su - <user>   切换到新用户的同时,也却换到新用户的环境变量
su <user>  只切换到root,环境变量不切换
```

例子:

```shell
su -    切换到root,且环境切换到root的环境变量
su      只切换到root,环境变量不切换
```

运行管理员特权 `Super User Do`

```Shell
sudo
```

更改密码

```
passwd 当前密码 
```

### 压缩

```bash

```


### 解压

#### tar文件
```bash
tar -zxvf <package>
xz -d <package>
tar -xf <package>
```

#### zip文件

unzip

> 如果没有unzip, 则需要下载: `yum install -y unzip` (CeontOS7)

-d 目录名: 将压缩文件解压到指定目录下。
-n:  解压时并不覆盖已经存在的文件。
-o: 解压时覆盖已经存在的文件，并且无需用户确认。
-v:  查看压缩文件的详细信息，包括压缩文件中包含的文件大小、文件名以及压缩比等，但并不做解压操作。
-t:  测试压缩文件有无损坏，但并不解压。
-x 文件列表: 解压文件，但不包含文件列表中指定的文件。
```
unzip <filename>.zip
```

查找文件

语法:
`find <path> -name <filename>`
`locate <filename>`

```
find / -name <filename> // 查找根目录下的文件

locate <filename>
```

查找文件夹

```Shell
whereis <dir>
```

运行管理员特权

`sudo`

```
Super User Do
```

查看当前服务器占用的端口

```
ss -tunlp
```

更新`yum`软件包索引

```Shell
yum makecache fast
```

更改密码

passwd 当前密码

`pwd` 以绝对路径方式显示当前的工作路径

关机（退出Linux） shutdown -h 10:00 十点后关机 shutdown -h +4 4分钟后关机 shutdown -h now 现在关机

查看已安装的服务 rpm -qa rpm -qi 软件名 rpm -qc 软件的配置文件 rpm -qd 软件名 #查看一个已经安装软件的文档安装位置 rpm -qR 软件名 #查看一下已安装软件所依赖的软件包及文件