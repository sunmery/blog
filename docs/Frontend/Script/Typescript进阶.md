从类型中选取某一个

```ts

```

ts对象的类型为枚举中的类型
```ts
enmu EnhanceKeyValue = {
	key1 = 'key'
}

type EnhanceKeyValue = {
	[key in keyof typeof EnhanceKey]?: string;
}

const test: EnhanceKeyValue {} //属性为EnhanceKeyValue的值
```