# Array

#Script

- concat() 拼接两个字符

```js
let arr1 = [1]
let arr2 = [2]

let arr3 = arr1.concat(crr2) // [1,2]
let arr4 = arr3.concat([3]) // [1,2,3]
```

更优方法:

```js
let arr1 = [1]
let arr2 = [2]
let arr3 = [...arr1, ...arr2]
let arr4 = [...arr3, 3]
```

Array.flat 数组扁平化

```ts
let arr = [1,[2],[3]]
  
function floatten(arr){
    return arr.flat(Infinity)
}

console.log(floatten(arr))
```