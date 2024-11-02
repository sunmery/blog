#!/usr/bin/bash

# 启用 POSIX 模式并设置严格的错误处理机制
set -o posix errexit -o pipefail

if [ -z "${DOMAIN}" ]; then
    echo "请编写你的域名"
    exit 1
fi

# 判断 NGINX_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${NGINX_DIR}" ]; then
    #export NGINX_DIR="/home/nginx"
    exit 1
fi

# 判断 HTML_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${HTML_DIR}" ]; then
    #export HTML_DIR="${NGINX_DIR}/html"
    exit 1
fi

# 判断 CONF_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${CONF_DIR}" ]; then
    #export CONF_DIR="${NGINX_DIR}/conf"
    exit 1
fi

# 判断 SSL_DIR 变量是否已定义，如果未定义，则设置默认值
if [ -z "${SSL_DIR}" ]; then
    #export SSL_DIR="${NGINX_DIR}/ssl"
    exit 1
fi

echo "用户定义的变量:"
echo "DOMAIN: ${DOMAIN}"
echo "NGINX_DIR: ${NGINX_DIR}"
echo "HTML_DIR: ${HTML_DIR}"
echo "CONF_DIR: ${CONF_DIR}"
echo "SSL_DIR: ${SSL_DIR}"

echo "正在创建目录, 如果目录存在则不会创建"
mkdir -pv "$HTML_DIR"
mkdir -pv "$CONF_DIR"
mkdir -pv "$SSL_DIR"

# SSL_DIR=$(pwd)
if [ -f "$SSL_DIR"/nginx.crt ]; then
  echo "$SSL_DIR/nginx.crt 文件存在, 跳过复制"
  #echo "nginx crt证书文件已存在, 正在删除"
  #rm -rf "$SSL_DIR"/nginx.crt
