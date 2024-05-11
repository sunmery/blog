# Vue-i18n

#Vue-i18n #Vue

## 安装

- @intlify/vite-plugin-vue-i18n
- vue-i18n

## 配置

`main.js`

```js
import message from '@intlify/vite-plugin-vue-i18n/messages'

const i18n = createI18n({
	locale:navigator.language || 'en-US'
	messages
})
```

`locales/en-US.json` / `locales/zh-CN.json`

```json
{
	"language":"Language"
}
```

## 使用

`App.vue`

```vue
<i18n>
{
	"en-US":{
		"hello":"Hello World!"
	},
	"zh-CN":{
		"hello":"你好 世界!"
	}
}
</i18n>

<script setup>
	import {useI18n} from 'vue-i18n'
	const {locale,t} = useI18n({
		inheritLocale:true
	})
</script>

<template>
	<HelloWorld :msg="`${t('language')}: ${t('hello')}`" />
</template>
```

`HelloWorld.vue`

```vue
<script setup lang="ts">
defineProps<{ msg: string }>()
</script>

<template>
  <h1>{{ msg }}</h1>
</template>
```