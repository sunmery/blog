## 核心思路：

1. 使用`useEffect`来操作echarts的实例
2. 使用`useRef`Hooks操作原生DOM
3. 使用`ref`选择DOM

## 使用

1. 安装echarts

    ```powershell
    pnpm i echarts
    ```

2. 准备DOM

    ```ts
    const chartRef = useRef<null | HTMLElement>(null)
    ```

3. 准备实例化图表

    ```
    //1. 选择一个DOM实例化
    let chartInstance = echarts.init((chartRef.current as HTMLElement))
    //2. 图表的内容
    const option = { // 图表的选项 }
    //3. 将图表给DOM进行渲染 
    chartInstance.setOption(option)
    ```

4. 选择DOM展示图表

    ```tsx
     <div
        ref={ chartRef }
        style={{ height: '400px' }}
        >
    </div>
    ```