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
        ssl_certificate /etc/nginx/ssl/lookeke.cn_bundle.crt;

        # 私钥文件的相对路径或绝对路径
        ssl_certificate_key /etc/nginx/ssl/lookeke.cn.key;
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
    		ssl_certificate /etc/nginx/ssl/lookeke.cn_bundle.crt;

    		# 私钥文件的相对路径或绝对路径
    		ssl_certificate_key /etc/nginx/ssl/lookeke.cn.key;
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