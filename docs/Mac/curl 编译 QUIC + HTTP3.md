# 编译
第 4 步可以禁用 libpsl：大多数场景下，libpsl 是可选的依赖，禁用后不影响 HTTP/3 的核心功能:
```bash
./configure \
  LDFLAGS="-Wl,-rpath,$HOME/quictls/lib" \
  --with-openssl=$HOME/quictls \
  --with-nghttp3=$HOME/nghttp3 \
  --with-ngtcp2=$HOME/ngtcp2
```

```bash
#### 0. 安装依赖
brew install autoconf automake libtool pkg-config cmake libpsl

#### 1. 编译 quictls（OpenSSL 的 QUIC 分支）
git clone --depth 1 -b openssl-3.1.4+quic https://github.com/quictls/openssl
cd openssl
./config enable-tls1_3 --prefix=$HOME/quictls
make -j$(sysctl -n hw.logicalcpu)
make install
cd ..

#### 2. 编译 nghttp3
git clone https://github.com/ngtcp2/nghttp3
cd nghttp3
autoreconf -fi
./configure --prefix=$HOME/nghttp3 --enable-lib-only
make -j$(sysctl -n hw.logicalcpu)
make install
cd ..

#### 3. 编译 ngtcp2
git clone https://github.com/ngtcp2/ngtcp2 --recurse-submodules
cd ngtcp2
autoreconf -fi
./configure PKG_CONFIG_PATH=$HOME/quictls/lib/pkgconfig:$HOME/nghttp3/lib/pkgconfig \
            LDFLAGS="-Wl,-rpath,$HOME/quictls/lib" \
            --prefix=$HOME/ngtcp2 \
            --enable-lib-only
make -j$(sysctl -n hw.logicalcpu)
make install
cd ..

#### 4. 编译 curl
git clone https://github.com/curl/curl  --recurse-submodules
cd curl
autoreconf -fi
./configure \
  LDFLAGS="-Wl,-rpath,$HOME/quictls/lib" \
  --with-openssl=$HOME/quictls \
  --with-nghttp3=$HOME/nghttp3 \
  --with-ngtcp2=$HOME/ngtcp2

make -j$(sysctl -n hw.logicalcpu)
sudo make install  # 需要管理员权限
```

# 测试:

## 应用测试
```go
git clone --depth 1 https://github.com/sunmery/quic-gin-example.git
cd quic-gin-example
go mod tidy
go run server.go
```

新开一个 终端运行客户端
```bash
go run client.go
```

使用 QUIC+HTTP3 的 curl来查看详细的网络请求和测试:

查看当前 curl 版本:
```
curl --version
```
输出包含`HTTP3`则代表该 curl支持
```
curl 8.13.0-DEV (aarch64-apple-darwin24.3.0) libcurl/8.13.0-DEV quictls/3.1.4 zlib/1.2.12 libidn2/2.3.7 libpsl/0.21.5 ngtcp2/1.12.0-DEV nghttp3/1.9
Release-Date: [unreleased]
Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns ldap ldaps mqtt pop3 pop3s rtsp smb smbs smtp smtps telnet tftp ws wss
Features: alt-svc AsynchDNS HSTS HTTP3 HTTPS-proxy IDN IPv6 Largefile libz NTLM PSL SSL threadsafe TLS-SRP UnixSockets
```

测试服务
```bash
curl --http3-only -kv https://localhost:443
```

正确则输出:
```
* Host localhost:443 was resolved.
* IPv6: ::1
* IPv4: 127.0.0.1
*   Trying [::1]:443...
* Server certificate:
*  subject: CN=localhost
*  start date: Mar 17 23:51:13 2025 GMT
*  expire date: Mar 17 23:51:13 2026 GMT
*  issuer: CN=localhost
*  SSL certificate verify result: self-signed certificate (18), continuing anyway.
*   Certificate level 0: Public key type RSA (2048/112 Bits/secBits), signed using sha256WithRSAEncryption
* Connected to localhost (::1) port 443
* using HTTP/3
* [HTTP/3] [0] OPENED stream for https://localhost:443/
* [HTTP/3] [0] [:method: GET]
* [HTTP/3] [0] [:scheme: https]
* [HTTP/3] [0] [:authority: localhost]
* [HTTP/3] [0] [:path: /]
* [HTTP/3] [0] [user-agent: curl/8.13.0-DEV]
* [HTTP/3] [0] [accept: */*]
> GET / HTTP/3
> Host: localhost
> User-Agent: curl/8.13.0-DEV
> Accept: */*
> 
* Request completely sent off
< HTTP/3 200 
< content-type: application/json; charset=utf-8
< date: Tue, 18 Mar 2025 01:49:40 GMT
< content-length: 32
< 
* Connection #0 to host localhost left intact
{"message":"Hello over HTTP/3!"}                              
```


 ## 网站测试:
 访问 [HTTP/3 QUIC 在线测试](https://http3.wcode.net)
```
https://http3.wcode.net
```

查看支持 HTTP3 的[网站]( https://bagder.github.io/HTTP3-test/), 例如`h2o.examp1e.net`
```
https://http3.wcode.net/?q=h2o.examp1e.net
```

# 参考
1. https://curl.se/docs/http3.html
2. https://segmentfault.com/a/1190000045557760
