# 快捷键

#教程 #快捷键

`Ctrl + [`  跳到该标签/对象的开始位置
`Ctrl + ]` 跳到该标签/对象的结束位置
`Ctrl + Down` 下移行
`Ctrl + Up` 上移行
`Ctrl + N` 新建目录

Ctrl + E 查看最近文件

Alt + Enter 正则表达式校验

`Alt + H` 新建HTML文件
`Alt + C` 新建样式文件
`Alt + T` 新建Typescript文件
`Alt + V` 新建Vue文件

Alt + F7 查看代码逻辑用途

### 4.5 其他超级快捷键

1. `command/ctrl + option/alt + O`：import 优化，移除没用到的 import
2. `command/ctrl + option/alt + L`：重新格式化代码
3. `command/ctrl + option/alt + Z`：Git 回滚当前区域的代码
4. `command/ctrl + J`：查看预定义代码模板
5. `command/ctrl + shift + up/down`：智能移动代码块，如果移动函数，可以将这个函数整体移动到上一个函数上
6. `control/ctrl + shift + J`：合并两行
7. `command/ctrl + G`：选择下一个相同匹配项
8. `command/ctrl + D`：复制当前行
9. `F2`：导航到编辑器报错或者报警告的地方

配置`版权`信息

1. 编辑器->版权
2. 编辑版权

变量表

| 变量                       | 类型       | 描述                                                         |
| :------------------------- | ---------- | ------------------------------------------------------------ |
| `$today`                   | `DateInfo` | 当前日期和时间。                                             |
| `$file.fileName`           | `String`   | 要在其中生成通知的当前打开的文件的名称。                     |
| `$file.pathName`           | `String`   | 要在其中生成通知的当前打开的文件的完整路径和名称。           |
| `$file.className`          | `String`   | 当前打开的要在其中生成通知的 Java 文件的名称。               |
| `$file.qualifiedClassName` | `String`   | 要在其中生成通知的当前打开的文件的完全限定名。               |
| `$file.lastModified`       | `DateInfo` | 上次更改当前文件的日期和时间。                               |
| `$project.name`            | `String`   | 当前项目的名称。                                             |
| `$username`                | `String`   | 当前用户的名称。                                             |
| `DateInfo`具有以下属性：   |            |                                                              |
| `year`                     | `int`      | 本年度。                                                     |
| `month`                    | `int`      | 当前月份 （1-12）.                                           |
| `day`                      | `int`      | 当前月份的日期 （1-31）。                                    |
| `hour`                     | `int`      | 当前小时 （0-11）。                                          |
| `hour24`                   | `int`      | 当前小时 （0-23）。                                          |
| `minute`                   | `int`      | 小时的当前分钟 （0-59）。                                    |
| `second`                   | `int`      | 当前分钟秒 （0-59）。                                        |
| `DateInfo`具有以下方法：   |            |                                                              |
| `format(String format)`    | `String`   | 由日期和时间模式字符串指定的*日期和时间*格式。请参阅 java.text.SimpleDateFormat 格式选项。 |

## 实时模板变量中使用的函数

以下函数可用于定义实时模板变量：

