```
worker_processes  1;

pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 10m;
    upstream douyin {
        # server 192.168.0.158:30001;
        server 47.120.5.83:30001;
        server 120.77.172.80:30001;
    }

    server {
        listen 8080;
        client_max_body_size 1024m;
        location / {
            if ($request_method !~* GET|POST) { return 444; }
            #使用444错误代码可以更加减轻服务器负载压力。
            #防止SQL注入
            if ($uri ~* (/~).*) { return 501; }
            if ($uri ~* (\\x.)) { return 501; }
            #防止SQL注入
            if ($query_string ~* "[;'<>].*") { return 509; }
            if ($request_uri ~ " ") { return 509; }
            if ($request_uri ~ (\/\.+)) { return 509; }
            if ($request_uri ~ (\.+\/)) { return 509; }
            if ($query_string ~* ".*('|--|union|insert|drop|truncate|update|from|grant|exec|where|select|and|count|chr|mid|like|iframe|script|alert|webscan|dbappsecurity|style|confirm|innerhtml|innertext|class).*"){ return 500; }
            if ($uri ~* .*(viewsource.jsp)$) { return 404; }
            if ($uri ~* .*(/~).*) { return 404; }
            if ($request_uri ~* "\(cost\(\)") { return 504; }
            if ($request_uri ~* "\(concat\(\)") { return 504; }

            if ($request_uri ~* "[+|(%20)]union[+|(%20)]") { return 504; }
            if ($request_uri ~* "[+|(%20)]and[+|(%20)]") { return 504; }
            if ($request_uri ~* "[+|(%20)]select[+|(%20)]") { return 504; }
            if ($request_uri ~* "[+|(%20)]or[+|(%20)]") { return 504; }
            if ($request_uri ~* "[+|(%20)]delete[+|(%20)]") { return 504; }
            if ($request_uri ~* "[+|(%20)]update[+|(%20)]") { return 504; }
            if ($request_uri ~* "[+|(%20)]insert[+|(%20)]") { return 504; }
            if ($query_string ~ "(<|%3C).*script.*(>|%3E)") { return 505; }
            if ($query_string ~ "GLOBALS(=|\[|\%[0-9A-Z]{0,2})") { return 505; }
            if ($query_string ~ "_REQUEST(=|\[|\%[0-9A-Z]{0,2})") { return 505; }
            if ($query_string ~ "proc/self/environ") { return 505; }
            if ($query_string ~ "mosConfig_[a-zA-Z_]{1,21}(=|\%3D)") { return 505; }
            if ($query_string ~ "base64_(en|de)code\(.*\)") { return 505; }
            if ($query_string ~ "[a-zA-Z0-9_]=http://") { return 506; }
            if ($query_string ~ "[a-zA-Z0-9_]=(\.\.//?)+") { return 506; }
            if ($query_string ~ "[a-zA-Z0-9_]=/([a-z0-9_.]//?)+") { return 506; }
            if ($query_string ~ "b(ultram|unicauca|valium|viagra|vicodin|xanax|ypxaieo)b") { return 507; }
            if ($query_string ~ "b(erections|hoodia|huronriveracres|impotence|levitra|libido)b") {return 507; }
            if ($query_string ~ "b(ambien|bluespill|cialis|cocaine|ejaculation|erectile)b") { return 507; }
            if ($query_string ~ "b(lipitor|phentermin|pro[sz]ac|sandyauer|tramadol|troyhamby)b") { return 507; }
            #这里大家根据自己情况添加删减上述判断参数，cURL、wget这类的屏蔽有点儿极端了，但要“宁可错杀一千，不可放过一个”。
            if ($http_user_agent ~* YisouSpider|ApacheBench|WebBench|Jmeter|JoeDog|Havij|GetRight|TurnitinBot|GrabNet|masscan|mail2000|github|wget|curl|Java|python) { return 508; }
            #同上，大家根据自己站点实际情况来添加删减下面的屏蔽拦截参数。
            if ($http_user_agent ~* "Go-Ahead-Got-It") { return 508; }
            if ($http_user_agent ~* "GetWeb!") { return 508; }
            if ($http_user_agent ~* "Go!Zilla") { return 508; }
            if ($http_user_agent ~* "Download Demon") { return 508; }
            if ($http_user_agent ~* "Indy Library") { return 508; }
            if ($http_user_agent ~* "libwww-perl") { return 508; }
            if ($http_user_agent ~* "Nmap Scripting Engine") { return 508; }
            if ($http_user_agent ~* "~17ce.com") { return 508; }
            if ($http_user_agent ~* "WebBench*") { return 508; }
            if ($http_user_agent ~* "spider") { return 508; } #这个会影响国内某些搜索引擎爬虫，比如：搜狗
            #拦截各恶意请求的UA，可以通过分析站点日志文件或者waf日志作为参考配置。
            if ($http_referer ~* 17ce.com) { return 509; }
            proxy_set_header HOST $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://douyin/;
        }
    }
}

```