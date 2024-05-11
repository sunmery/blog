问题: 不是序列化的字符串

解决方案:
取消对其检查

```ts
middleware: (getDefaultMiddleware) => getDefaultMiddleware({
    serializableCheck: false,
  })
```