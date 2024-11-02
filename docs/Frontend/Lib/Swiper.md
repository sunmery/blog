## 普通版本
参考官网[例子](https://swiperjs.com/get-started)即可

## React
1. 使用`swiper`提供的`react`组件版本
2. swipt组件从`swiper`获取
3. HTML组件从`swiper/react`组件获取

例子:
```jsx
import { Navigation } from 'swiper';
import { Swiper, SwiperSlide } from 'swiper/react';

import 'swiper/css';
import 'swiper/css/navigation';

function App() {
  return (
    <Swiper
      modules={[Navigation]}
      navigation={{ prevEl: '.prev', nextEl: '.next' }}
      loop
      pagination={{ clickable: true }}
    >
      <SwiperSlide>Slide 1</SwiperSlide>
      <SwiperSlide>Slide 2</SwiperSlide>
      <SwiperSlide>Slide 3</SwiperSlide>
      <SwiperSlide>Slide 4</SwiperSlide>
      <button className='prev'>prev</button>
      <button className='next'>next</button>
    </Swiper>
  )
}

export default App
```
