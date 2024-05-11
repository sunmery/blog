## 介绍
与数据结构的队列相同, 先进先出, 如果没有值就使用与内容超出容量长度会报错

## 读写权限
- 只读

关键字: `chan<-`

语法: 
1. 定义 `var chan_variable = chan<- `\<Type\>`
2. 初始化: `var chan_variable = make(chan\<- \<Type\>, \<Size\>)`

例子:
```go
var chan1 chan<- int // 定义未初始化
var chan1 = make(chan<- int, 10, 10) // 初始化
func main { // 简短的初始化
	chan1 := make(chan<- int, 10, 10)
}
```

- 只写

关键字: `<-chan
`
语法: 
1. 定义 `var chan_variable = <-chan `\<Type\>`
2. 初始化: `var chan_variable = make(\<-chan \<Type\>, \<Size\>)`

例子:
```go
var chan2 <- chan int
var chan2 = make(<-chan int, 10)
func main {
	chan2 := make(<- chan int, 10)
}
```

## 取值
- 循环
1. `for i`
```go
var chan3 = make(chan int,10)

chan3 <- 20
for i := 0; i < len(chan3); i++ {
	fmt.Println(<-chan3)
}
```

2. `for range`
```go
var chan4 = make(chan int,10)
chan4 <- 20

for value := range {
	fmt.Println(<-chan4)
}
```

## 阻塞
管道如果只写入, 但不读取的情况下, 会抛出异常: `fatal error: all goroutines are asleep - deadlock!`(致命错误:所有的goroutine都睡着了-死锁!)

解决方案: 写入必须读取
