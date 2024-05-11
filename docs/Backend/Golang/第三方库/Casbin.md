Casbin是RPEM
R: Request请求定义
P: Policy Definition 策略定义
E: Policy Effect 策略范围
M: Matchers匹配器
## 模型
1. RBAC(基于角色访问控制)
2. ACL(访问控制列表)
3. ABAC(属性基础访问控制)
4. RESTful(路由限制)

## 模型语法
### Request 请求定义
1. sub 主体
2. obj 对象
3. act 权限
4. eft

```
[request_definition]
r = sub, obj, act, eft
```

### Policy Definition 策略定义

一般策略的定义与请求的定义相同
```
[policy_definition]
p = sub, obj, act
p2 = sub, act
```
### Policy Effect 策略范围
固定规则, 支持的 policy effects 如下：

|Policy Effect|意义|示例|
|---|---|---|
|some(where (p.eft == allow))|allow-override|[ACL, RBAC, etc.](https://casbin.org/zh/docs/supported-models#examples)|
|!some(where (p.eft == deny))|deny-override|[拒绝改写](https://casbin.org/zh/docs/supported-models#examples)|
|some(where (p.eft == allow)) && !some(where (p.eft == deny))|allow-and-deny|[同意与拒绝](https://casbin.org/zh/docs/supported-models#examples)|
|priority(p.eft) \| deny|priority|[优先级](https://casbin.org/zh/docs/supported-models#examples)|
|subjectPriority(p.eft)|priority based on role|[主题优先级](https://casbin.org/zh/docs/supported-models#examples)|

示例:
```
[policy_effect]
e = some(where (p.eft == allow))
```
###  Matchers 匹配器
是策略匹配器的定义
```
[matchers]
m = r.sub == p.sub && r.obj == p.obj && r.act == p.act
```

##  使用
RBAC的一个学生范例:
model.conf
```
[request_definition]
r = sub, obj, act

[policy_definition]
p = sub, obj, act, eft

[role_definition]
g = _, _

[policy_effect]
e = some(where (p.eft == allow)) && !some(where (p.eft == deny))

[matchers]
m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act

```

policy.csv:
```
p, student, student, read, allow
p, student, student, write, allow
p, student, teacher, read, deny
p, student, teacher, write, deny
p, student, admin, read, deny
p, student, admin, write, deny

p, teacher, student, read, deny
p, teacher, student, write, deny
p, teacher, teacher, read, allow
p, teacher, teacher, write, allow
p, teacher, admin, read, deny
p, teacher, admin, write, deny

p, admin, student, read, allow
p, admin, student, write, allow
p, admin, teacher, read, allow
p, admin, teacher, write, allow
p, admin, admin, read, allow
p, admin, admin, write, allow

g, student, student
g, teacher, teacher
g, admin, admin

```

## 参考
1. https://casbin.org/zh/docs/syntax-for-models
2. https://casbin.org/zh/editor/
3. https://github.com/lisa-sum/go-casbin-RBAC
4. https://github.com/casbin/casbin#tutorials
5. https://github.com/go-kratos/examples/tree/main/casbin