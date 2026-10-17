$VMName = "ServerWindows19"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
& $VBoxPath controlvm $VMName poweroff soft 2>$null
Start-Sleep -Seconds 3
& $VBoxPath modifyvm $VMName --graphicscontroller vmsvga
& $VBoxPath modifyvm $VMName --accelerate3d off
Write-Host "¡Controlador optimizado con éxito!" -ForegroundColor Green
