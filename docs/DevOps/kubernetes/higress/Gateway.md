语法:
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: higress-console
    # namespace: higress
spec:
  ingressClassName: higress
  rules:
    - host: local.higress.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: higress-console
                port:
                  number: 8080
```

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: higress-gateway
  namespace: higress-system
spec:
  ingressClassName: higress
  rules:
    - host: gateway.higress.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: higress-gateway
                port:
                  number: 443
```