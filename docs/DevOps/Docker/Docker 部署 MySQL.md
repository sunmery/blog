## Docker
```shell
rm -rf /data/mysql
mkdir -p /data/mysql/
docker stop mysql && docker rm mysql

docker run \
--name mysql \
-e MYSQL_USER=rx \
-e MYSQL_ROOT_PASSWORD=263393 \
-e MYSQL_DATABASE=db \
-d \
-p 3306:3306 \
-v /data/mysql/:/var/lib/mysql \
mysql:latest \
--symbolic-links=0 \
--character-set-server=utf8mb4 \
--bind-address=0.0.0.0
```

-e 选项:
- MYSQL_USER 新的超级用户, 默认 root
- MYSQL_DATABASE 指定数据库
- MYSQL_RANDOM_ROOT_PASSWORD
这是一个可选变量。设置为非空值，如 `yes` ，为 root 用户生成随机初始密码（使用 `pwgen` ）。生成的根密码将打印到 stdout （ `GENERATED ROOT PASSWORD: .....` ）。
- MYSQL_ONETIME_PASSWORD
初始化完成后，将 root（而不是 ！中 `MYSQL_USER` 指定的用户）用户设置为已过期，强制在首次登录时更改密码。任何非空值都将激活此设置。注意：此功能仅在MySQL 5.6 +上受支持。在MySQL 5.5上使用此选项将在初始化期间引发适当的错误。

--character-set-server 选项:
无需 cnf 就可以修改 mysql 的 cnf

- character-set-server 设置编码, 默认 utf8
- collation-server