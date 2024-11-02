1. 渲染方式
   1.1 静态渲染(SSG)`getStaticProps`
   ```ts
       export const getStaticProps = async() =>{
           const res = await fetch(uri)
           const posts = await res.json()

           return {
               props:{
                   posts
               }
           }
       }

       export default function Posts(){
           // Render data
       }
   ```

   1.2 动态路径
   ```ts
   export const getStaticPaths = async () => {  
     const posts = await fetch('https://jsonplaceholder.typicode.com/posts', {  
     headers: { 'Content-Type': 'application/json' },  
   })
   
   const res = await posts.json()
   
   const paths = res.map((item: IPosts) => {  
   return {  
    params: { 'id': item.id.toString() },  
    }  
    },  
   )
   
   return {  
   paths,  
   fallback: false,  
    }  
   }
   ```

   1.3 服务端渲染(SSR)

```tsx
interface IProps {
  id: string
  userID: string
  title: string
  body: string
}

export const getServerSideProps = async () => {
  const res = await fetch('https://jsonplaceholder.typicode.com/posts')
  const posts = await res.json()

  return {
    props: {
      posts,
    },
  }
}

const Page = (props: { posts: Array<IProps> }) => {
  const { posts } = props
  return <>
      {
        posts.map((post: IProps) => {
          return <article key = { post.id } >
            <p>{ post.title } < /p>  
            < figure >
            <figcaption>
              <p>{ post.userID } < /p>  
            < p > { post.title } < /p>  
            < /figcaption>  
            < /figure>  
            < /article>  
        })
      }
    < />  
}
```

MarkDown解析库

1. 安装

   ```sehll
   pnpm i gray-matter
   ```

2. 准备md文件,在头部设置`--- key: value ---`
3. 读取md数据
    1. 获取需要读取的md文件的父目录
    2. 读取并给md文件设置编码格式,默认为`utf-8`
    3. 使用`matter`截取在md文件的元数据`--- key: value ---`的内容

MarkDown渲染库

1. 安装

   ```shell
   pnpm i remark remark-html
   ```

2. 准备md文件
3. 导入

   ```js
   import html from 'remark-html'
   import { remark } from 'remark'
   ```

4. 使用
    1. 搭配`matter`库解析md文件
    2. 使用`remark-html`将md文件转成HTML格式
    3. 将HTML数据转成字符串
    4. 页面渲染HTML字符串

   ```tsx
   const mdToHTML = async () =>{
       const filePath =  resolve(__dirname,'mdFile.md')
       const mdFile = fs.readFileSync(filePath,'utf-8')
       const mdFileResult = matter(mdFile)
   
       const content = await remark()
       .use(html)
       .process(mdFileResult.content)
       const htmlString = content.toString()
       return {
           htmlString
       }
   }
   ```
   
   ```
   App(props){
       const {htmlString} = props
       return <div dangerouslySetInnerHTML={{__html:  htmlString.content}}></div>
   }
   ```