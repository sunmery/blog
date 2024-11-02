1. 在`publuc`目录下
2. 通过`<IP>/robots.txt`访问
   `# Block all crawlers for /` 防止爬虫爬取的地方
   `# Allow all crawlers` 允许爬虫爬取的地方

```txt
# Block all crawlers for /accounts  
  
# Allow all crawlers  
User-agent: *  
Allow: /
```