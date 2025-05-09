FROM node:18-alpine AS builder
# FROM node:slim 仅包含运行 node 所需的最小包
#
# 要依赖的node版本, 这里以node 18演示, 使用小体积的os系统alpine以减少构建的镜像大小

WORKDIR /web
COPY . /web

# 分离环境
RUN cd /web

# 如果出现错误提示: 缺少使用 process.dlopen:
# Alpine v3.18及更早版本:
# RUN apk add --no-cache gcompat
# Alpine v3.19:
# apk add --no-cache libc6-compat

# 可选, 如果你的服务器环境连npm都下不动依赖包, 尝试使用大陆proxy
RUN npm config set registry https://registry.npmmirror.com

# 本项目使用 pnpm 管理包, 根据你的实际来修改
RUN npm install pnpm -g
# 验证 pnpm安装与否
RUN pnpm -v

# 可选, 如果你的服务器环境连pnpm都下不动依赖包, 尝试使用大陆proxy
#RUN pnpm config set registry https://registry.npmmirror.com

# 删除 npm 下载的包,由 pnpm 接管
RUN rm -f node_modules
# 安装依赖
RUN pnpm install
# RUN pnpm install --no-frozen-lockfile 不根据package.lock的包来下载

# 打包
RUN pnpm build

# 运行清理工作
RUN rm -rf node_modules

# nginx QUIC + HTTP3 大小约为74.9MB
FROM ghcr.io/macbre/nginx-http3
# 使用nginx代理 web 项目的映射

# 把上一步骤打包好的的 dist目录传递到 nginx 默认的 html 目录作为映射
COPY --from=builder /web/dist/ /usr/share/nginx/html/

# 测试用, 查看目录是否有文件
RUN ls /usr/share/nginx/html/

# 挂载 Nginx 的必要文件,
# /etc/nginx/ssl/是 SSL 配置,不需要删掉即可
# /var/log/nginx/ 是 nginx 日志,不需要删掉即可
# /var/cache/nginx/是 nginx 缓存, 不需要删掉即可
# /etc/nginx/conf/ 是 nginx 的配置文件目录, 必须保留
# /usr/share/nginx/html/是 nginx 的 html 目录, 必须保留
VOLUME ["/etc/nginx/html/","/etc/nginx/ssl/","/etc/nginx/conf.d/"]

# 运行 nginx 服务
CMD ["nginx", "-g", "daemon off;"]

# 执行打包
# --progress=plain: 构建过程中显示的详细信息的格式
# --no-cache: 不使用缓存
# -t: 标签, 例如: lisa/frontend:v2
# frontend/ : 构建的目录, 相对于Dockerfile的路径, 与Docker相同的目录使用 . 表示当前目录
# -f frontend/Dockerfile: 相对路径, 指定Dockerfile的路径
# docker build --progress=plain --no-cache -t lisa/frontend:v2 frontend/ -f frontend/Dockerfile

# 运行示例
# docker run -itd \
# --name nginx-quic \
# -v /home/nginx/html:/etc/nginx/html \
# -v /home/nginx/conf:/etc/nginx/conf.d \
# -v /home/nginx/ssl:/etc/nginx/ssl \
# -p '443:443/tcp' \
# -p '443:443/udp' \
# -p 80:80 \
# ccr.ccs.tencentyun.com/lisa/frontend:v2
