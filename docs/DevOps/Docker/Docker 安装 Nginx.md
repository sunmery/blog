## 安装
```shell
docker pull nginx
```

## 配置
```shell
mkdir -p /home/nginx/conf
mkdir -p /home/nginx/conf/ssl
mkdir -p /home/nginx/log
mkdir -p /home/nginx/html
```

### SSL
[腾讯云](https://cloud.tencent.com/document/product/400/35244)
```conf
# HTTPS www.lookeke.cn
    server {
     #SSL 默认访问端口号为 443
     listen 443 ssl;
     #请填写绑定证书的域名
     server_name www.lookeke.cn;
     #请填写证书文件的相对路径或绝对路径
     ssl_certificate /home/nginx/conf/ssl/lookeke.cn_nginx/lookeke.cn_bundle.crt;
     #请填写私钥文件的相对路径或绝对路径
     ssl_certificate_key /home/nginx/conf/ssl/lookeke.cn_nginx/lookeke.cn.key;
     ssl_session_timeout 5m;
     #请按照以下协议配置
     ssl_protocols TLSv1.2 TLSv1.3;
     #请按照以下套件配置，配置加密套件，写法遵循 openssl 标准。
     ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
     ssl_prefer_server_ciphers on;
     location / {
         #网站主页路径。此路径仅供参考，具体请您按照实际目录操作。
         #例如，您的网站主页在 Nginx 服务器的 /etc/www 目录下，则请修改 root 后面的 html 为 /etc/www。
         root /home/nginx/html/web;
         index  index.html index.htm;
     }
 }
```

## 测试

检查配置文件是否有误

```shell
nginx -t
```

重启读取配置
```shell
docker restart nginx
```

## 运行
--restart: 
-   `no`：不自动重启容器，默认值。
-   `on-failure[:max-retries]`：只有在容器以非0状态（即失败）退出时才会重启，可指定最大重试次数。
-   `always`：不管容器是以什么状态退出，都将尝试重启容器。
-   `unless-stopped`：除非手动停止了容器，否则总是尝试自动重启容器。

```shell
docker run \
-p 80:80 \
-p 443:443 \
--restart=unless-stopped \
--name nginx \
-v /home/nginx/cache:/var/cache/nginx \
-v /home/nginx/ssl:/etc/nginx/ssl \
-v /home/nginx/conf/:/etc/nginx/conf/ \
-v /home/nginx/log:/var/log/nginx \
-v /home/nginx/html:/usr/share/nginx/html \
-d nginx:latest
```

IP限速:
[文章](https://juejin.cn/post/7219889814115811388)
[NGINX(]http://nginx.org/en/docs/http/ngx_http_core_module.html#limit_rate)
`limit_rate`:  `1k` 限制单个IP的速率, 这里为`1k`流量
`limit_rate_after`: `50m`, 50m之后限速为`limit_rate`定义的值
```
location / { 
	limit_rate_after 50m;
	limit_rate 1k;
	root html;
}
```

## 总结

```conf
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

		# 日志
    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

		# 文件压缩配置
		# 是否启用压缩
    gzip  on;
    # 要压缩的文件类型
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
		# 压缩等级 1-9
		gzip_comp_level 6;
		# 开始压缩的最低大小,单位: kb
		gzip_min_length 1024;
		# 设置Gzip压缩时内存缓冲区的大小和数量。具体来说，这个指令将分配16个内存缓冲区，每个缓冲区大小为8KB
		gzip_buffers 16 8k;
		# 浏览器根据Accept-Encoding请求头来判断是否需要解压缩响应内容
		gzip_vary on;

		# 包含默认的配置文件
    # include /etc/nginx/conf.d/*.conf;

		# HTTP 服务器IP
    server {
        listen 80;
        server_name 47.120.5.83;
        return 301 https://www.lookeke.cn$request_uri;
    }

    # HTTP www.域名跳转
    server {
        listen 80;
        server_name www.lookeke.cn;
        return 301 https://www.lookeke.cn$request_uri;
    }

		# HTTP 域名跳转
    server {
        listen 80;
        server_name lookeke.cn;
        return 301 https://www.lookeke.cn$request_uri;
    }

    # HTTPS 域名跳转
    server {
    		listen 443 ssl;
    		server_name lookeke.cn;
    		# 证书文件的相对路径或绝对路径
        ssl_certificate /etc/nginx/ssl/lookeke.cn_nginx/lookeke.cn_bundle.crt;

        # 私钥文件的相对路径或绝对路径
        ssl_certificate_key /etc/nginx/ssl/lookeke.cn_nginx/lookeke.cn.key;
        ssl_session_timeout 5m;

        # 协议配置
        ssl_protocols TLSv1.2 TLSv1.3;

        # 配置加密套件，写法遵循 openssl 标准。
        #ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        #ssl_prefer_server_ciphers on;

    		return 301 https://www.lookeke.cn$request_uri;
    }

		# HTTPS 配置
    server {
        # SSL 默认访问端口号为 443
    		listen 443 ssl;

    		# 绑定证书的域名
    		server_name www.lookeke.cn;

    		# 证书文件的相对路径或绝对路径
    		ssl_certificate /etc/nginx/ssl/lookeke.cn_nginx/lookeke.cn_bundle.crt;

    		# 私钥文件的相对路径或绝对路径
    		ssl_certificate_key /etc/nginx/ssl/lookeke.cn_nginx/lookeke.cn.key;
    		ssl_session_timeout 5m;

    		# 协议配置
    		ssl_protocols TLSv1.2 TLSv1.3;

    		# 配置加密套件，写法遵循 openssl 标准。
    		#ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
    		#ssl_prefer_server_ciphers on;

    		# 网站主页
    		location / {
		        root   /usr/share/nginx/html/web/;
		        index  index.html index.htm;
        }

        # 项目私有配置
        location /login {
            proxy_pass https://www.lookeke.cn/;
        }

        # 项目私有配置
        location /undefined {
            proxy_pass https://www.lookeke.cn/;
        }
    }
}
```

- 服务器有多个CPU核心，使用`reuseport`可以提高性能
调整流和并发连接的数量:
```conf
http {
    ...
    # 设置每个连接的最大并发流数量
    http2_max_concurrent_streams 128;

    # 设置QUIC的最大并发连接数量
    quic_max_concurrent_streams 128;
}

```
## 参考
[TX](https://cloud.tencent.com/developer/article/1395059)