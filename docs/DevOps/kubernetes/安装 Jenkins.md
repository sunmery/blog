
[教程](https://www.yoyoask.com/?p=9642)

```yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: jenkins-init-pvc
  namespace: devops
spec:
  accessModes:
    - ReadWriteOnce # rook-ceph-block支持ReadWriteOnce, nfc-csi 支持ReadWriteMany
  storageClassName: rook-ceph-block # 替换为自己的 pv
  resources:
    requests:
      storage: 20Gi
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins
  namespace: devops
spec:
  type: NodePort
  ports:
    - port: 7080
      targetPort: 8080
  selector:
    app: jenkins
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
  namespace: devops
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      initContainers:
        - name: init-container
          image: busybox
          imagePullPolicy: IfNotPresent
          command: ["sh"]
          args:
            [
              "-c",
              "chown -R 1000:1000 /var/jenkins_home",
            ]
          volumeMounts:
            - name: jenkins-home
              mountPath: /var/jenkins_home
      containers:
        - name: jenkins
          image: jenkins/jenkins:lts-jdk11
          ports:
            - containerPort: 8080
          volumeMounts:
            - name: jenkins-home
              mountPath: /var/jenkins_home
      volumes:
        - name: jenkins-home
          persistentVolumeClaim:
            claimName: jenkins-init-pvc

```