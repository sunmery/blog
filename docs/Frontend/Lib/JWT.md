## 用法

**jwt.sign(payload， secretOrPrivateKey， [options， callback])**

1. payload: **string**
   需要加密的字段, 例如从数据库请求的用户名`profile['username']`

2. secretOrPrivateKey: **string**
   密钥,`express-jwt`生成或者自己写的的字符串

3. secretOrPrivateKey: **string | object**
    - options: **{}**
        - `algorithm`: **string** 使用的加密算法
          algorithm参数值 | 数字签名
          ---|--|---
          HS256 | 使用 SHA-256 哈希算法的 HMAC
          HS384系列 | 使用 SHA-384 哈希算法的 HMAC
          HS512系列|使用 SHA-512 哈希算法的 HMAC
          RS256|使用 SHA-256 哈希算法的 RSASSA-PKCS1-v1_5
          RS384|使用 SHA-384 哈希算法的 RSASSA-PKCS1-v1_5
          RS512|使用 SHA-512 哈希算法的 RSASSA-PKCS1-v1_5
          PS256系列|使用 SHA-256 哈希算法的 RSASSA-PSS（仅Node ^6.12.0 或 >=8.0.0）
          PS384系列|使用 SHA-384 哈希算法的 RSASSA-PSS（仅Node ^6.12.0 或 >=8.0.0）
          PS512系列|使用 SHA-512 哈希算法的 RSASSA-PSS（仅Node ^6.12.0 或 >=8.0.0）
          ES256系列|使用P-256曲线和SHA-256哈希算法的ECDSA
          ES384系列|ECDSA使用P-384曲线和SHA-384哈希算法
          ES512系列|ECDSA使用P-521曲线和SHA-512哈希算法
          没有|不包含数字签名或 MAC 值
        - `expiresIn`: **string** 过期时间之后. 以秒或描述时间跨度[zeit/ms](https://github.com/zeit/ms)的字符串表示
            - 1ms 毫秒
            - 1s 秒
            - 1h 时
            - 3d 天
            - 40 * 40 表示40秒乘以40秒
        - `notBefore`: **string** 在设定的时间过期. 参数与`expiresIn`的参数相同
        - `audience`
        - `issuer`
        - `jwtid`
        - `subject`
        - `noTimestamp`
        - `header`
        - `keyid`
        - `mutatePayload`：如果为 true，则 sign 函数将直接修改有效负载对象。如果在将声明应用于有效负载之后但在将其编码为令牌之前需要对有效负载的原始引用，这将非常有用。

4. callback: **function(error,token)**
    1. error: **any** 错误的消息
    2. token: **string** 生成的`token`值

## 使用

```js
const express = require('express')
const userRouter = express.Router()
const db = require('../db/conn')
const secret = require('../app') // 密钥
const JWT = require('jsonwebtoken') // jwt

// 在获取数据时必须await等待查询完成!
userRouter.route('/user').post(async (req, res, next) => {
  console.log(req.headers.authorization)

  const dbConnect = db.getDB()
  const profile = await dbConnect
    .collection('shadow')
    .findOne({ aut_name: req.body.account }, { aut_name: 1, aut_pwd: 1 })

  if (profile['aut_pwd'] === req.body.password) {
  // 对从数据库获取到的用户名进行加密生成token
    let token = JWT.sign(profile['aut_name'], secret, {
      algorithms: ['RS256'], // 使用RS256算法加密
      expiresIn: '3h',// 3小时后过期
    }, (err, token) => {
      console.log(token) // 输入生成的token值
    })

	// 返回登录成功的状态
    res.send({
      body: `登录成功,欢迎您, ${ req.body.account }`,
      statusCode: 200,
      statusText: 'OK',
      token,
    })

  }
  // 账密与数据库中的账密不对则返回错误的状态
  else {
    res.send({
      body: `请检查账号密码是否正确!`,
      statusCode: 401,
      statusText: 'Error',
    })
  }
})

module.exports = userRouter
```