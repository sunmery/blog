## 配置国内源
1. Settings ->Appearance & Behavior -> System Settings -> HTTP Proxy
2. 选择`Auto-detect proxy settings`
3. 勾选 `Automatic proxy` 选项
4: 填写一个源
```text
腾讯： https://mirrors.cloud.tencent.com/AndroidSDK/

阿里： https://mirrors.aliyun.com/android.googlesource.com/
```

## 创建模拟机
1. File -> New -> NewProject-> 选择任意一个模板
![[Pasted image 20230731225334.png]]

2. 点击 Next

3. 配置应用程序信息

一般只需要填写`Name`就足够了, 点击`Finish`
![[Pasted image 20230731225431.png]]
4. 最后点击`Create Device` 等待安装完成

5. 点击运行

6. App 模拟机运行之后, 点击状态栏的`View` -> `Tool Windows` -> `Device Explorer` 
![[Pasted image 20230731230848.png]]
7. 打开`/sdcard`, 点击 `Upload` 图标将文件传输进去, 即可在模拟机看到

## 参考
https://zhuanlan.zhihu.com/p/536789267