| 功能                                                    | 描述                                                         |
| ------------------------------------------------------- | ------------------------------------------------------------ |
| `blockCommentEnd()`                                     | 返回指示当前语言上下文中块注释结尾的字符。                   |
| `blockCommentStart()`                                   | 返回指示当前语言上下文中块注释的开头的字符。                 |
| `camelCase(<String>)`                                   | 将字符串转换为*驼峰大小写*。例如，、 和 全部返回 。`camelCase("my-text-file")``camelCase("my text file")``camelCase("my_text_file")``myTextFile` |
| `capitalize(<String>)`                                  | 将字符串的第一个字母大写。例如，返回 .或者，您可以将其组合成.`capitalize("name")``Name``capitalize(camelCase("my awesome class"))``MyAwesomeClass` |
| `capitalizeAndUnderscore(<String>)`                     | 将字符串的所有字母大写，并在各部分之间插入下划线。例如，、 和 全部返回 。`capitalizeAndUnderscore("FooBar")``capitalizeAndUnderscore("foo bar")``capitalizeAndUnderscore("foo-bar")``FOO_BAR` |
| `clipboard()`                                           | 返回系统剪贴板的内容。                                       |
| `commentEnd()`                                          | 返回指示当前语言上下文中注释结尾的字符。对于带有行注释的语言，返回值为空。 |
| `commentStart()`                                        | 返回指示当前语言上下文中注释开头的字符。对于具有行注释的语言，返回值是行注释的开头，与 [lineCommentStart（） 相同](https://www.jetbrains.com/help/webstorm/template-variables.html#lineCommentStart)。 |
| `complete()`                                            | 在变量的位置调用[代码完成](https://www.jetbrains.com/help/webstorm/auto-completing-code.html#basic_completion)。 |
| `concat(<String>, ...)`                                 | 返回作为参数传递给函数的所有字符串的串联。例如，返回以空格分隔的当前系统日期和用户名。`concat(date()," ",user())` |
| `dartIterableVariable()`                                | 返回可以迭代的变量的名称。                                   |
| `dartListVariable()`                                    | 返回数组元素的列表。                                         |
| `dartSuggestIndexName()`                                | 从最常用的索引变量、、 和 son on 中返回索引变量的建议名称。首先显示当前作用域中尚未使用的名称。`i``j``k` |
| `dartSuggestVariableName()`                             | 根据变量命名规则的代码样式设置，根据变量类型和初始值设定项表达式返回变量的建议名称。例如，如果它是一个在迭代中保存元素的变量，WebStorm 会根据迭代的容器的名称，对最合理的名称进行猜测。 |
| `date([format])`                                        | 返回当前系统日期。默认情况下，如果不带参数，它将以当前系统格式返回日期。若要使用不同的格式，请根据 [SimpleDateFormat](https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html) 规范提供一个参数。例如，返回格式为 的日期。`date("Y-MM-d, E, H:m")``2020-02-27, Thu, 16:11` |
| `dbColumns()`                                           | 返回表或视图的列列表。用于上下文实时模板（例如，）。您可以通过右键单击对象并选择 SQL 脚本来访问上下文实时模板。`dbColumns()``ins` |
| `dbObjectName()`                                        | 返回表或视图的名称。用于上下文实时模板（例如，）。您可以通过右键单击对象并选择 SQL 脚本来访问上下文实时模板。`dbObjectName()``top` |
| `decapitalize(<String>)`                                | 将字符串的第一个字母替换为相应的小写字母。例如，返回 .`decapitalize("Name")``name` |
| `defaultReturnValues`                                   | 如果在 return 语句中使用了表达式，则返回默认值。如果表达式属于错误类型，则使用该参数。`errorVariableName` |
| `enum(<String>, ...)`                                   | 返回模板展开时建议完成的字符串列表。例如，显示一个列表，您可以从中选择一个指定的字符串。`enum("Foo","Bar","Baz")` |
| `escapeString(<String>)`                                | 转义特殊字符，以便可以在 Java 字符串中使用结果。例如，它将制表符替换为 、换行符替换为 、将反斜杠转义为 、引号为 等。`\t``\n``\\``\"` |
| `expectedType()`                                        | 返回模板展开的表达式的预期类型（在赋值的右侧，在 之后，作为方法参数，依此类推）。`return` |
| `fileName()`                                            | 返回当前文件的名称及其扩展名。                               |
| `fileNameWithoutExtension()`                            | 返回当前文件的名称，不带其扩展名。                           |
| `filePath()`                                            | 返回当前文件的绝对路径。                                     |
| `fileRelativePath()`                                    | 返回相对于当前项目的当前文件路径。要检查给定文件的相对路径，请右键单击该文件并选择“复制引用”，或按 。Ctrl+Alt+Shift+C |
| `firstWord(<String>)`                                   | 返回作为参数传递的字符串的第一个单词。例如，返回 .`firstWord("one two three")``one` |
| `groovyScript(<String>, [arg, ...])`                    | 执行作为字符串传递的 Groovy 脚本。第一个参数是一个字符串，其中包含脚本的文本或包含脚本的文件的路径。该函数将其他可选参数作为 、 ... 、 变量的值传递给脚本。此外，您还可以使用变量从脚本内部访问当前编辑器。`_1``_2``_3``_n``_editor`下面的示例演示一个函数，该函数将所选文本拆分为单词，并将其显示为编号列表：`groovyScript()``groovyScript("def result = ''; _1.split().eachWithIndex { item, index -> result = result + index.next() + '. ' + item + System.lineSeparator() }; return result;", SELECTION);` |
| `JsArrayVariable()`                                     | 返回当前 JavaScript 数组的名称。                             |
| `jsClassName()`                                         | 返回当前 JavaScript 类的名称。                               |
| `jsComponentTypeOf()`                                   | 返回当前 JavaScript 组件的类型。                             |
| `jsDefineParameter`                                     | 根据模块的名称，从 返回参数。`define(["module"], function (<parameter_in_question>>) {})` |
| `jsMethodName()`                                        | 返回当前 JavaScript 方法的名称。                             |
| `jsQualifiedClassName()`                                | 返回当前 JavaScript 类的完整名称。                           |
| `jsSuggestDefaultVariableKind(Boolean)`                 | 布尔参数确定在当前上下文中是否允许常量。如果未指定参数，则允许使用常量。当模板展开时，将显示一个列表，其中包含 、、TypeScript 和 ES6 选项，对于早期 JavaScript 版本，只有一个选项。`var``let``const``var` |
| `jsSuggestImportedEntityName()`                         | 建议导入语句的类型名称或基于文件名的名称。``import * as $ITEM$ from "$MODULE$"````import $ITEM$ from "$MODULE$"`` |
| `jsSuggestIndexName()`                                  | 从最常用的索引变量、、 和 son on 中返回索引变量的建议名称。首先显示当前作用域中尚未使用的名称。`i``j``k` |
| `jsSuggestVariableName()`                               | 根据变量命名规则的代码样式设置，根据变量类型和初始值设定项表达式返回变量的建议名称。例如，如果它是一个在迭代中保存元素的变量，WebStorm 会根据迭代的容器的名称，对最合理的名称进行猜测。 |
| `lineCommentStart()`                                    | 返回指示当前语言上下文中行注释开头的字符。                   |
| `lineNumber()`                                          | 返回当前行号。                                               |
| `lowercaseAndDash(<String>)`                            | 将字符串转换为小写，并插入 n 短划线作为分隔符。例如，并且两者都返回 .`lowercaseAndDash("MyExampleName")``lowercaseAndDash("my example name")``my-example-name` |
| `regularExpression(<String>, <Pattern>, <Replacement>)` | 查找 中出现的所有 和，并将它们替换为 。您可以将模式指定为正则表达式，以查找字符串中与其匹配的所有内容。`Pattern``String``Replacement` |
| `snakeCase(<String>)`                                   | 将字符串转换为*snake_case*。例如，并且两者都返回 .`snakeCase("fooBar")``snakeCase("foo bar")``foo_bar` |
| `spaceSeparated(<String>)`                              | 返回以空格分隔符的指定字符串。例如，返回和返回 。`spaceSeparated("fooBar")``foo Bar``spaceSeparated("Foo_BAR")``Foo BAR` |
| `spacesToUnderscores(<String>)`                         | 将作为参数传递的字符串中的下划线替换空格。例如，返回 .`spacesToUnderscores("foo bar BAZ")``foo_bar_BAZ` |
| `substringBefore(<String>, <Delimeter>)`                | 返回指定分隔符的子字符串。这对于删除测试文件名中的扩展名很有帮助。例如，如果在名为 **component-test.js** 的文件中使用，则返回。`substringBefore(fileName(),".")``component-test` |
| `time([format])`                                        | 返回当前系统时间。默认情况下，如果没有参数，它将以当前系统格式返回时间。若要使用不同的格式，请根据 [SimpleDateFormat](https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html) 规范提供一个参数。例如，返回格式为 的时间。`time("H:m z")``13:10 UTC` |
| `underscoresToCamelCase(<String>)`                      | 将带有下划线（如*snake_case*）的字符串转换为*驼峰大小写*。例如，并且两者都返回 .`underscoresToCamelCase(foo_bar_baz)``underscoresToCamelCase(FOO_BaR_baZ)``fooBarBaz` |
| `underscoresToSpaces(<String>)`                         | 将字符串中的下划线转换为空格。例如，返回和返回 。`underscoresToSpaces(foo_bar_baz)``foo bar baz``underscoresToSpaces(FOO_BaR_baZ)``FOO BaR baZ` |
| `user()`                                                | 返回当前用户的名称。                                         |

https://juejin.cn/post/7067703148734840869