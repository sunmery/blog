1. 编辑`bashrc`
```sh
vi ~/.bashrc
```

2. 设置别名
```sh
alias ct='kubectl'
```

3. 重新读取bashrc
```sh
source ~/.bashrc
```

总结:
```bash
echo "alias ct='kubectl'" >> ~/.bashrc && source ~/.bashrc
```