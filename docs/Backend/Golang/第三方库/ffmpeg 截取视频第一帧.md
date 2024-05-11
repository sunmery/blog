```go
package test

import (
	"bytes"
	"fmt"
	"github.com/disintegration/imaging"
	ffmpeg "github.com/u2takey/ffmpeg-go"
	"log"
	"os"
	"strings"
	"testing"
)

func TestV(t *testing.T) {
	// 参数 1: 根据主入口文件的相对路径的文件, 
	// 参数 2: 输出的 image文件的位置
	// 参数 3: 截取的帧数, 1 表示视频第一帧
	name, err := GetSnapshot("./assets/video/1.mp4", "1", 1)
	if err != nil {
		log.Fatal(err)
		return
	}
	fmt.Println("return:", name)
}

func GetSnapshot(videoPath, snapshotPath string, frameNum int) (snapshotName string, err error) {
	// 给快照路径加上前缀, 需要修改的地方, 根据实际需要
	snapshotPath = "./assets/video/fm/" + snapshotPath

	// 创建一个空的字节缓冲区
	buf := bytes.NewBuffer(nil)

	// 使用ffmpeg从视频中提取指定帧
	err = ffmpeg.Input(videoPath).
		Filter("select", ffmpeg.Args{fmt.Sprintf("gte(n,%d)", frameNum)}).                   // 选择帧
		Output("pipe:", ffmpeg.KwArgs{"vframes": 1, "format": "image2", "vcodec": "mjpeg"}). // 输出设置
		WithOutput(buf, os.Stdout).
		Run() // 运行命令
	if err != nil {
		log.Fatal("生成缩略图失败：", err)
		return "", err
	}

	// 从字节缓冲区中解码图片
	img, err := imaging.Decode(buf)
	if err != nil {
		log.Fatal("生成缩略图失败：", err)
		return "", err
	}

	// 保存图片为PNG格式
	err = imaging.Save(img, snapshotPath+".jpg")
	if err != nil {
		log.Fatal("生成缩略图失败：", err)
		return "", err
	}

	// 打印快照路径
	fmt.Println("--snapshotPath--", snapshotPath)

	// 分割路径
	names := strings.Split(snapshotPath, "/")
	fmt.Println("----names----", names)

	// 获取图片的名称
	snapshotName = names[len(names)-1]
	fmt.Println("----snapshotName----", snapshotName)

	return snapshotName, nil
}

```

在宿主机安装`ffmpeg`并挂载到`alpine`容器:
`/home/ffmpeg-6.0-amd64-static:/usr/local/bin` 把`ffmpeg`所在的目录挂载到`alpine `的环境变量

> `alpine `的环境变量通过`docker exec -it <容器> echo $PATH`得到, 挂载到它返回的任意一个目录即可, 例如`/usr/local/bin`

示例输出:
```shell
docker exec -it tiktok echo $PATH

-> /root/.local/bin:/root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
```

```yml
version: '3'

services:
  tiktok:
    image: docker.io/library/tiktok
    container_name: tiktok
    restart: always
    ports:
      - "8080:8080"
      - "4000:4000"
    volumes:
      - ./configs:/data/conf
      - /home/ffmpeg-6.0-amd64-static:/usr/local/bin
    environment:
      - TZ=Asia/Shanghai
    command: ["/app/tiktok", "-conf", "/data/conf/production.yaml", "sh", "-c", "export PATH=\"/ffmpeg:$PATH\" && source /etc/profile"]

```

## 参考
1. https://github.com/u2takey/ffmpeg-go
2. https://juejin.cn/post/7107959471355199495
3. http://ffmpeg.org/