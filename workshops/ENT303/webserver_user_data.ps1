<powershell>
# Script Log
Start-Transcript -Path "C:\UserData.log" -Append


# Install/upgrade SSM Agent
if (-not (Test-Path C:\SSMAgent_latest.exe)) {
  Invoke-WebRequest `
      https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe `
      -OutFile C:\SSMAgent_latest.exe
  Start-Process `
      -FilePath C:\SSMAgent_latest.exe `
      -ArgumentList "/S"
  Restart-Service AmazonSSMAgent
}

# Disable IE ESC
function Disable-InternetExplorerESC {
  $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
  $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
  Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
  Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
  Stop-Process -Name Explorer
}
Disable-InternetExplorerESC

# Install Admin tools
if ((Get-WindowsFeature RSAT-DNS-Server).installed -ne 'True') {
    Install-WindowsFeature -Name RSAT-AD-Tools,RSAT-DNS-Server
}

# Install Chocolatey
if (-not (Test-Path C:\ProgramData\\chocolatey)) {
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install SQL Management Tools
$Software = "SQL Server Management Studio"
$Installed = $null -ne (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -eq $Software })

if (-not $installed) {
C:\ProgramData\\chocolatey\choco install sql-server-management-studio -y
}

# Install AWSCLIv2
if (-not (Test-Path "C:\Program Files\Amazon\AWSCLIV2")) {
  msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /quiet
  }

# Install IIS Web Services
if ((Get-WindowsFeature Web-Mgmt-Console).installed -ne 'True') {
    Install-WindowsFeature Web-Common-Http,Web-Http-Logging,Web-Http-Redirect,Web-Dyn-Compression,Web-Net-Ext45,Web-Asp-Net45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Scripting-Tools,Web-Mgmt-Console
  }

# Copy webserverfiles locally
C:\PROGRA~1\Amazon\AWSCLIV2\aws s3 sync ${S3Bucket} C:\inetpub\pdocommsrig

# Configure webserver
icacls "C:\INETPUB\pdocommsrig" /grant "IIS_IUSRS:(OI)(CI)(RX)"
icacls "D:\Folder" /grant "Domain\ADGroup":(OI)(CI)RX
Set-WebBinding -Name "Default Web Site" -BindingInformation "*:80:" -PropertyName "Port" -Value "81"
New-IISSite -Name "pdocommsrig" -BindingInformation "*:80:" -PhysicalPath "$env:systemdrive\inetpub\pdocommsrig"


# Useful Locations
Write-Output "Chocolatey Logs: C:\ProgramData\chocolatey\logs\chocolatey.log"
Write-Output "Chocolatey Temp: C:\Users\%USERNAME%\AppData\Local\Temp\chocolatey"

Stop-Transcript

</powershell>
<persist>true</persist>