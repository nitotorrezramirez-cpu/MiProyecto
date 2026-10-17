Write-Host "Iniciando configuracion automatica..." -ForegroundColor Green
Rename-Computer -NewName "ServerWindows19" -Force
Add-Computer -WorkGroupName "SO2"
slmgr /rearm
Write-Host "Configuracion completada. Reiniciando..." -ForegroundColor Yellow
Restart-Computer
