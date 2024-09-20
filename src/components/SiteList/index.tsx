import {useEffect, useState} from "react";

interface SiteList {
    name: string
    url: string
}

export default function SiteList() {
    const [siteList, setSiteList] = useState<SiteList[]>([
        {name:'index',url:'/'},
        {name:'argocd',url:'https://116.213.43.152:31664'},
        {name:'jaeger',url:'http://116.213.43.152:30891'},
        {name:'casdoor',url:'http://38.55.206.16:32206/'},
        {name:'consul-server1',url:'http://116.213.43.152:32080'},
        {name:'consul-server2',url:'http://38.55.206.16:32080'},
    ])
    // TODO 开发后端
    useEffect(() => {
        fetch("https://116.213.43.152:31664",{
            method: "GET",
            headers: {"Content-Type": "application/json"},
        }).then(res => res.json())
            .then((data)=>{
                setSiteList(data)
            })
            .catch(err=>{
            console.error(err)
        })
    },[])
 return <>
     <div>
         <ol>
             {siteList.map((site: SiteList) => {
                 return <>
                     <li>
                         <div>{site.name}</div>
                         <div>
                             <a href={site.url}>{site.url}</a>
                         </div>
                     </li>
                 </>
             })}
         </ol>
     </div>
 </>
}
