## Docker 安装Jenkins

防火墙

```
firewall-cmd --zone=public --add-port=8099/tcp --permanent
systemctl restart firewalld
firewall-cmd --zone=public --list-ports
```

安装`jenkinsci/blueocean`

```bash
docker run  -u root -d -p 8080:8080 -p 50000:50000  -v /home/data/jenkins:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock  --name jenkins jenkinsci/blueocean
```

```yml
version: '3'
services:
  jenkins:
    image: jenkinsci/blueocean
    container_name: jenkins
    user: root
    ports:
      - "7000:7000"
      - "50000:50000"
    volumes:
      - /home/data/jenkins:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    restart: unless-stopped

```

### 安装Java JDK环境

1. 下载JDK

2. 配置环境变量

3. 安装`vim`编辑器, 本Linux系统是CentOS发行版,故使用`yum`包管理器
    ```bash
    yum install -y vim
    ```

4. 添加环境变量,编辑环境变量文件,位于根目录的`etc`目录下的`profile`文件
    ```bash
    vim /etc/profile
    ```	

5. 添加JDK的环境, **JDK_DIR**替换成你的JDK目录
    ```
    # /etc/profile
   
    # Java 11 环境
    export JAVA_HOME=/<JDK_DIR>
    export JRE_HOME=${JAVA_HOME}/jre
    export CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib:$CLASSPATH
    export JAVA_PATH=${JAVA_HOME}/bin:${JRE_HOME}/bin
    export PATH=$PATH:${JAVA_PATH}
    ```

6. 重新读取配置文件
    ```bash
    source /etc/profile
    ```

## 安装Maven环境

1. 安装[Maven包](https://maven.apache.org/download.cgi)

2. 解压下载下来的包, 把`<MAVEN_NAME>`替换成MAVEN的路径,把`<DIR>`替换成解压之后的路径
    ```bash
    tar -xzvf <MAVEN_NAME> -C <DIR>
    ```

3. 添加环境变量,编辑环境变量文件,位于根目录的`etc`目录下的`profile`文件
    ```bash
    vim /etc/profile
    ```

4. 在`/etc/profile`文件下,将**MAVEN_NAME**替换成Maven的路径
    ```
    # /etc/profile
    
    # Maven 环境
    export MAVEN_HOME=<MAVEN_NAME>
    export PATH=${MAVEN_HOME}/bin:$PATH
    ```

5. 重启使最新配置生效。
    ```bash
    source /etc/profile
    ```

6. 测试mvn命令
    1. test测试
       ```bash
       type -a mvn
        ```
    2. 查看Maven版本
       ```bash
        mvn --version
       ```

