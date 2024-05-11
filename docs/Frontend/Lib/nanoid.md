# nanoid

[Github](https://github.com/ai/nanoid/blob/HEAD/README.zh-CN.md)

不建议使用在列表项的key中,影响性能: 查找时会很慢(重新查找),增删时而不重新渲染

## 使用

```shell
pnpm i nanoid
```

1. 导入
    ```js
    import {nanoid} from 'nanoid'
    ```
2. 使用随机数
    ```js
    const id = nanoid()
    
    const obj = {
        id: Symbol(id)
    }
    ```

3. 使用固定生成随机数

```js
const id = nanoid(10)
```