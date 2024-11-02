# Lunix的Nginx部署

#Linux #Nginx
[Bilibili视频](https://www.bilibili.com/video/BV1db4y1n7Rr?spm_id_from=333.999.0.0)
[腾讯云社区文章](https://cloud.tencent.com/developer/article/1924770)
https://blog.csdn.net/WayneLee0809/article/details/84664342
https://cloud.tencent.com/document/product/400/35244
[搭建1](https://blog.csdn.net/Cs_Mervyn/article/details/120075477#:~:text=centos%207%20%E5%AE%89%E8%A3%85nginx%20%E4%B8%80%E3%80%81%E4%B8%8B%E8%BD%BD%20%E5%AE%89%E8%A3%85%20%E5%8C%85%20cd%20%2Fusr%2Flocal%2Fsoftware,%E4%BA%8C%E3%80%81%E8%A7%A3%E5%8E%8B%20%E5%AE%89%E8%A3%85%20tar%20-zxvf%20nginx%20centos%207%20%E5%AE%89%E8%A3%85nginx)
[搭建2](https://blog.csdn.net/WayneLee0809/article/details/84664342)
[nginx指令](https://blog.csdn.net/erdfty/article/details/89919513)

## 安装相关依赖

1. gcc
2. zlib
3. zlib-devel
4. pcre-devel
5. openssl
6. openssl-devel

```Shell
yum install -y gcc zlib zlib-devel pcre-devel openssl openssl-devel
```

## 解压

解压

```Shell
tar -xf <nginx_dir>
```

## 配置

进入到`nginx`目录

```Shell
cd <nginx_dir>
```

安装配置文件

`--prefix=<dir>` 输出目录地址

```Shell
./conifgure --prefix=usr/local/nginx
```

把所有东西安装到指定目录

```shell
make install
```

校验安装

```Shell
cd /usr/local/nginx
```

启动`Nginx`服务

```Shell
cd sbin
./nginx
```

检查首页是否有变化,键入服务器URL,会显示`Nginx`默认的`Index.html`

## 修改配置

进入到`Nginx`目录的`conf`目录下

```Shell
cd ~/usr/local/nginx/conf
```

编辑配置文件

```Shell
vi nginx.conf
```

修改conf下的`Server`下的`location`下的`root`与`index`

1. 吧`<root_dir>` 替换成`网站跟目录`

   ```bash
   nginx/conf
   
   root <root_dir>
   ```

2. 吧`<index>` 修改成`网站的index.html文件`

   ```bash
   nginx/conf/nginx.conf
   
   index <index>
   ``` 

3. 授权用户权限
    1. 删除`#`符号
    2. `root` 改成你想要授权的用户,root也可以

   ```bash
   nginx/conf/nginx.conf
   
   user root;
   ```

读取修改后的配置文件,让其生效

```bash
nginx/sbin

./nginx -s reload
```

刷新`网站首页`,查看是否导航到`网站的内容`

## Vim命令

- `i` 进入编辑模式
  `ESC` 菜单
  `:wq` 退出编辑模式
  `:quit` 退出

问题:
Q: nginx: [error] open() ＂/usr/local/nginx/logs/nginx.pid＂ failed错误

A: 将`sbin`下的nginx复制到`nginx.conf`文件的目录下
示例:
/usr/local/server/nginx/sbin 目录

```shell
/usr/local/server/nginx/sbin/nginx -c /usr/local/server/nginx/conf/nginx.conf

```