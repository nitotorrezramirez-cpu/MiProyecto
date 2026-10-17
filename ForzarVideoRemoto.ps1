$VMName = "Windows Server 19"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

Write-Host "Enviando comando de desbloqueo y actualización gráfica a la máquina virtual..." -ForegroundColor Cyan
# Envía Ctrl+Alt+Supr para despertar la sesión
& $VBoxPath controlvm $VMName keyboardputscancode 1d 38 47 c7 9d b8 c7
Start-Sleep -Seconds 1

Write-Host "¡Señal enviada con éxito!" -ForegroundColor Green
