#!/usr/bin/bash

# 启用 POSIX 模式并设置严格的错误处理机制
set -o errexit -o pipefail -o nounset

# 检查 DOMAIN 变量是否已定义
if [[ -z "${DOMAIN:-}" ]]; then
    echo "错误：必须定义 DOMAIN 环境变量。"
    exit 1
fi

# 基础目录
export NGINX_DIR="${NGINX_DIR:-/home/docker/nginx}"

# 派生目录
export HTML_DIR="${HTML_DIR:-$NGINX_DIR/html}"
export CONF_DIR="${CONF_DIR:-$NGINX_DIR/conf}"
export SSL_DIR="${SSL_DIR:-$NGINX_DIR/ssl}"

echo "用户定义的变量:"
echo "DOMAIN: ${DOMAIN}"
echo "NGINX_DIR: ${NGINX_DIR}"
echo "HTML_DIR: ${HTML_DIR}"
echo "CONF_DIR: ${CONF_DIR}"
echo "SSL_DIR: ${SSL_DIR}"

# 创建目录
echo "正在创建目录，如果目录存在则不会创建"
mkdir -pv "$HTML_DIR" "$CONF_DIR" "$SSL_DIR"

# 处理SSL证书
handle_ssl_cert() {
    local cert_type=$1
    local source_pattern="$SSL_DIR"/*."$cert_type"
    local target_file="$SSL_DIR/nginx.$cert_type"

    if [ -f "$target_file" ]; then
        echo "$target_file 文件存在，跳过复制"
        return 0
    fi

    # 检查是否有匹配的文件
    if ! compgen -G "$source_pattern" > /dev/null; then
        echo "错误：没有找到 $cert_type 文件 ($source_pattern)"
        exit 1
    fi

    # 复制第一个匹配的文件
    local first_match=$(ls $source_pattern | head -n 1)
    echo "正在复制 $first_match 到 $target_file"
    cp "$first_match" "$target_file"
}

handle_ssl_cert "crt"
handle_ssl_cert "key"

echo "正在拉取 macbre/docker-nginx-http3 镜像"
docker pull ghcr.io/macbre/nginx-http3:latest

# 生成nginx配置
cat > "${CONF_DIR}/nginx.conf" <<EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\${DOMAIN};
}

server {
    server_name ${DOMAIN} www.${DOMAIN};

    # HTTP/3 with QUIC
    listen 443 quic reuseport;

    # HTTP/2 and HTTP/1.1
    listen 443 ssl;
    http2 on;

    # Security headers
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff;
    add_header Alt-Svc 'h3=":443"; ma=86400, h3-29=":443"; ma=86400';

    # SSL/TLS configuration
    ssl_protocols TLSv1.3 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ecdh_curve X25519:P-256:P-384;
    ssl_early_data on;
    ssl_stapling on;
    ssl_stapling_verify on;

    # SSL certificates
    ssl_certificate     /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        root   /etc/nginx/html;
        index  index.html index.htm;
    }
}
EOF

# 清理现有容器和进程
echo "清理可能的冲突资源"
docker stop nginx-quic &>/dev/null || true
docker rm nginx-quic &>/dev/null || true

# 杀死占用80和443端口的进程
for port in 80 443; do
    pid=$(sudo lsof -t -i:$port || true)
    if [ -n "$pid" ]; then
        sudo kill -9 $pid
        echo "已终止占用端口 $port 的进程 (PID: $pid)"
    fi
done

# 运行容器
echo "正在启动NGINX容器"
docker run -d \
    --name nginx-quic \
    -v "${HTML_DIR}":/etc/nginx/html \
    -v "${CONF_DIR}":/etc/nginx/conf.d \
    -v "${SSL_DIR}":/etc/nginx/ssl \
    -p 80:80 \
    -p 443:443/tcp \
    -p 443:443/udp \
    ghcr.io/macbre/nginx-http3

echo "容器已启动，等待5秒后检查状态..."
sleep 5

# 检查容器状态
if docker ps | grep -q nginx-quic; then
    echo "容器运行状态:"
    docker ps | grep nginx-quic

    echo "查看前10条日志:"
    docker logs --tail=10 nginx-quic

    echo "测试HTTP访问:"
    curl -I http://${DOMAIN} || echo "HTTP测试失败"

    echo "测试HTTPS访问:"
    curl -Ik https://${DOMAIN} || echo "HTTPS测试失败"
else
    echo "错误：容器启动失败"
    docker logs nginx-quic
    exit 1
fi

#docker run -d \
#    --name nginx-quic \
#    -v /home/docker/nginx/html:/etc/nginx/html \
#    -v /home/docker/nginx/conf:/etc/nginx/conf.d \
#    -v /home/docker/nginx/ssl:/etc/nginx/ssl \
#    -p 80:80 \
#    -p 443:443/tcp \
#    -p 443:443/udp \
#    ghcr.io/macbre/nginx-http3
