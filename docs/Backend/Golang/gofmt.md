#### GoLand
https://github.com/mvdan/gofumpt

GoLand 不使用 `gopls`，因此应将其配置为直接使用 `gofumpt`。安装 `gofumpt` 后，请按照以下步骤作：

- Open **Settings** (File > Settings)  
    打开**设置** （文件 > 设置）
- Open the **Tools** section  
    打开 **“工具”** 部分
- Find the _File Watchers_ sub-section  
    找到 _File Watchers_ 子部分
- Click on the `+` on the right side to add a new file watcher  
    单击右侧的 `+` 添加新的文件观察器
- Choose _Custom Template_  
    选择_自定义模板_

When a window asks for settings, you can enter the following:  
当窗口要求设置时，您可以输入以下内容：

- File Types: Select all .go files  
    文件类型：选择所有 .go 文件
- Scope: Project Files  范围：项目文件
- Program: Select your `gofumpt` executable  
    程序：选择您的 `gofumpt` 可执行文件
- Arguments: `-w $FilePath$`  
    参数： `-w $FilePath$`
- Output path to refresh: `$FilePath$`  
    刷新输出路径：`$FilePath$`
- Working directory: `$ProjectFileDir$`  
    工作目录：`$ProjectFileDir$`
- Environment variables: `GOROOT=$GOROOT$;GOPATH=$GOPATH$;PATH=$GoBinDirs$`  
    环境变量： `GOROOT=$GOROOT$;GOPATH=$GOPATH$;PATH=$GoBinDirs$`

To avoid unnecessary runs, you should disable all checkboxes in the _Advanced_ section.  
为避免不必要的运行，您应该禁用 _“高级_ ”部分中的所有复选框。