## 解析命令行参数

`getopts`只能处理单个字符的选项

```bash
while getopts n:c: flag
  do
      case "${flag}" in
          install)
            install=true
            ;;
          version)
            version=${OPTARG}
            ;;
          url)
            url=${OPTARG}
            ;;
          *)
            echo "未知的命令行选项参数"
            exit 1
            ;;
      esac
  done
```

## 判断

-v: 检查变量是否已经被定义（不论其值是否为空）

```bash
if [[ -v $var1 ]] && [[ -v $var2 ]];
  echo "变量已经被定义"
fi
```

-n: 测试字符串是否为非空, 非空则为true

```bash
if [[ -n $var1 && $var2 ]]
```

-z: 测试字符串是否为空

```bash
if [[ -z $var1 && $var2 ]]
```

3. **数字比较**：

    - `-eq`：等于
    - `-ne`：不等于
    - `-gt`：大于
    - `-lt`：小于
    - `-ge`：大于等于
    - `-le`：小于等于

   例如：

   bash复制代码

   `if [ $num1 -eq $num2 ]; then     echo "Numbers are equal" fi`

2. **字符串比较**：

    - `=`：相等
    - `!=`：不相等
    - `-z`：长度为零（空字符串）
    - `-n`：长度非零（非空字符串）

   例如：

   bash复制代码

   `if [ "$str1" = "$str2" ]; then     echo "Strings are equal" fi`

3. **文件测试**：

    - `-e`：文件存在
    - `-f`：普通文件存在
    - `-d`：目录存在
    - `-r`：可读
    - `-w`：可写
    - `-x`：可执行

   例如：

   bash复制代码

   `if [ -e "$file" ]; then     echo "File exists" fi`

4. **逻辑运算**：

    - `&&`：与
    - `||`：或
    - `!`：非

   例如：

   bash复制代码

   `if [ "$condition1" = "true" ] && [ "$condition2" = "true" ]; then     echo "Both conditions are true" fi`
