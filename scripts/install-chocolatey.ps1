Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install chocolatey-core.extension -y

choco install 7zip -y

# choco install brave -y
# choco install firefox -y
# choco install googlechrome -y
# choco install notepadplusplus -y
# choco install vlc -y
# choco install mpc-be -y