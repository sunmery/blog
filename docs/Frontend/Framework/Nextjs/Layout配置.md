_app

```tsx
import { NextPage } from 'next'  
import type { AppProps } from 'next/app'  
import { ReactElement, ReactNode } from 'react'  
  
/*  
 * Layout组件所需的类型  
 * @params page {ReactElement} React tsx组件  
 * * @return Layout框架下的组件 { ReactNode } React组件  
 *  */export type NextPageLayout = NextPage & {  
  getLayout?: (page: ReactElement) => ReactNode  
}  
  
type AppPropsLayout = AppProps & {  
  Component: NextPageLayout  
}  
  
function MyApp ({  
  Component,  
  pageProps,  
}: AppPropsLayout) {  
  const getLayout = Component.getLayout ?? ((page) => page)  
  return getLayout(<Component { ...pageProps } />)  
}  
  
export default MyApp
```

Layout

```tsx
import Head from 'next/head'  
import Link from 'next/link'  
import type { ReactNode } from 'react'  
  
export default function Layout ({  
  children,  
  home,  
}: {  
  children: ReactNode,  
  home?: boolean  
}) {  
  return (  
    <div>  
      <Head>  
        <link rel="icon" href="/favicon.ico" />  
        <meta  
          name="description"  
          content="Learn how to build a personal website using Next.js"  
        />  
        {/* <title>{ document.title }</title> */ }  
        <title>Title</title>  
      </Head>  
      <header>  
        { home ? (  
          <>  
            <nav>  
              <ul>  
                <li><Link href="/posts"><a>Posts</a></Link></li>  
              </ul>  
            </nav>  
          </>        ) : (  
          <>  
            <div>  
              <Link href="/">  
                <a>← Back to home</a>  
              </Link>  
            </div>  
          </>        ) }  
      </header>  
  
      <main>{ children }</main>  
  
      <footer>  
        { !home && (  
          <div>  
            <Link href="/">  
              <a>← Back to home</a>  
            </Link>  
          </div>  
        ) }  
      </footer>  
    </div>  
  )  
}
```

pages/index

```tsx
import '../styles/globals.css'  
import { NextPage } from 'next'  
import type { AppProps } from 'next/app'  
import { ReactElement, ReactNode } from 'react'  
  
/*  
 * Layout组件所需的类型  
 * @params page {ReactElement} React tsx组件  
 * * @return Layout框架下的组件 { ReactNode } React组件  
 *  */export type NextPageLayout = NextPage & {  
  getLayout?: (page: ReactElement) => ReactNode  
}  
  
type AppPropsLayout = AppProps & {  
  Component: NextPageLayout  
}  
  
function MyApp ({  
  Component,  
  pageProps,  
}: AppPropsLayout) {  
  const getLayout = Component.getLayout ?? ((page) => page)  
  return getLayout(<Component { ...pageProps } />)  
}  
  
export default MyApp
```