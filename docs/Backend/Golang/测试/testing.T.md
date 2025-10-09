使用`"github.com/stretchr/testify/assert"`包方便测试, 使用它即可减少if err != nil等样板代码, 增加阅读性

```go
package models

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestGetUsername(t *testing.T) {
	arg := "admin"

	result, err := testQueries.GetUsername(context.Background(), arg)
	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.NotEmpty(t, result)
	t.Log(result)
}

func TestInsertTestUser(t *testing.T) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	result, err := testQueries.InsertTestUser(ctx)
	assert.NoError(t, err)
	assert.NotNil(t, result)
	assert.NotEmpty(t, result)
	t.Log(result)
}

```