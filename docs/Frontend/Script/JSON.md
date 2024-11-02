# JSON对象

#Script

将数组或者对象转成JSON格式

```js
const obj = {
  key:"value"
}

const arr1 = ["books","add"]
const arr2 = [{
  key1:'value1'
}, {
  key2: 'value2'
}]

const objJSON = JSON.stringify(obj) // {"key":"value"}
const arrJSON1 = JSON.stringify(arr1) // ["books","add"]
const arrJSON2 = JSON.stringify(arr2) // [{"key1":"value1"},{"key2":"value2"}]
```

将JSON序列化对象转成普通数组或者对象

```js
const arrJSON = '[{ "key1": "value2" }, { "key2": "value2" }]'
const objJSON = '{"key1":"value1"}'

const arr = JSON.parse(arrJSON) // [ { key1: 'value2' }, { key2: 'value2' } ]
const obj = JSON.parse(objJSON) // { key1: 'value1' }
```