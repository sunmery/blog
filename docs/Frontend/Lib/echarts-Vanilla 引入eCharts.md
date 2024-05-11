#Lib #Echarts

```html

<div id="app"></div>
<srcipt src="echarts.js"></script>
```

```css
div {
	width  : 200px;
	height : 200px
}
```

```js
const myCharts = echarts.init(document.getElementById('app'))
const xAxisArr = []
const yAxisArr = []
myCharts.setOptions({
  xAxis: {
    type: 'category',
    data: xAxisArr,
  },
  yAxis: {
    type: 'value',
    data: []
  },
  series: [
    {
      type: 'Line/Bar/pie',
      data: yAxisArr
    }
  ]
})
```