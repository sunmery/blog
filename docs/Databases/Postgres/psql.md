使用特定用户登录特定的数据库
-h: 地址
-U: 用户
-d: 数据库

```bash
psql -h localhost -U postgres -d simple_bank
```

## 死锁调试

### 常见的死锁原因

1. 一个表的外键约束, 当一个事务更新时则会可能引起死锁
2. 更新锁, 一个事务在操作一行数据时(没有提交或者回滚), 其它事务也试图修改此行就被阻塞, 然后当第一个事务也试图更新第二个事务所修改的行时就会引发死锁,
   即互相等待对方的锁

调试步骤:

1. 一般都是由并发运行两个琥珀多个事务引起的死锁, 复现步骤可以使用两个终端连接数据库实例
2. 两个终端输入BEGIN开启事务
3. 运行命令直到有一个事务被阻塞
4. 使用以下链接或示例的代码找出死锁问题的原因:
   https://wiki.postgresql.org/wiki/Lock_Monitoring

```sql
 SELECT blocked_locks.pid                  AS blocked_pid,
        blocked_activity.usename           AS blocked_user,
        blocking_locks.pid                 AS blocking_pid,
        blocking_activity.usename          AS blocking_user,
        blocked_activity.query             AS blocked_statement,
        blocking_activity.query            AS current_statement_in_blocking_process,
        blocked_activity.application_name  AS blocked_application,
        blocking_activity.application_name AS blocking_application
 FROM pg_catalog.pg_locks blocked_locks
          JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
          JOIN pg_catalog.pg_locks blocking_locks
               ON blocking_locks.locktype = blocked_locks.locktype
                   AND blocking_locks.DATABASE IS NOT DISTINCT
 FROM blocked_locks.DATABASE
     AND blocking_locks.relation IS NOT DISTINCT
 FROM blocked_locks.relation
     AND blocking_locks.page IS NOT DISTINCT
 FROM blocked_locks.page
     AND blocking_locks.tuple IS NOT DISTINCT
 FROM blocked_locks.tuple
     AND blocking_locks.virtualxid IS NOT DISTINCT
 FROM blocked_locks.virtualxid
     AND blocking_locks.transactionid IS NOT DISTINCT
 FROM blocked_locks.transactionid
     AND blocking_locks.classid IS NOT DISTINCT
 FROM blocked_locks.classid
     AND blocking_locks.objid IS NOT DISTINCT
 FROM blocked_locks.objid
     AND blocking_locks.objsubid IS NOT DISTINCT
 FROM blocked_locks.objsubid
     AND blocking_locks.pid != blocked_locks.pid
     JOIN pg_catalog.pg_stat_activity blocking_activity
 ON blocking_activity.pid = blocking_locks.pid
 WHERE NOT blocked_locks.GRANTED;
```

5. 进一步使用下面教程的代码来排查问题
   https://www.bilibili.com/video/BV1dy4y1u7Sq/?p=7&spm_id_from=pageDriver&vd_source=63554dc934fc61f53a9594e7bfe32a1b

示例:

```sql
-- a.application_name pg应用程序名,一般是psql
-- relation::regclass: 表名
-- transactionid: 事务id
-- l.mode: 锁的模式
-- l.locktype: 锁的类型
-- l.GRANTED: 锁是否被授权
-- a.query: 锁是否持有或试图获取锁的查询
SELECT a.application_name,
       l.relation::regclass, l.transactionid,
       l.mode,
       l.locktype,
       l.GRANTED,
       a.query,
       a.pid
FROM pg_stat_activity a
         JOIN pg_locks l ON l.pid = a.pid
WHERE a.application_name = 'psql'
ORDER BY a.pid;
```
