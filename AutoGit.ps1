$VMName     = "Windows Server 19"
$VBoxPath   = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$IsoDestino = "C:\Windows_Server.iso"

& $VBoxPath controlvm "$VMName" poweroff 2>$null
Start-Sleep -Seconds 2
& $VBoxPath storagectl "$VMName" --name "SATA" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "SATA" --add sata --controller IntelAhci --portcount 2 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$HOME\VirtualBox VMs\$VMName\$VMName.vdi" 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null
& $VBoxPath modifyvm "$VMName" --nic1 nat
& $VBoxPath modifyvm "$VMName" --nic2 intnet
& $VBoxPath modifyvm "$VMName" --intnet2 "SO2"
& $VBoxPath modifyvm "$VMName" --graphicscontroller vboxsvga
& $VBoxPath modifyvm "$VMName" --vram 128
& $VBoxPath modifyvm "$VMName" --accelerate3d off

git add .
git commit -m "Auto-actualizacion y ejecucion del servidor" 2>$null
git push
& $VBoxPath startvm "$VMName"
