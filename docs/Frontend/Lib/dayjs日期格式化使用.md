# 基本使用

1. 导入

```ts
import * as moment from 'moment'
```

2. 导入本地日期

语法：`import 'moment/local/<city>`, 将`city`替换为地区，此处为中国大陆

```ts
import 'moment/local/zh-cn'
```

3. 设置本地日期
   语法：`moment.local('<city>')`, 将`city`替换为地区，此处为中国大陆

```ts
moment.local('zh-cn')
```

## 常见指令

### 解析日期

- 解析

```ts
moment('日期')
```

- 格式化日期
  关键字： `format()`

```ts
moment('日期').format()
```

#### （2）获取今天0时0分0秒

```js
moment().startOf('day')
```

#### （3）获取本周第一天(周日)0时0分0秒

```js
moment().startOf('week')
```

#### （4）获取本周周一0时0分0秒

```js
moment().startOf('isoWeek')
```

#### （5）获取当前月第一天0时0分0秒

```js
moment().startOf('month')
```

#### （6）获取今天23时59分59秒

```js
moment().endOf('day')
```

#### （7）获取本周最后一天(周六)23时59分59秒

```js
moment().endOf('week')
```

#### （8）获取本周周日23时59分59秒

```js
moment().endOf('isoWeek')
```

#### （9）获取当前月最后一天23时59分59秒

```js
moment().endOf('month')
```

#### （10）获取当前月的总天数

```js
moment().daysInMonth() 
```

#### （11）获取时间戳(以秒为单位)

```js
moment().format('X') // 返回值为字符串类型
moment().unix() // 返回值为数值型
```

#### （12）获取时间戳(以毫秒为单位)

```js
moment().format('x') // 返回值为字符串类型
moment().valueOf() // 返回值为数值型
```

#### （13）获取年份

```js
moment().year()
moment().get('year')
```

#### （14）获取月份

```js
moment().month()  // (0~11, 0: January, 11: December)
moment().get('month')
```

#### （15）获取一个月中的某一天

```js
moment().date()
moment().get('date')
```

#### （16）获取一个星期中的某一天

```js
moment().day() // (0~6, 0: Sunday, 6: Saturday)
moment().weekday() // (0~6, 0: Sunday, 6: Saturday)
moment().isoWeekday() // (1~7, 1: Monday, 7: Sunday)
moment().get('day')
mment().get('weekday')
moment().get('isoWeekday')
```

#### （17）获取小时

```js
moment().hours()
moment().get('hours')
```

#### （18）获取分钟

```js
moment().minutes()
moment().get('minutes')
```

#### （19）获取秒数

```js
moment().seconds()
moment().get('seconds')
```

#### （20）获取当前的年月日时分秒

```js
moment().toArray() // [years, months, date, hours, minutes, seconds, milliseconds]
moment().toObject() // {years: xxxx, months: x, date: xx ...}
```

### 设置日期

#### （1）设置年份

```js
moment().year(2019)
moment().set('year', 2019)
moment().set({year: 2019})
```

#### （2）设置月份

```js
moment().month(11)  // (0~11, 0: January, 11: December)
moment().set('month', 11) 
```

#### （3）设置某个月中的某一天

```js
moment().date(15)
moment().set('date', 15)
```

#### （4）设置某个星期中的某一天

```js
moment().weekday(0) // 设置日期为本周第一天（周日）
moment().isoWeekday(1) // 设置日期为本周周一
moment().set('weekday', 0)
moment().set('isoWeekday', 1)
```

#### （5）设置小时

```js
moment().hours(12)
moment().set('hours', 12)
```

#### （6）设置分钟

```js
moment().minutes(30)
moment().set('minutes', 30)
```

#### （7）设置秒数

```js
moment().seconds(30)
moment().set('seconds', 30)
```

#### （8）年份+1

```js
moment().add(1, 'years')
moment().add({years: 1})
```

#### （9）月份+1

```js
moment().add(1, 'months')
```

#### （10）日期+1

```js
moment().add(1, 'days')
```

#### （11）星期+1

```js
moment().add(1, 'weeks')
```

#### （12）小时+1

```js
moment().add(1, 'hours')
```

#### （13）分钟+1

```js
moment().add(1, 'minutes')
```

#### （14）秒数+1

````js
moment().add(1, 'seconds')
#### （15）年份-1
```js
moment().subtract(1, 'years')
moment().subtract({years: 1})
````

#### （16）月份-1

```js
moment().subtract(1, 'months')
```

#### （17）日期-1

```js
moment().subtract(1, 'days')
```

#### （18）星期-1

```js
moment().subtract(1, 'weeks')
```

#### （19）小时-1

```js
moment().subtract(1, 'hours')
```

#### （20）分钟-1

```js
moment().subtract(1, 'minutes')
```

#### （21）秒数-1

```js
moment().subtract(1, 'seconds')
```