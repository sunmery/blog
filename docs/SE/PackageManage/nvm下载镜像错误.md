1.  通过nvm的命令行使用nvm node_mirror命令多次尝试无效
2.  在nvm的安装路径下找到settings.txt打开:
    
    ```makefile
    root: C:\nvm
    arch: 64
    proxy: none
    originalpath:
    originalversion:
    node_mirror:
    npm_mirror:
    ```
3.  分别指定node和npm的mirror

    ```avrasm
    node_mirror: npm.taobao.org/mirrors/node/
    npm_mirror: npm.taobao.org/mirrors/npm/
    ```