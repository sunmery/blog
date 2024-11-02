## 作用
操作`channel`管道专用, 与`Switch`语法差不多, 但有区别:
1. case 参数语句必须是`IO`操作, 不能是`=`赋值
2. secect是随机选择`IO`操作执行(一般选择执行时间最短的case)

语法:
```go
select {
	case case1: // code 
	case case2: // code 
	default:  // code 
}
```

例子: 随机对某个`channel`管道执行
```go
package main

import (
	"fmt"
	"time"
)

func main() {
	chan4 := make(chan int, 10)
	chan5 := make(chan string, 10)

	go intChan(chan4, 12)
	go strChan(chan5, "1231")

	select {
	case v := <-chan4: // 必须是IO操作语句
		fmt.Println(v)
	case v := <-chan5: // 必须是IO操作语句
		fmt.Println(v)
	}
}
func intChan(ch chan int, arg int) {
	time.Sleep(time.Second * 2)
	ch <- arg
}

func strChan(ch chan string, arg string) {
	time.Sleep(time.Second * 4)
	ch <- arg
}
```