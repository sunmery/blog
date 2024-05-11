docker run -d \
-h 192.168.0.235 \
-p 443:443 -p 80:80 -p 2222:22 \
-e TZ=Asia/Shanghai \
--shm-size 256m \
--name gitlab \
--restart always \
-v /data/gitlab/config:/etc/gitlab \
-v /data/gitlab/logs:/var/log/gitlab \
-v /data/gitlab/data:/var/opt/gitlab \

gitlab/gitlab-ce:latest
#-h这里写ip
-p指定端口随意网页设置



#修改配置文件
vi /data/gitlab/config/gitlab.rb
#比较配置
gitlab-ctl diff-config
#加载配置
gitlab-ctl reconfigure
#重启gitlab
gitlab-ctl restart
#查看状态
gitlab-ctl status



# 修改gitlab.rb文件中的IP与端口号

提示：在规定的位置放置规定的命令

// 在gitlab创建项目时候http地址的host(不用添加端口)
external_url 'http://192.168.0.235'

//配置ssh协议所使用的访问地址和端口
gitlab_rails['gitlab_ssh_host'] = '192.168.0.235' //和上一个IP输入的一样
gitlab_rails['gitlab_shell_ssh_port'] = 2222 // 此端口是run时2222端口映射的22端口
:wq //保存配置文件并退出
**-p 2222:22**
#理解是ssh转发，固定映射22就可以用于ssh拉取代码，但是本机22冲突，这里设置一个2222用于映射，在设置web端用于复制拉取，这里的gitlab_shell_ssh_port 2222显示在web端用于复制



# 设置邮件发送
vi /etc/gitlab/gitlab.rb

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "xinghuan@xinghuankj.com"
gitlab_rails['smtp_password'] = "ZYWYaXyx2jeGMWG4"
gitlab_rails['smtp_domain'] = "qq.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['smtp_pool'] = true

gitlab_rails['gitlab_email_from'] = 'xinghuan@xinghuankj.com'  #邮箱地址

user['git_user_email'] = "xinghuan@xinghuankj.com"

#重新加载配置

gitlab-ctl reconfigure

*执行这个命令后，可能会卡住等待一小会儿*
gitlab-rails console
*测试邮件发送*
Notify.test_email('13731754667@163.com','邮件标题','邮件内容').deliver_now


# 设置ssh密钥拉取
## 检查密钥是否存在
ls -alh ~/.ssh
## 不存在生成密钥
#用户wangbin
生成密钥
ssh-keygen -t rsa -C "gitlab" -f ~/.ssh/gitlabpullweb_rsa
## ssh密钥上传gitlab
登录到 GitLab。
在右上角的顶栏上，选择您的头像。
选择首选项。（偏好设置也可以）
在左侧边栏上，选择“SSH 密钥”。
在“密钥”框中，粘贴公钥的内容。如果手动复制了密钥，请确保复制整个密钥，该密钥以id_rsa.pub结尾
在“标题”框中，键入说明，如 或 。Work LaptopHome Workstation
自选。在“过期日期”框中，选择到期日期。（在 GitLab 12.9 中引入。在：
GitLab 13.12 及更早版本，到期日期仅供参考。它不会阻止您使用密钥。管理员可以查看到期日期，并在删除密钥时使用它们作为指导。
GitLab 14.0 及更高版本，将强制执行到期日期。管理员可以允许使用过期的密钥。
GitLab 在每天 UTC 时间 02：00 检查所有 SSH 密钥。它会通过电子邮件为在当前日期过期的所有 SSH 密钥发送过期通知。（在 GitLab 13.11 中引入。
GitLab 在每天 UTC 时间 01：00 检查所有 SSH 密钥。它会通过电子邮件向计划从现在起七天后过期的所有 SSH 密钥发出过期通知。（在 GitLab 13.11 中引入。

选择“添加密钥”。

## 添加私钥到本机ssh

#添加私钥，指向私钥文件
ssh-add ~/.ssh/gitlabpullweb_rsa
### 失败使用
ssh-agent bash
#检查添加成功
 ssh-add -l

## 验证是否可以连接
ssh -T git@192.168.0.235 -p 2222
大写-T 指向主机
小写-p指向端口
选择-i指向密钥文件
 -i ~/.ssh/gitlabpullweb_rsa 
#成功提示
Welcome to GitLab, @wangbin!

# 命令修改root密码
#执行命令  
**gitlab-rails console -e production**
```
显示内容
--------------------------------------------------------------------------------
 Ruby:         ruby 2.7.5p203 (2021-11-24 revision f69aeb8314) [x86_64-linux]
 GitLab:       14.6.1 (661d663ab2b) FOSS
 GitLab Shell: 13.22.1
 PostgreSQL:   12.7
 --------------------------------------------------------------------------------
Loading production environment (Rails 6.1.4.1)
```
```
 # gitlab-rails console -e production      # 然后以此执行下面命令（需要提前查询用户的id号）
...> user = User.where(id: 1).first
...> user.password = 'root123*'
...> user.password_confirmation = 'root123*'
...> user.save!
```
```
例如，重置root用户密码为root123*，root用户id为1。

# gitlab-rails console -e production

irb(main):001:0> user = User.where(id: 1).first
=> #<User id:1 @root>
irb(main):002:0> user.password = 'root123*'
=> "root123*"
irb(main):003:0> user.password_confirmation = 'root123*'
=> "root123*"
irb(main):004:0> user.save!
Enqueued ActionMailer::DeliveryJob (Job ID: e562694d-2a1b-4bad-843b-d8567ac51077) to Sidekiq(mailers) with arguments: "DeviseMailer", "password_change", "deliver_now", #<GlobalID:0x00007fae7e55bcc8 @uri=#<URI::GID gid://gitlab/User/1>>
=> true
irb(main):005:0> quit
```