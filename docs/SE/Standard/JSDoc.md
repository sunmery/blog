# JSDoc

[JSDoc](https://en.wikipedia.org/wiki/JSDoc)
[官网文档](https://jsdoc.app/)
#规范 #Scripts

## 标记 Tags

@author 开发者名称
@constructor 将函数标记为构造函数
@deprecated 标记为已弃用
@throws/@exception 记录方法引发的异常
@param 参数
@private 私有
@return 返回值
@see 记录与另一个对象的关联
@todo 记录丢失/打开的内容
@this 指定关键字在函数中引用的对象类型
@version 提供库的版本号
[@function](https://jsdoc.app/tags-function.html)(synonyms: @func, @method) 描述函数
@fires 描述此方法可能引发的事件。
@listens 列出符号侦听的事件。
@since 这个功能是什么时候添加的?

### 示例:

```js
/* @class Circle representing a circle. */
/* @class Circle 代表 circle 实例对象 */
class Circle{
/*

* Creates an instance of Circle
*
* author: lisa<xionz@qq.com>
* @param {number} r The desired radius of the circle.
  */

constructor(){

/* @private */ this.radius = r

/* @private */ this.circumference = 2 * Math.Pi * r

/**

* Create a new Circle from a diameter.

* @param {number} d the xx
* @param {Circle} The new Circle object
  */

static fromDiameter(d) {
return new Circle(d / 2)
}

/*

* calculates the circumference of th Circle

* @deprecated since 1.1.0; use getCircumference instead
* @return {number}
  */
  calculateCircumference() {
  return 2 * Math.PI * this.radius
  }

/**

* Returns the pre-computed circumference of the Circle.
*
* @return {number} The circumference of the circle.
* @since 1.1.0
  */
  getCircumference() {
  return this.circumference
  }

/**

* Find a String representation of the Circle.
*
* @override
* @return {string} Human-readable representation of this Circle.
  */
  toString() {
  return `[A Circle object with radius of ${this.radius}.]`
  }
  }

/**

* Prints a circle.
*
* @param {Circle} circle
  */
  function printCircle(circle) {
  /** @this {Circle} */
  function bound() { console.log(this) }
  bound.apply(circle)
  }
```
