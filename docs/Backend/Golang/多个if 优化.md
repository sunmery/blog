
没优化之前: 嵌套if, 检查是否有中文字段值, 否则去查找英文值, 都没有则返回默认值
```go
if record.City.Names["zh-CN"] == "" {
	city = record.City.Names["en"]
	if record.City.Names["en"] == "" {
		city = record.City.Names["en"]
	}
} else {
	city = "未知地域"
}
```

优化后: 平级if..else代替嵌套if
```go
if name, ok := record.City.Names["zh-CN"]; ok {
	city = name
} else if city, ok = record.City.Names["en"]; ok {
	city = record.City.Names["en"]
} else {
	city = "未知地域"
}
```

知识点: 利用go的`ok`模式,对查询`map`对象的值是否存在更加简洁和安全

更进一步的优化, 去掉else
> 这对else的处理逻辑有明确的值时非常有用

```go
city = "未知地域"
if name, ok := record.City.Names["zh-CN"]; ok {
	city = name
} else if name, ok = record.City.Names["en"]; ok {
	city = name
}
```

使用switch代替多个if分支: 根据成绩的分数段给出对应的等级
```go
func calculateGrade(score int) string {
	var grade string

	if score >= 90 && score <= 100 {
		grade = "A"
	} else if score >= 80 && score < 90 {
		grade = "B"
	} else if score >= 70 && score < 80 {
		grade = "C"
	} else if score >= 60 && score < 70 {
		grade = "D"
	} else if score >= 0 && score < 60 {
		grade = "F"
	} else {
		grade = "Invalid Score"
	}

	return grade
}
```

优化后: 使代码更加简洁，并且避免了多个嵌套的 `if-else` 语句。同时，使用 `switch` 语句还能够处理默认情况，即当 `score` 不满足任何一个分支条件时，默认返回 "Invalid Score"
```go
func calculateGrade(score int) string {
	var grade string

	switch {
	case score >= 90 && score <= 100:
		grade = "A"
	case score >= 80 && score < 90:
		grade = "B"
	case score >= 70 && score < 80:
		grade = "C"
	case score >= 60 && score < 70:
		grade = "D"
	case score >= 0 && score < 60:
		grade = "F"
	default:
		grade = "Invalid Score"
	}

	return grade
}
```

错误检查

首先看`etcd`github官网的错误处理[例子](https://github.com/etcd-io/etcd/tree/main/client/v3#error-handling):
```go
resp, err := cli.Put(ctx, "", "")
if err != nil {
	switch err {
	case context.Canceled:
		log.Fatalf("ctx is canceled by another routine: %v", err)
	case context.DeadlineExceeded:
		log.Fatalf("ctx is attached with a deadline is exceeded: %v", err)
	case rpctypes.ErrEmptyKey:
		log.Fatalf("client-side error: %v", err)
	default:
		log.Fatalf("bad cluster endpoints, which are not etcd servers: %v", err)
	}
}
```

我们可以进一步优化, 使用`go`自带的包`errors`对错误类型进行更加健壮的检查, 但是对开发者的要求较高, 需要预定义正确的错误类型, 来保证正确的比较错误

```go
resp, err := cli.Put(ctx, "", "")
if err2 != nil {
		switch {
		case errors.Is(err, context.Canceled):
			log.Fatalf("ctx is canceled by another routine: %v", err)
		case errors.Is(err, context.DeadlineExceeded):
			log.Fatalf("ctx is attached with a deadline is exceeded: %v", err)
		case errors.Is(err, rpctypes.ErrEmptyKey):
			log.Fatalf("client-side error: %v", err)
		default:
			log.Fatalf("bad cluster endpoints, which are not etcd servers: %v", err)
		}
	}
```