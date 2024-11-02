#工程化

## 配置

**.prettierrc.js** 格式化文件配置

```json
module.exports = {
	// 当箭头函数的参数只有一个时，参数使用小括号包裹
	'arrowParens': 'always',
	// 打印对象字面量中括号之间的空格。
	'bracketSpacing': true,
	// 是否将具有多行元素的>放在最后一行的末尾，还是单独放在下一行
	'bracketSameLine': false,
	// 是否将JSX中具有多行元素的>放在最后一行的末尾，还是是单独放在下一行
	'jsxBracketSameLine': false,
	// 行结束符
	'endOfLine': 'auto',
	// 是否打印分号
	'semi': false,
	// html中对于空格的处理方式
	'htmlWhitespaceSensitivity': 'css',
	// 是否在文件顶部插入@format标记
	'insertPragma': false,
	// 指定超过该最大长度时，prettier换行。
	'printWidth': 80,
	// 属性换行方式
	'proseWrap': 'preserve',
	// 对象中的属性名如何添加引号
	'quoteProps': 'preserve',
	// 是否在文件开头有@prettier或者@format才格式化该文件
	'requirePragma': false,
	// 是否使用单引号替代双引号
	'singleQuote': true,
	// jsx中哦哦那个是否使用单引号替代双引号
	'jsxSingleQuote': false,
	// 指定Tab的空格数
	'tabWidth': 2,
	// 多属性换行
	'singleAttributePerLine': true,
	// 是否使用tab进行缩进，而不是使用空格
	'useTabs': true,
	// 打印结尾分号
	'trailingComma': 'all',
	// import 导入顺序
	'importOrder': [
		'^(^react$|^@react|^react|^recoil|redux|vite)',
		'^(^antd|^rsuite|^@emotion|^emotion|theme-ui|^semantic-ui|^@rebass|^@chakra-ui|bootstrap|tailwind|bulma|mui|^@blueprintjs|reactstrap|^@mantine)',
		'<THIRD_PARTY_MODULES>',
		'^@(.*)$',
		'^~(.*)$',
		'^[./]',
	],
	// 是否将命名空间导入说明符放到导入分组的最前面
	'importOrderGroupNamespaceSpecifiers': true,
	// 对导入的包不同分类中间是否添加空格
	'importOrderSeparation': true,
	// 对导入的同一个包中的说明符是否排序
	'importOrderSortSpecifiers': true,
}

```

**.prettierignore** 不进行格式化的文件

```
# Ignore all files:
*.html
*.ejs
*.mdx
*.md
/dist/*
.local
/node_modules/**

**/*.svg
**/*.sh
/public/*
```
