[申请证书](https://todoit.tech/k8s/cert/#%E5%88%9B%E5%BB%BA-certificate)

```shell
export DOMAIN="lookeke.top"

# 创建 Certificate 创建 证书
cat > ${DOMAIN}-certificate.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: ${DOMAIN}
spec:
  dnsNames:
    - ${DOMAIN} # 要签发证书的域名，替换成你自己的
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-dns01 # 引用 ClusterIssuer，名字和 letsencrypt-issuer.yaml 中保持一致
  secretName: ${DOMAIN}-letsencrypt-tls # 最终签发出来的证书会保存在这个 Secret 里面
EOF
kubectl apply -f ${DOMAIN}-certificate.yaml

# 查看是否生效
kubectl get certificate

# kubectl get certificate -w
```
