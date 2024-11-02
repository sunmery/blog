创建 Issuer
https://todoit.tech/k8s/cert/#%E5%88%9B%E5%BB%BA-issuer
```shell
export CLOUDFLARE_EMAIL="user@example.com"
export CLOUDFLARE_TOKEN="JetH3-LDZZwk2mJ0kiPpE"

# 1. cloudflare 添加 DNS 记录. 映射到对应的服务器
# 2. 前往个人资料 -> API 令牌， 使用编辑区域 DNS 模版， 创建一个 token。
# 3. 测试
curl -X GET "https://api.cloudflare.com/client/v4/user/tokens/verify" \
     -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
     -H "Content-Type:application/json"

# 将得到的 token，保存到 .env 文件中，并将 .env.prod 添加到 .gitignore 中

cat > .env.prod <<EOF
api-token=${CLOUDFLARE_TOKEN}
EOF

# 使用 Kustomize 来管理该 token。
cat > kustomization.yaml <<EOF
resources:
  - letsencrypt-issuer.yaml
namespace: cert-manager
secretGenerator:
  - name: cloudflare-api-token-secret
    envs:
      - .env.prod # token 就存放在这里，这个文件不会被提交到 Git 仓库中
generatorOptions:
  disableNameSuffixHash: true
EOF

# 使用 Kustomize 来生成一个名为 cloudflare-api-token-secret 的 Secret, 该 Secret 被下面的清单使用

cat >letsencrypt-issuer.yaml<<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-dns01
spec:
  acme:
    privateKeySecretRef:
      name: letsencrypt-dns01
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        cloudflare:
          email: ${CLOUDFLARE_EMAIL} # 替换成你的 cloudflare 邮箱账号
          apiTokenSecretRef:
            key: api-token
            name: cloudflare-api-token-secret # 引用保存 cloudflare 认证信息的 Secret
EOF

# 检查
kubectl kustomize ./

# 创建 issuer
kubectl apply -k ./

# 查看 Let't Encrypt 注册状态
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-dns01
```