<powershell>

# Set DOCKER_HOST
[System.Environment]::SetEnvironmentVariable("DOCKER_HOST", "${docker_host_ip}:${docker_host_port}", "Machine")

# Install Docker CLI
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) 
choco install docker-cli

</powershell>