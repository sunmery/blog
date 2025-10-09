v1.25: https://mp.weixin.qq.com/s/ok6H3I9QUFYGt-YpwZwXSg?scene=1&click_id=3

![[cd6f0d63bb93027e7be721bd57d25d14.png]]
```
go env -w GOEXPERIMENT=jsonv2
```

Go 1.25 引入了一个新的实验性垃圾收集器 ——Green Tea GC，可通过设置`GOEXPERIMENT=greenteagc`在构建时启用。这一改进旨在提高小对象的标记和扫描性能，同时增强 CPU 可扩展性。

根据官方基准测试，新的垃圾收集器在实际应用中可减少 10% 到 40% 的 CPU 开销。这对于内存密集型应用，尤其是长时间运行的服务器端应用来说，是一个巨大的性能提升。Green Tea GC 的主要优势在于：

1. **减少标记阶段的 CPU 开销**：通过优化内存访问模式，降低标记阶段的 CPU 使用率。
    
2. **更高效的小对象处理**：针对小对象的分配和回收进行了专门优化。
    
3. **更好的 CPU 扩展性**：在多核环境下表现更佳，减少锁竞争。
    

虽然这是一个实验性功能，但它预示着 Go 垃圾回收机制的未来发展方向。开发者可以通过设置环境变量来尝试这一新功能，并为 Go 团队提供反馈，帮助改进这一重要组件。
```go
go env -w GOEXPERIMENT=greenteagc
```
