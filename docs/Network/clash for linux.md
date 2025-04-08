https://github.com/nelvko/clash-for-linux-install

```bash
git clone --branch master --depth 1 https://gh-proxy.com/https://github.com/nelvko/clash-for-linux-install.git \
  && cd clash-for-linux-install \
  && sudo bash install.sh
```

它会与tailscale 冲突

可以先停止tailscale

```bahs
tailscale down
```
