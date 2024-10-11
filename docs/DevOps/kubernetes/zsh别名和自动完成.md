```zsh
# kubectl alias
alias k="kubectl"

# kubectl 自动补全
autoload -Uz compinit
compinit
source <(kubectl completion zsh)
```