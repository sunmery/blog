#!/bin/bash

set -x

server_name=""

dir="/home/nginx"
conf_dir=${dir}/conf
html_dir=${dir}/html
ssl_dir=${dir}/ssl

mkdir -p ${dir}
mkdir -p ${html_dir}
mkdir -p ${ssl_dir}

cd ${dir} || exit

docker pull ghcr.io/macbre/nginx-http3

docker run \
-itd \
--name nginx-quic \
-p '80:80' \
-p '443:443/tcp' \
-p '443:443/udp'\
-v /home/nginx/html:/etc/nginx/html \
-v /home/nginx/conf:/etc/nginx/conf.d \
-v /home/nginx/ssl:/etc/nginx/ssl \
ghcr.io/macbre/nginx-http3

cat > ${conf_dir}/nginx.conf <<EOF
# 访问HTTP(80端口)自动跳转到HTTPS(443端口)
server {
    listen 80;
    server_name ${server_name}; # server_name
    return 301 https://${server_name}; # webside
}

server {
    server_name ${server_name};  # 服务器名称

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

set +x
