## 配置

#工程化
全局配置: 会覆盖`eslintrc`的配置文件
**.editorconfig**

```
[*]
charset = utf-8
indent_style = tab
end_of_line = lf
insert_final_newline = false
trim_trailing_whitespace = true
```

**.eslintrc**

```json
{
  "root": true,
  "env": {
    "node": true,
    "es6": true
  },
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 10,
    "sourceType": "module"
  },
  "ignorePatterns": ["node_modules/*"],
  "extends": [
    "alloy",
    "alloy/react",
    "alloy/typescript",
    // 'plugin:react/recommended',
    "plugin:typescript-enum/recommended"
  ],
  "plugins": [
    "react",
    "react-hooks",
    "react-hooks-addons",
    "simple-import-sort",
    "import",
    "typescript-enum"
  ],
  "globals": {
    "JSX": true,
    "React": true
  },
  "settings": {
    "react": {
      "version": "detect"
    },
    "import/resolver": {
      "typescript": {
        "alwaysTryTypes": true,
        "project": "."
      },
      "node": {
        "paths": ["."]
      }
    }
  },
  "rules": {
    // 文件末尾插入换行符号\n, 这样才符合LF标准，CRLF标准需要去除
    "eol-last": ["error", "always"],
    //		// 设置代码上行与下行最大的空行
    //		"no-multiple-empty-lines": [
    //			"error",
    //			{
    //				"max": 2,
    //				"maxBOF": 1
    //			}
    //		],
    // 可以展开或不展开对象属性
    "object-curly-newline": [
      "error",
      {
        "consistent": true
      }
    ],
    // 对象间距
    "key-spacing": [
      "error",
      {
        "afterColon": true
      }
    ],
    // 引号
    //		"quotes": [
    //			"error",
    //			"single"
    //		],
    // JSX 属性引号 单引号: prefer-single, 双引号: prefer-double
    //		"jsx-quotes": [
    //			"error",
    //			"prefer-double"
    //		],
    // 三元换行 "always" 强制, 与Prettier冲突
    "multiline-ternary": "off",
    // 块状注释之前有一个空行
    "lines-around-comment": [
      "warn",
      {
        "beforeBlockComment": true
      }
    ],
    // 禁止行末尾空格
    "no-trailing-spaces": "error",
    // 禁止块有多余空格
    "no-multi-spaces": "error",
    // 禁止空格与制表符一起使用
    "no-mixed-spaces-and-tabs": "error",
    // 关闭分号
    "semi": ["error", "never"],
    "camelcase": "off",
    // 关闭最大参数的限制
    "max-params": "off",
    // 没有用到的变量, 报警
    "no-unused-vars": "warn",
    "simple-import-sort/imports": "error",
    "simple-import-sort/exports": "error",
    "import/first": "error",
    "import/newline-after-import": "error",
    "import/no-duplicates": "error",
    // 允许 typescript 函数重载
    // 'no-redeclare': 'off',
    // '@typescript-eslint/no-redeclare': ['error'],
    // 位数过多会丢精度
    "@typescript-eslint/no-loss-of-precision": "warn",
    // 优先使用type 而不是interface
    "@typescript-eslint/consistent-type-definitions": ["error", "type"],
    "@typescript-eslint/no-invalid-void-type": 1,
    // 函数组件不允许使用 this
    "react/no-this-in-sfc": "warn",
    // 强制 jsx 一行一个表达式, 除非是纯文字可以不断行, 和 prettier 有冲突
    // 'react/jsx-one-expression-per-line': ['error', { allow: 'literal' }],
    // 强制 react 多 prop 新起一行放置
    "react/jsx-first-prop-new-line": ["error", "multiline"],
    // 强制 jsx 一行最大属性, 超出2个必须关闭perttier singleAttributePerLine选项
    "react/jsx-max-props-per-line": [
      "error",
      {
        "maximum": 2
      }
    ],
    //		// 强制 prop 缩进,启用此项必须关闭prettie useTab选项
    //		"react/jsx-indent-props": [
    //			"off",
    //			2
    //		],
    // 强制 prop 排序
    "react/jsx-sort-props": [
      "error",
      {
        "callbacksLast": true,
        // 回调函数后置
        "shorthandFirst": true,
        // 缩写前置
        "ignoreCase": false,
        // 不允许忽略大小写
        "reservedFirst": true
        // 内置属性(key, ref)前置
      }
    ],
    // 强制尖括号关闭符位置
    "react/jsx-closing-bracket-location": [
      2,
      {
        "nonEmpty": "tag-aligned",
        "selfClosing": "tag-aligned"
      }
    ],
    // 防止在组件内部创建不稳定的组件, 开启 allowAsProps 选项允许 render props 模式
    "react/no-unstable-nested-components": [
      "error",
      {
        "allowAsProps": true
      }
    ],
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",
    "react-hooks-addons/no-unused-deps": "warn"
  },
  "overrides": [
    // 官方推荐ts文件不使用eslint的检查, 因为 no-undef 有bug, 参考:
    // https://stackoverflow.com/questions/65054079/eslint-with-typescript-and-firebase-no-undef-error
    {
      "files": ["**/*.ts", "**/*.tsx"],
      "rules": {
        "no-undef": "off"
      }
    }
  ]
}
```
