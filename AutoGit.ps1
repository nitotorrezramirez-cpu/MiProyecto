$VMName   = "Windows Server 19"
$VBoxPath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$IsoDestino = "C:\Windows_Server.iso"

Write-Host "1. Apagando la máquina virtual..." -ForegroundColor Cyan
& $VBoxPath controlvm "$VMName" poweroff 2>$null
Start-Sleep -Seconds 2

Write-Host "2. Configurando controladora IDE universal (elimina error de drivers)..." -ForegroundColor Yellow
& $VBoxPath storagectl "$VMName" --name "SATA" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --add ide --controller PIIX4 2>$null

& $VBoxPath storageattach "$VMName" --storagectl "IDE" --port 0 --device 0 --type hdd --medium "$HOME\VirtualBox VMs\$VMName\$VMName.vdi" 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null

& $VBoxPath modifyvm "$VMName" --nic1 nat
& $VBoxPath modifyvm "$VMName" --nic2 intnet
& $VBoxPath modifyvm "$VMName" --intnet2 "SO2"
& $VBoxPath modifyvm "$VMName" --graphicscontroller vboxvga
& $VBoxPath modifyvm "$VMName" --vram 128
& $VBoxPath modifyvm "$VMName" --accelerate3d off

Write-Host "3. Sincronizando con Git..." -ForegroundColor Cyan
git add .
git commit -m "Cambio a controladora IDE universal para instalacion limpia" 2>$null
git push

Write-Host "4. Iniciando la máquina virtual..." -ForegroundColor Green
& $VBoxPath startvm "$VMName"
