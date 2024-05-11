## Jenkins配置
1. 创建项目, 让Jenkins知道你要通过哪个仓库触发CD动作
选择源码管理, 填写URL和对应的仓库认证方式
2. 触发构建, 让Jenkins知道你通过什么动作触发
选择构建触发器, 这里选择使用`GitLab webhook URL`
3. 触发之后添加一些额外选项, 这里选择`Generic Webhook Trigger`(通用Webhook触发器)
选择`Generic Webhook Trigger`的`Post content parameters`, 添加变量,把隐私参数写到这里
本文所需的参数和值, 请根据你的项目实际需要进行修改:
示例:
![[Pasted image 20230910215700.png]]
1. ref: `$.ref` 
2. gitUrl: `$project.git_http_url` 
3. projectID: `$.project_id` gitlab的项目ID
4. k8sApiServce: `https://127.0.0.1:6443/apis/apps/v1`
5. GitlabApiServer: gitlab的api地址, 默认是`url/api/v4` [文档](https://docs.gitlab.com/ee/api/repository_files.html#update-existing-file-in-repository)
选择`Generic Webhook Trigger`的`Token`, 这里的输入gitlab的一个Token, 建议与gitlab的项目仓库同名,复制`http://JENKINS_URL/generic-webhook-trigger/invoke`到Gitlab中
![[Pasted image 20230910215739.png]]
进入到Gitlab, 找到项目设置-> 访问令牌

![[Pasted image 20230910220239.png]]
复制生成的Gitlab访问令牌的值, 添加到Jenkins凭据中
![[Pasted image 20230910220606.png]]

1. 获取token

```shell
kubectl get secret -n <namespace>
```

例子:

```shell
kubectl get secret jenkins -n jenkins -o jsonpath={".data.token"} | base64 -d
```

创建namespace,  ServiceAccount ,Secret, ClusterRoleBinding  干了这事
```yml
---
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-service-account
  namespace: jenkins
---
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-secret
  namespace: jenkins
  annotations:
    kubernetes.io/service-account.name: jenkins-service-account
type: kubernetes.io/service-account-token
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-cluster-admin-rbac
subjects:
  - kind: ServiceAccount
    # Reference to upper's `metadata.name`
    name: jenkins-service-account
    # Reference to upper's `metadata.namespace`
    namespace: jenkins
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

```
gitlab
```
glpat-L2Paidzu7Q8sd_szmqzP
```

Jenkinsfile.groovy
```groovy

import java.util.Base64

// 封装http请求
def k8sHttpReq(reqType, reqUrl, reqBody) {
    def result
    // k8s的api可以参考https://kubernetes.io/zh-cn/docs/reference/using-api/api-concepts/
    withCredentials([string(credentialsId: 'kubernetes-token', variable: 'k8stoken')]) {
        result = httpRequest consoleLogResponseBody: true,
                customHeaders: [
                        [maskValue: true, name: 'Authorization', value: "Bearer ${k8stoken}"],
                        [maskValue: false, name: 'Content-Type', value: 'application/yaml'],
                        [maskValue: false, name: 'Accept', value: 'application/yaml']
                ],
                httpMode: reqType,
                ignoreSslErrors: true,
                requestBody: reqBody,
                url: "${k8sApiServer}/${reqUrl}",
                wrapAsMultipart: false
    }

    return result
}

// 获取某一个deployment
def getDeployment(nameSpace, deployName) {
    apiUrl = "namespaces/${nameSpace}/deployments/${deployName}"
    response = k8sHttpReq('GET', apiUrl, '')
    return response
}

// 更新deployment
def updateDeployment(nameSpace, deployName, deployBody) {
    apiUrl = "namespaces/${nameSpace}/deployments/${deployName}"

    response = k8sHttpReq('PATCH', apiUrl, deployBody)
    println(response)
}

// 获取所有的deployments
def getAllDeployment(nameSpace) {
    apiUrl = "namespaces/${nameSpace}/deployments"
    response = k8sHttpReq('GET', apiUrl, '')
    return response.content
}

// 创建一个deployment
def createDeployment(nameSpace, deployBody) {
    apiUrl = "namespaces/${nameSpace}/deployments"
    response = k8sHttpReq('POST', apiUrl, deployBody)
    return response.content
}

// 删除一个deployment
def deleteDeployment(nameSpace, deployName) {
    apiUrl = "namespaces/${nameSpace}/deployments/${deployName}"
    response = k8sHttpReq('DELETE', apiUrl, '')
    return response.content
}

// 封装http请求
def httpReq(reqType, reqUrl, reqBody) {
    result = httpRequest consoleLogResponseBody: true,
            contentType: 'APPLICATION_JSON',
            customHeaders: [[maskValue: true, name: 'PRIVATE-TOKEN', value: "${gitlabToken}"]],
            httpMode: reqType,
            ignoreSslErrors: true,
            requestBody: reqBody,
            url: "${gitlabApiServer}/${reqUrl}",
            wrapAsMultipart: false
    return result
}

// 获取文件内容
def getRepoFile(projectId, filePath) {
    apiUrl = "projects/${projectId}/repository/files/${filePath}/raw"

    response = httpReq('GET', apiUrl, '')
    return response.content
}

// 更新文件内容
// def updateRepoFile(projectId, filePath, fileContent) {
//     apiUrl = "projects/${projectId}/repository/files/${filePath}"
//     reqBody = """
//         {"branch": "main", "encoding": "base64", "content": "${fileContent}", "commit_message": "Update a new file"}
//     """
//     response = httpReq('PUT', apiUrl, reqBody)
//     println(response.content)
// }

pipeline {
    agent any

    stages {
        // 拉取gitlab代码
        stage('Pull Repository') {
            steps {
                script {
                    branchName = ref - 'refs/heads/'   // 获取分支名
                    // 拉取分支的语法可以用jenkins自动生成，然后修改下就可以
                    checkout scmGit(branches: [[name: branchName]], extensions: [], userRemoteConfigs: [[credentialsId: 'gitlab-auth', url: gitUrl]])
                }
            }
        }

        // 上传镜像
        stage("Upload Image") {
            steps {
                script {
                    // credentialsId: Jenkins的Harbor的token的ID
                    // usernameVariable: Jenkins的Harbor的用户名的环境变量, 通过流水线语法生成脚本
                    // passwordVariable: Jenkins的Harbor的密码的环境变量, 通过流水线语法生成脚本
                    withCredentials([usernamePassword(credentialsId: 'Harbor', passwordVariable: 'password', usernameVariable: 'username')]) {
                        sh """
                          # 登陆Harbor
                          # -u Harbor用户名
                          # -p Harbor密码
                          docker login -u ${username} -p ${password} ${harborUrl}
                          # 构建镜像,docker会使用go项目中写好的docerfile文件构建镜像
                          # --progress=plain 文本方式显示构建过程
                          docker build --progress=plain --no-cache -t ${harborImageName}:${branchName} .
                          # 打Tag
                          # docker tag test2:${branchName} www.shandong.shop/test1/test2:${branchName}
            
                          docker tag ${harborImageName}:${branchName} ${harborUrl}/${harborImageDir}/${harborImageName}:${branchName}
                          sleep 1
                          # 上传镜像
                          # 推送到Harbor
                          docker push ${harborUrl}/${harborImageDir}/${harborImageName}:${branchName}
                          sleep 1
                          # 删除构建的二进制文件
                          # docker rmi ${harborImageName}:${branchName}
                        """
                    }
                }
            }
        }

        // 部署到容器编排
        stage('Deploy container orchestration') {
            steps {
                script {
                    // dockerImage: Harbor的镜像地址
                    dockerImage = "${harborUrl}/${harborImageDir}/${harborImageName}:${branchName}"
                    // 下载版本库文件
                    // 使用前面创建的k8s-info-service项目，查看gitlab该项目的id为4,所以第一个参数传4
                    response = getRepoFile(projectID, "${deploy_file}")

                    // 替换文件的内容（替换镜像)
                    fileData = readYaml text: """${response}"""
                    fileData["spec"]["template"]["spec"]["containers"][0]["image"] = dockerImage

                    // 将yaml转换为字符串
                    String ret = writeYaml returnText: true, data: fileData

                    // 将字符串进行base64编码
                    String base64encodedString = Base64.getEncoder().encodeToString(ret.getBytes("utf-8"));
                    println(base64encodedString)

                    // TODO 更新gitlab中的内容
                    // updateRepoFile(projectID, 'build%2fuat%2fdeploy.yaml', base64encodedString)

                    //获取部署的deployment状态
                    deployment = getAllDeployment("demoapp")

                    // 如果demo-go-app不存在，部署
                    yamlData = readYaml text: deployment

                    // 定义一个包含所有的deployemt的数组
                    deploymentList = []

                    // 遍历，将demoapp名称空间下的deployment都取出来
                    for (item in yamlData.items) {
                        deploymentList.add(item.metadata.name)
                    }

                    // 如果已经包含了这个deployment，则先删除，再创建
                    if (deploymentList.contains('demo-go-app')) {
                        println("如果已经包含了这个deployment")
                        deleteDeployment("demoapp", "demo-go-app")
                        sleep 1
                        createDeployment("demoapp", ret)
                    } else {
                        // 没有包含这个deployment，创建
                        println("没有包含这个deployment，创建")
                        createDeployment("demoapp", ret)
                    }
                }
            }
        }
    }
}

```


Jenkins 2
```

//所有的脚本命令都放在pipeline中
pipeline {
    //指定任务在哪个集群节点中执行
    agent any

    //声明全局变量，方便后面使用
    environment {
        harborUser = 'admin'
        harborPassword = 'Harbor12345'
        harborAddress = '192.168.2.152:30003'
        harborRepo = 'go'
    }

    stages {
        stage('拉取代码') {
            steps {
                echo '开始拉取git仓库代码……'
                checkout scmGit(branches: [[name: 'dev']], extensions: [], userRemoteConfigs: [[url: 'http://192.168.2.158:7080/root/test.git']])
                echo '开始拉取git仓库代码完毕。'
            }
        }
        stage('构建项目') {
            steps {
                echo '开始通过maven构建项目……'
                sh 'node -v'
                sh 'npm install pnpm -g'
                sh 'ls'
                sh 'cd ./web && pnpm install'
                sh 'ls'
                sh 'pnpm build'
                echo '通过maven构建项目完毕'
            }
        }
        stage('代码检查') {
            steps {
                echo 'TODO 通过SonarQube做代码质量检测'
            }
        }
        stage('制作镜像') {
            steps {
                echo '通过Docker制作自定义镜像……'
                sh '''mv ./target/*.jar ./docker/
                docker build -t ${JOB_NAME}:dev ./docker/'''
                echo '通过Docker制作自定义镜像完毕'
            }
        }
        stage('推送镜像') {
            steps {
                echo '将自定义对象推送到Harbor仓库……'
                sh '''docker login -u ${harborUser} -p ${harborPassword} ${harborAddress}
                docker tag ${JOB_NAME}:dev ${harborAddress}/${harborRepo}/${JOB_NAME}:dev
                docker push ${harborAddress}/${harborRepo}/${JOB_NAME}:dev
                docker image prune -f'''
                echo '将自定义对象推送到Harbor仓库完成'
            }
        }
        stage('将yml文件传到k8smaster') {
            steps {
                echo '将yml文件传到k8smaster……'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'k8smaster', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'pipeline-auto.yml')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                echo '将yml文件传到k8smaster完毕'
            }
        }
        stage('远程执行k8smaster的kubectl命令') {
            steps {
                echo '远程执行k8smaster的kubectl命令……'
                sshPublisher(publishers: [sshPublisherDesc(configName: 'k8smaster', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''kubectl apply -f /usr/local/k8s/pipeline-auto.yml
                //强制重新部署容器
                kubectl rollout restart deployment pipeline-auto -n test''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                echo '远程执行k8smaster的kubectl命令完毕'
            }
        }
    }
}
```
## 参考
k8s的[api](https://kubernetes.io/zh-cn/docs/reference/using-api/api-concepts/)
