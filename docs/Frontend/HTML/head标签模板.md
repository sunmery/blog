# HTML模板

#HTML

## Head属性详解

[head标签](https://developer.mozilla.org/zh-CN/docs/Web/HTML/Element/link)

```HTML
<!doctype html>
<html lang="zh-CN">
<head>
	<meta charset="UTF-8" />
	<meta name="viewport"
				content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0" />
	<meta http-equiv="X-UA-Compatible" content="ie=edge" />
	<!-- 网页中所运行的应用程序的名称 -->
	<meta name="application-name" content="Vue" />
	<meta name="author" content="Lookeke<xiconz@qq.com>" />
	<!--	段简短而精确的、对页面内容的描述/书签的默认描述 -->
	<meta name="description" content="首页" />
	<!--	生成此页面的软件的标识符-->
	<meta name="generator" content="" />
	<!--	与页面内容相关的关键词-->
	<meta name="keywords" content="" />
	<!--如果请求目标与当前页面一样安全或者更加安全（HTTP(S)→HTTPS），则发送完整 URL；如果请求目标更加不安全（HTTPS→HTTP），则不发送  referrer。这是默认行为。-->
	<meta name="referrer" content="no-referrer-when-downgrade" />
	<!-- 页面颜色 -->
	<meta name="theme-color" media="(prefers-color-scheme:light)" content="white" />
	<meta name="theme-color" media="(prefers-color-scheme:black)" content="black" />

	<!--	非标准: 与当前文档兼容的一种或多种配色方案 -->
	<meta name="color-scheme" content="light dark" />

	<!--	设置默认 CSS 样式表组的名称。 -->
	<meta http-equiv="default-style" content="base" />
	<!--	<link rel="icon" href="favicon.ico"/>-->
	<!--	<link rel="stylesheet" href="base.css" />-->

	<!-- apple移动设备图标类型 -->
	<!--	<link rel="apple-touch-icon-precomposed" sizes="114x114" href="apple-icon-114.png" type="image/png" />-->

	<!--	<link href="print.css" rel="stylesheet" media="print">-->

	<!--	移动端特有配置 -->
	<!--	<link href="mobile.css" rel="stylesheet" media="screen and (max-width: 600px)">-->
	<meta charset="UTF-8" />
	<link href="/vite.svg" rel="icon" type="image/svg+xml" />
	<meta content="width=device-width, initial-scale=1.0" name="viewport" />
	<meta content="edu-system" name="application-name" />
	<meta content="Lookeke<xicons@qq.com>" name="author" />
	<meta content="教务管理系统" name="description" />
	<meta content="edu-system,edu,management" name="keywords">
	<meta content="#1976d2" media="(prefers-color-scheme: light)" name="theme-color">
	<meta content="black" media="(prefers-color-scheme: dark)" name="theme-color">
	<meta content="edu-system-20221017-lookeke" name="generator" />
	<!-- 	预加载字体 -->
	<link as="font" crossorigin="anonymous" href="https://cos.ap-guangzhou.myqcloud.com/y-1309528122/edu_system/fonts/FiraCodeNF.otf" rel="preload"
				type="opentype" />
	<title>Document</title>
	<noscript>
		<strong>你的浏览器已经关闭了JavaScript脚本功能！ 请重新开启并刷新此网页</strong>
	</noscript>
</head>
```