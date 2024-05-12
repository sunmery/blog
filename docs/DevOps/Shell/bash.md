1. **数字比较**：
    
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