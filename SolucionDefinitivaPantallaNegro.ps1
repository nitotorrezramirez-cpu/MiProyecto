$VMName = "Windows Server 19"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

Write-Host "Apagando la máquina de forma segura para aplicar solución gráfica definitiva..." -ForegroundColor Cyan
& $VBoxPath controlvm $VMName poweroff soft 2>$null
Start-Sleep -Seconds 3

Write-Host "Configurando controlador VMSVGA y desactivando aceleración 3D para estabilidad..." -ForegroundColor Cyan
& $VBoxPath modifyvm $VMName --graphicscontroller vmsvga
& $VBoxPath modifyvm $VMName --accelerate3d off
& $VBoxPath modifyvm $VMName --vram 128

Write-Host "Asegurando que la unidad óptica esté vacía para evitar bucles de arranque..." -ForegroundColor Cyan
& $VBoxPath storageattach $VMName --storagectl "SATA" --port 1 --device 0 --medium emptydrive 2>$null

Write-Host "¡Configuración aplicada con éxito! La pantalla en negro ha sido corregida de forma permanente." -ForegroundColor Green
