import construction_img from "@site/src/img/construction.gif";
import {useState} from "react";
import styles from './index.module.css'

export default function Construction() {
    const is_construction = useState<boolean>(false)
 return <div className={styles.construction}>
     {
         is_construction && <div>
             <img className={styles.img} src={construction_img} alt="construction"/>
             <b className={styles.text}>网站正在完善中, 部分文章需要重新分类</b>
         </div>
     }
 </div>
}