else
  echo "$SSL_DIR/nginx.crt 文件不存在, 正在将用户上传的crt文件复制并更名为 $SSL_DIR/nginx.crt, 请确保该目录有正确非过期的crt证书文件"
  cp "$SSL_DIR"/*.crt "$SSL_DIR"/nginx.crt
  if [ $? -eq 1 ]; then
    echo "没有上传SSL的crt文件到指定的SSL_DIR目录!"
    exit 1
  fi
fi

if [ -f "$SSL_DIR"/nginx.key ]; then
  echo "$SSL_DIR/nginx.crt 文件存在, 跳过复制"
  #echo "nginx crt证书文件已存在, 正在删除"
  #rm -rf "$SSL_DIR"/nginx.key
else
  echo "$SSL_DIR/nginx.key 文件不存在, 正在将用户上传的crt文件复制并更名为 $SSL_DIR/nginx.key, 请确保该目录有正确非过期的crt证书文件"
  cp "$SSL_DIR"/*.key "$SSL_DIR"/nginx.key
  if [ $? -eq 1 ]; then
    echo "没有上传SSL的key文件到指定的SSL_DIR目录!"
    exit 1
  fi
fi

echo "正在拉取 macbre/docker-nginx-http3 镜像"
# https://github.com/macbre/docker-nginx-http3
docker pull ghcr.io/macbre/nginx-http3:latest

# macbre/docker-nginx-http3 默认的 nginx.conf:
# this allows you to call directives such as "env" in your own conf files
# http://nginx.org/en/docs/ngx_core_module.html#env
#
# and load dynamic modules via load_module
# http://nginx.org/en/docs/ngx_core_module.html#load_module
#include /etc/nginx/main.d/*.conf;
#
#worker_processes  1;
#
#error_log  /var/log/nginx/error.log warn;
#pid        /var/run/nginx/nginx.pid;
#
#events {
#    worker_connections  1024;
#}
#
#
#http {
#    include       /etc/nginx/mime.types;
#    default_type  application/octet-stream;
#
#    log_format  quic  '$remote_addr - $remote_user [$time_local] "$request" '
#                      '$status $body_bytes_sent "$http_referer" '
#                      '"$http_user_agent" "$http_x_forwarded_for" "$http3"';
#
#    access_log  /var/log/nginx/access.log  quic;
#
#    sendfile        on;
#    #tcp_nopush     on;
#
#    keepalive_timeout  65;
#
#    # security, reveal less information about ourselves
#    server_tokens off; # disables emitting nginx version in error messages and in the “Server” response header field
#    more_clear_headers 'Server';
#    more_clear_headers 'X-Powered-By';
#
#    # prevent clickjacking attacks
#    more_set_headers 'X-Frame-Options: SAMEORIGIN';
#
#    # help to prevent cross-site scripting exploits
#    more_set_headers 'X-XSS-Protection: 1; mode=block';
#
#    # help to prevent Cross-Site Scripting (XSS) and data injection attacks
#    # https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
#    more_set_headers "Content-Security-Policy: object-src 'none'; frame-ancestors 'self'; form-action 'self'; block-all-mixed-content; sandbox allow-forms allow-same-origin allow-scripts allow-popups allow-downloads; base-uri 'self';";
#
#    # enable response compression
#    gzip  on;
#    brotli on;
#    brotli_static on;
#
#    include /etc/nginx/conf.d/*.conf;
#}

cat > "${CONF_DIR}"/nginx.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN}; # server_name
    return 301 https://${DOMAIN}; # webside
}

server {
    server_name ${DOMAIN} www.${DOMAIN};  # 服务器名称

    # UDP listener for QUIC+HTTP/3
    # http/3
    listen 443 quic reuseport;

    # http/2 and http/1.1
    listen 443 ssl;
    http2 on;

    # 以下为各种 HTTP 安全相关头部的设置
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options "DENY";
    add_header Alt-Svc 'h3=":443"; ma=86400, h3-29=":443"; ma=86400';

    # SSL/TLS 相关配置
    ssl_protocols TLSv1.3 TLSv1.2;  # 设置支持的 SSL 协议版本
    # ssl_ciphers ...;  # 设置 SSL 密码套件
    ssl_prefer_server_ciphers on;  # 优先使用服务器的密码套件
    ssl_ecdh_curve X25519:P-256:P-384;  # 设置 ECDH 曲线
    ssl_early_data on;  # 启用 TLS 1.3 的 0-RTT 特性
    ssl_stapling on;  # 启用 OCSP Stapling
    ssl_stapling_verify on;  # 启用 OCSP Stapling 的验证

    # SSL 证书路径配置
    ssl_certificate     /etc/nginx/ssl/nginx.crt;  # SSL 证书路径
    ssl_certificate_key /etc/nginx/ssl/nginx.key;  # SSL 证书密钥路径

    location / {
        root   /etc/nginx/html;  # 设置根目录路径
        index  index.html index.htm default.html default.htm;  # 设置默认index首页文件
    }
}
EOF

echo "清理可能的意外, 保证容器被本shell script控制"
# 查询端口 80 和 443 的进程，并获取它们的 PID
pid_80=$(sudo lsof -t -i:80)
pid_443=$(sudo lsof -t -i:443)

# 如果找到对应的进程，就杀死它们
if [ -n "$pid_80" ]; then
    sudo kill -9 $pid_80
    echo "Killed process on port 80 (PID: $pid_80)"
fi

if [ -n "$pid_443" ]; then
    sudo kill -9 $pid_443
    echo "Killed process on port 443 (PID: $pid_443)"
fi
docker stop nginx-quic || true
docker rm nginx-quic || true

echo "正在运行NGINX容器"
# HTML_DIR=""
# CONF_DIR=""
# SSL_DIR=""
docker run -itd \
--name nginx-quic \
-v "${HTML_DIR}":/etc/nginx/html \
-v "${CONF_DIR}":/etc/nginx/conf.d \
-v "${SSL_DIR}":/etc/nginx/ssl \
-p '443:443/tcp' \
-p '443:443/udp' \
-p 80:80 \
ghcr.io/macbre/nginx-http3

echo "重新加载配置"
docker exec -it nginx-quic nginx -s reload

echo "查询前十条日志"
docker logs nginx-quic | head -n 10
