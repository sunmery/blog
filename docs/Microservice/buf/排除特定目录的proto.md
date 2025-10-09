# 场景
当你需要为不同的语言生成语言的pb文件时，有些proto不需要生成，那么就需要排除生成对应的pb文件
# 思路
创建一个单独的`buf.gen.yaml`文件，例如：`bug.gen.ts.yaml`，在此文件里排除不需要生成pb文件的目录即可

# 实现

`bug.gen.ts.yaml`文件内容：
```bash
version: v2

managed:
  enabled: true
  disable:
    - module: buf.build/googleapis/googleapis
      file_option: go_package_prefix # 禁用对 googleapis 模块的 go_package 重写
    - file_option: go_package
      module: buf.build/bufbuild/protovalidate
#    - file_option: go_package
#      module: buf.build/grpc-ecosystem/grpc-gateway
#  override:
#    - file_option: go_package_prefix
#      value: connect-go-example/greet
plugins:
  # This will invoke protoc-gen-es and write output to src/gen
  - local: protoc-gen-es
    out: .
    # Also generate any imported dependencies
    include_imports: true
    # Add more plugin options here
    opt: target=ts

inputs:
  # 引用当前模块（或工作区根目录）
  - directory: .
    # 🌟 使用 exclude_paths 排除不需要生成 TS 的目录
    exclude_paths:
      - internal/conf/v1
```

生成pb文件，由于创建了多份文件，需要告诉buf使用哪个文件的配置：
```bash
buf generate --template buf.gen.ts.yaml
```


就可以排除`exclude_paths`里的目录了

然后是正常的`buf.gen.yaml`实现：
```yaml
version: v2

managed:
  enabled: true
  disable:
    - module: buf.build/googleapis/googleapis
      file_option: go_package_prefix # 禁用对 googleapis 模块的 go_package 重写
    - file_option: go_package
      module: buf.build/bufbuild/protovalidate
#    - file_option: go_package
#      module: buf.build/grpc-ecosystem/grpc-gateway
#  override:
#    - file_option: go_package_prefix
#      value: connect-go-example/greet
plugins:
#  - remote: buf.build/grpc/go
#    out: .
#    opt: paths=source_relative
#  - remote: buf.build/protocolbuffers/go
#    out: gen
#    opt: paths=source_relative
  - local: protoc-gen-go
    out: .
    opt: paths=source_relative
  - local: protoc-gen-connect-go
    out: .
    opt: paths=source_relative
```
使用如下命令：
```bash
buf generate --template buf.gen.yaml
```
它依然会给proto文件生成对应的pb文件。

最终效果如下：
protoc-gen-es插件排除了该目录，自然也不会生成对应的`*_pb.ts`文件
![[Pasted image 20251009195425.png]]

没有排除目录的protoc-gen-es的配置生成的文件：
![[Pasted image 20251009195431.png]]

最后，可以添加简写，减少出错，也方便团队使用,  例如`Makefile`

`buf.mk`:
```Makefile
.PHONY: generate
generate:
	buf generate --template buf.gen.yaml
	buf generate --template buf.gen.ts.yaml
```