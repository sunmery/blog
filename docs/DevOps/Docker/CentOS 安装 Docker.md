## 前置条件

1. 能够连接网络

2. 如果之前安装,那么需要卸载
    ```shell
    yum -y remove docker docker-common docker-selinux docker-engine
    ```

3. (可选) 更新软件
    ```shell
    yum update -y
    ```

4. 安装`Yum`源,安装 yum-utils , 使用 `yum-config-manager` 工具设置Yum源, 后面两个是 `devicemappe`r驱动依赖
    ```shell
    yum install -y yum-utils device-mapper-persistent-data lvm2
    ```

5. 添加docker的yum源

   > 如果国内访问失败,那么就需要安装国内的Docker源
    ```shell
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    ```

6. (可选)使用`阿里云`源访问
    ```shell
    yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    ```

## 安装

1. 选择一个`Docker`版本安装
   查看所有仓库中docker版本，并选择特定版本安装：(此处我们查看社区版 docker-ce)
    ```shell
    yum list docker-ce --showduplicates | sort -r
    ```

2. 选择一个`Docker`版本安装

语法：

`yum install -y docker-ce` (这样写默认安装最新版本)

`yum install -y docker-ce-<VERSION_STRING>` (指定安装版本)

```shell
yum install docker-ce-18.03.1.ce
```

## 验证

验证是否安装成功

```shell
docker run hello-world
```

## 指令

- 一些可能会用到的指令

```shell
systemctl start docker 启动Docker服务
systemctl restart docker 重启Docker服务
systemctl enable docker 开机启动
docker version  查看docker版本号
```

- 指令说明

```shell
yum `yum`是`RedHat`公司的包管理工具
yum update -y `yum`的系统更新与软件更新, `-y`参数为不询问直接更新
yum remove <package> 删除依赖
yum install <package> 安装依赖
`yum-config-manager --add-repo <url>` 配置yum的安装地址,以后通过yum安装依赖时通过此URL来下载
`docker run <Image>` 运行镜像
systemctl 特权, 就像是Windows中的管理员权限
```

## 参考

[阿里云](https://developer.aliyun.com/article/765545)