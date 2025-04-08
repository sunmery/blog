# TS高级类型

#Typescript #教程
https://juejin.cn/post/6985296521495314445#heading-18

## Pick

语法: `<interface | Type, attr1|attr2>`
参数1: 接口, 类型
参数2: 属性

## Record

```ts
Record<Keys, Type>
```

将一个对象的属性的类型为第二个参数

```ts
type KeyType = 'key1' | 'key2' // 对象的键为其一或者全部, 而ICat的参数则是必须包含
interface ICat = {
	name: string
	age: number
}

const cats: Record<KeyType, ICat> = {
	key1: {
		name: 'cat1',
		age: 2
	}
}
```
