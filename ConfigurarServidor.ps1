Write-Host "Iniciando configuracion del servidor..." -ForegroundColor Green

# 1. Nombre y Grupo
Rename-Computer -NewName "ServerWindows19" -Force -ErrorAction SilentlyContinue
Add-Computer -WorkGroupName "SO2" -ErrorAction SilentlyContinue

# 2. Licencia
slmgr /rearm

# 3. IP Estatica y DNS
$Interfaz = (Get-NetAdapter | Where-Object Status -eq "Up")[0]
New-NetIPAddress -InterfaceIndex $Interfaz.ifIndex -IPAddress "192.168.1.10" -PrefixLength 24 -DefaultGateway "192.168.1.1" -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceIndex $Interfaz.ifIndex -ServerAddresses ("192.168.1.10", "8.8.8.8")

# 4. AQUI AGREGAS NUEVAS CONFIGURACIONES (Ejemplo: Habilitar Escritorio Remoto)
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 -ErrorAction SilentlyContinue
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

Write-Host "Configuracion procesada exitosamente." -ForegroundColor Yellow