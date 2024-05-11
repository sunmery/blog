## 初始化
```go
// 初使化minio client对象。
url := viper.GetString("minio.url") // 不包含HTTP协议的Host+Post地址, 例如: 192.168.0.158:5000. url为访问minio服务器文件的地址
accessKey := viper.GetString("minio.accessKey")
secretKey := viper.GetString("minio.secretKey")

minioClient, err := minio.New(url, &minio.Options{
	Creds:  credentials.NewStaticV4(accessKey, secretKey, ""),
	Secure: false,
})
if err != nil {
	t.Fatal("创建Minio客户端失败", err)
	return
}
```

## 参考
1. [Minio API](https://min.io/docs/minio/linux/developers/go/API.html)
2. [Github](https://github.com/minio/minio-go)
3. [过时中文文档](https://github.com/minio/minio-go/blob/master/docs/zh_CN/API.md)
4. [获取MinioKey](https://juejin.cn/post/7134996289992785956)