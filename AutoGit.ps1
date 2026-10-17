# ==========================================
# SCRIPT AUTOMÁTICO DE GIT Y VIRTUALBOX
# ==========================================

Write-Host "1. Guardando y subiendo cambios a GitHub..." -ForegroundColor Cyan
git add .
git commit -m "Actualizacion automatica del servidor" 2>$null
git push

Write-Host "2. Aplicando configuración en la Máquina Virtual..." -ForegroundColor Cyan
$VMName = "Windows Server 19"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Apagar la VM de forma segura por si estuviera colgada
& $VBoxPath controlvm $VMName poweroff soft 2>$null
Start-Sleep -Seconds 3

# Aplicar configuración gráfica definitiva (VBoxSVGA + Aceleración 3D + 128MB VRAM)
& $VBoxPath modifyvm $VMName --graphicscontroller vboxsvga
& $VBoxPath modifyvm $VMName --vram 128
& $VBoxPath modifyvm $VMName --accelerate3d on

# Asegurar que el lector de DVD esté vacío
& $VBoxPath storageattach $VMName --storagectl "SATA" --port 1 --device 0 --medium emptydrive 2>$null

Write-Host "¡Todo se guardó, subió y aplicó en el servidor con éxito!" -ForegroundColor Green
