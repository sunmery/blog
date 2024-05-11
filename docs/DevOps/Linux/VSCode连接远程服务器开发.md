# VSCode连接远程服务器开发

#教程 #Linux #Node #Script

参考:
[CSDN](https://blog.csdn.net/zhaxun/article/details/120568402)

## VSCode配置

1. 下载微软插件 **Remote-SSH**
2. 点击插件图标
3. 配置SSH

## CentOS配置

1. 下载`wget`方便下载url

    ```bash
    yum install wget -y
    ```

2. 下载[Node](https://nodejs.org/en/download/) Linux包

    ```bash
    wget https://nodejs.org/dist/v16.14.2/node-v16.14.2-linux-x64.tar.xz
    ```

3.解压`Node` 安装包, 把`<Node_Package>` 替换成`Node`包

    ```bash
    xz -d <Node_Package>
    tar -xf <Node-Package>
    ```