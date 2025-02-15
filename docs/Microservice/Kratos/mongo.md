
conf:
```protobuf

message Data {
  message Mongo {
    string url = 1;
  }
  Mongo mongo = 3;
}

```

yaml:
```yaml
data:
  mongo:
    url: "mongodb://localhost:27017"
```

data
```go
package data

import (
	"backend/application/product/internal/conf"
	"backend/application/product/internal/data/models"
	"context"
	"fmt"
	"github.com/exaring/otelpgx"
	"github.com/go-kratos/kratos/v2/log"
	"github.com/google/wire"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"go.mongodb.org/mongo-driver/mongo/readpref"
	"time"
)

// ProviderSet is data providers.
var ProviderSet = wire.NewSet(NewData, NewMongo)

type Data struct {
	mdb    *mongo.Database
	logger *log.Helper
}

// NewData .
func NewData(
    mdb *mongo.Database,
	logger log.Logger,
) (*Data, func(), error) {
	cleanup := func() {
		log.NewHelper(logger).Info("closing the data resources")
	}
	return &Data{
		logger: log.NewHelper(logger), // 注入日志
		mdb:    mdb,
	}, cleanup, nil
}

// NewMongo 文档数据库
func NewMongo(conf *conf.Data, logger log.Logger) *mongo.Database {
	helper := log.NewHelper(log.With(logger, "module", "user/data/mongo"))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	client, err := mongo.Connect(ctx, options.Client().ApplyURI(conf.Mongo.Url))
	if err != nil {
		helper.Fatalf("failed opening connection to mongo: %v", err)
	}
	err = client.Ping(ctx, readpref.Primary())
	if err != nil {
		helper.Fatal(err)
	}
	return client.Database(conf.Mongo.Database, nil)
}
```