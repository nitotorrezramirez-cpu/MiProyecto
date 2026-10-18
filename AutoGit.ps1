$VMName   = "Windows Server 19"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$IsoDestino = "C:\Windows_Server.iso"

Write-Host "1. Apagando la máquina virtual..." -ForegroundColor Cyan
& $VBoxPath controlvm "$VMName" poweroff 2>$null
Start-Sleep -Seconds 2

Write-Host "2. Configurando BIOS clásica y controladora IDE universal..." -ForegroundColor Yellow
& $VBoxPath modifyvm "$VMName" --firmware bios
& $VBoxPath storagectl "$VMName" --name "SATA" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --add ide --controller PIIX4 2>$null

& $VBoxPath storageattach "$VMName" --storagectl "IDE" --port 0 --device 0 --type hdd --medium "$HOME\VirtualBox VMs\$VMName\$VMName.vdi" 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null

Write-Host "3. Sincronizando con Git..." -ForegroundColor Cyan
git add .
git commit -m "Automatizacion completa: BIOS, IDE y configuracion de idioma" 2>$null
git push

Write-Host "4. Iniciando la máquina virtual limpia..." -ForegroundColor Green
& $VBoxPath startvm "$VMName"
