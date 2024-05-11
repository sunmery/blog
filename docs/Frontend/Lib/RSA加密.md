#Node 

使用`Node`的`crypto`库实现

1. 生成RSA加密算法所需的`私钥`与`公钥`

生成RSA密钥，加密方式指定为AES256，生成的RSA的密钥长度是2048位, 生成的文件在`C:\Users\<Username>`下
```bash
openssl genrsa -aes256 -out rsa-key.pem 2048
```

2. 导出原始的`私钥`:

```bash
openssl rsa -in rsa-key.pem -outform PEM -out rsa-prv.pem
```

3. 导出原始的`公钥`：

```bash
openssl rsa -in rsa-key.pem -outform PEM -pubout -out rsa-pub.pem
```

4. 加密

> `ts`文件的导入方式是 `import * as crypto form 'node:crypto'`

- 使用私钥加密, 公钥解密
```js
const
    fs = require('fs'),
    crypto = require('node:crypto');

// 从文件加载key:
function loadKey(file) {
    // key实际上就是PEM编码的字符串:
    return fs.readFileSync(file, 'utf8');
}

let
    prvKey = loadKey('./rsa-prv.pem'), // 私钥文件位置 rsa-prv.pem
    pubKey = loadKey('./rsa-pub.pem'), // 公钥文件位置 rsa-prv.pem
    message = 'Hello, world!'; // 需要加密的字段

// 使用私钥加密:
let enc_by_prv = crypto.privateEncrypt(prvKey, Buffer.from(message, 'utf8'));
console.log('encrypted by private key: ' + enc_by_prv.toString('hex'));

// 使用公钥解密:
let dec_by_pub = crypto.publicDecrypt(pubKey, enc_by_prv);
console.log('decrypted by public key: ' + dec_by_pub.toString('utf8'));
```

- 使用公钥加密，私钥解密：
```js
// 使用公钥加密:
let enc_by_pub = crypto.publicEncrypt(pubKey, Buffer.from(message, 'utf8'));
console.log('encrypted by public key: ' + enc_by_pub.toString('hex'));

// 使用私钥解密:
let dec_by_prv = crypto.privateDecrypt(prvKey, enc_by_pub);
console.log('decrypted by private key: ' + dec_by_prv.toString('utf8'));
```

## 参考文章

[廖雪峰](https://www.liaoxuefeng.com/wiki/1022910821149312/1023025778520640)