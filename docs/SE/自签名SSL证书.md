#工程化

以下是生成不过期或 5 年后过期的 SSL 证书并导出私钥与公钥 crt 文件到本地桌面的 PowerShell 命令：

powershell 复制代码

```pwsh
# 生成不过期的 SSL 证书，有效期从现在开始至2099年
$cert = New-SelfSignedCertificate -DnsName localhost -CertStoreLocation cert:\CurrentUser\My -NotAfter ([datetime]::new(2099, 12, 31))

# 导出证书和私钥为PFX文件
Export-PfxCertificate -Cert $cert -FilePath "$env:USERPROFILE\Desktop\cert.pfx" -Password (ConvertTo-SecureString -String "password" -Force -AsPlainText)

# 导出证书为CRT文件
Export-Certificate -Cert $cert -FilePath "$env:USERPROFILE\Desktop\cert.crt"
```

以下是生成 5 年有效期的 SSL 证书并导出私钥与公钥 crt 文件到本地桌面的 PowerShell 命令：

```pwsh
# 生成5年有效期的 SSL 证书
$notAfter = (Get-Date).AddYears(5)
$cert = New-SelfSignedCertificate -DnsName localhost -CertStoreLocation cert:\CurrentUser\My -NotAfter $notAfter

# 导出证书和私钥为PFX文件
Export-PfxCertificate -Cert $cert -FilePath "$env:USERPROFILE\Desktop\cert.pfx" -Password (ConvertTo-SecureString -String "password" -Force -AsPlainText)

# 导出证书为CRT文件
Export-Certificate -Cert $cert -FilePath "$env:USERPROFILE\Desktop\cert.crt"
```

安装

```
最后一步是将证书安装到计算机的受信任存储区域中。以下是在 Windows 操作系统中安装证书的步骤：

-   双击 pfx 文件并按照证书导入向导进行操作。
-   在“存储位置”选项中，选择“将所有证书放入以下存储”，并选择“受信任的根证书颁发机构”作为存储区域。
-   点击“下一步”并接受默认选项。
-   点击“完成”。
```
