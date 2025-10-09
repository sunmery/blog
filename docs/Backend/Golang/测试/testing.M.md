TestMain 在go test启动之后第一个执行, 用于全局资源管理, 可以在这里初始化数据库, 缓存等供后续的*testing.T函数使用,
这样就不需要再每个*testing.T测试函数重复初始化数据库等耗时操作

```go
package models

import (
	"context"
	"os"
	"testing"

	"log"

	"github.com/exaring/otelpgx"
	"github.com/jackc/pgx/v5/pgxpool"
)

var testQueries *Queries

const connString = "postgresql://postgres:msdnmm@47.119.157.17:5432/postgres?sslmode=disable&timezone=Asia/Shanghai"

func TestMain(m *testing.M) {
	cfg, err := pgxpool.ParseConfig(connString)
	if err != nil {
		log.Fatalf("parse database config failed: %v", err)
	}

	// 连接池设置
	// cfg.MaxConns = c.Database.Pool.MaxConns
	// cfg.MinConns = c.Database.Pool.MinConns
	// cfg.MaxConnLifetime = c.Database.Pool.MaxConnLifetime.AsDuration()
	// cfg.HealthCheckPeriod = c.Database.Pool.HealthCheckPeriod.AsDuration()
	// cfg.MaxConnIdleTime = c.Database.Pool.MaxConnIdleTime.AsDuration()

	// 链路追踪配置
	cfg.ConnConfig.Tracer = otelpgx.NewTracer()
	conn, connErr := pgxpool.NewWithConfig(context.Background(), cfg)
	if connErr != nil {
		log.Fatalf("connect to database: %v", connErr)
	}

	if err := otelpgx.RecordStats(conn); err != nil {
		log.Fatalf("unable to record database stats: %v", err)
	}

	pingErr := conn.Ping(context.Background())
	if pingErr != nil {
		panic(pingErr)
	}

	testQueries = New(conn)
	os.Exit(m.Run())
}

```