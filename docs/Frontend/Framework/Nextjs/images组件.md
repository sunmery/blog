svg

```
images: {  
    dangerouslyAllowSVG: true,  
    contentSecurityPolicy: 'default-src \'self\'; script-src \'none\'; sandbox;',
//    domains: [process.env.STATIC_PUBLIC],  
  },
```

域:
不加`https`/`http`前缀

```ts
images:{
 domains: ['<IP>']
}
```