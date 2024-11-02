## Client

**使用`React.js`框架来封装加密解密方法**

```ts
export function encrypt (word: string) {
	const encrypt = crypto.AES.encrypt(word,key,{
		mode: crypto.mode.ECB,
		padding: crypto.pad.Pkcs7
	})

	return encrypt.toString()
}
```

## Server

**使用`Nest.js`框架来封装加密解密方法**

## 参考

1. [CSDN](https://blog.csdn.net/l1134/article/details/123728649)
2. [简书](https://www.jianshu.com/p/56384997e9c8)
3. [Node](https://www.nodeapp.cn/crypto.html#crypto_crypto_publicencrypt_key_buffer)
