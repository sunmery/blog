mac系统默认自带git版本通常都不是最新， 而且没有中文提示，可使用brew的特性来进行链接
```bash
brew link git --overwrite  
```
如果已经链接过， 可以尝试重新链接
```
brew unlink git && brew link git
brew unlink git && brew link git
```