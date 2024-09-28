https://github.com/jackc/pgx/wiki/Error-Handling

```go
// Be sure the correct package is imported, this will not work if the old, standalone pgconn repo is imported instead.
import "github.com/jackc/pgx/v5/pgconn"

// ...

err = conn.QueryRow(context.Background(), "select 1 +").Scan(&greeting)
if err != nil {
  var pgErr *pgconn.PgError
  if errors.As(err, &pgErr) {
    fmt.Println(pgErr.Message) // => syntax error at end of input
    fmt.Println(pgErr.Code) // => 42601
  }
}
```

示例:
```go
account, err := s.store.CreateAccount(ctx, arg)
	if err != nil {
		var pgErr *pgconn.PgError
		if errors.As(err, &pgErr) {
			fmt.Printf("postgres sql err message is '%s' \n", pgErr.Message)
			fmt.Printf("postgres sql err code is '%s' \n", pgErr.Code)

			switch pgErr.Code {
			case "23503":
				ctx.JSON(http.StatusForbidden, gin.H{
					"error": pgErr.Error(),
				})
				return
			case "23505":
				ctx.JSON(http.StatusForbidden, gin.H{
					"error": pgErr.Error(),
				})
				return
			}
		}
		ctx.JSON(http.StatusInternalServerError, errorResponse(err))
		return
	}
```