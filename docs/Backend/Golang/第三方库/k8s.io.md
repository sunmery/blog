
到集群查看kubeconfig
[# K8s生成kubeconfig访问集群](https://juejin.cn/post/7285540804735205430)

示例, 获取k8s命名空间
```go
package main

import (
	"context"
	"fmt"
	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"time"
)

func main() {
	// 创建一个具有超时的上下文
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel() // 确保在不再需要时取消上下文，以释放资源

	// 使用kubeconfig文件初始化client
	config, err := clientcmd.BuildConfigFromFlags("https://www.abc.cn", "./kubeconfig")
	if err != nil {
		panic(err.Error())

	}
	client, err := kubernetes.NewForConfig(config)
	if err != nil {
		panic(err.Error())
	}

	// 获取指定命名空间
	namespaces, err := GetNamespace(client, ctx, "default")
	if err != nil {
		panic(err)
	}
	fmt.Println("namespaces", namespaces)

	pod := &v1.Pod{
		ObjectMeta: metav1.ObjectMeta{
			Name: "mypod",
		},
		Spec: v1.PodSpec{
			Containers: []v1.Container{
				{
					Name:  "nginx",
					Image: "nginx:1.14.2",
				},
			},
		},
	}
	_, err = client.CoreV1().Pods("default").Create(context.TODO(), pod, metav1.CreateOptions{})

}

func GetNamespace(client *kubernetes.Clientset, ctx context.Context, namespace string) ([]string, error) {
	var namespaces []string
	pods, err := client.CoreV1().Pods(namespace).List(ctx, metav1.ListOptions{})
	if err != nil {
		return nil, err
	}
	for _, pod := range pods.Items {
		namespaces = append(namespaces, pod.Name)
	}

	return namespaces, nil
}

```