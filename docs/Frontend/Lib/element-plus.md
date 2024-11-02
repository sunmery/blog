# Element-Plus

#Lib #Element-Plus

## 解决vite + typescript 打包问题

方法1: --skipLibCheck 参数

> package.json

```
"scripts": {
    "build": "vue-tsc --noEmit --skipLibCheck && vite build",
  },
```

方法2:

> tsconfig.json

```
"skipLibCheck": true,
```