# Ruta exacta del ejecutable de VirtualBox en Windows
$vbox = "C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"

$VM_NAME = "Zentyal_7-001"
$OS_TYPE = "Ubuntu_64"
$RAM_MB = 2048
$CPU_COUNT = 2
$DISK_SIZE_MB = 15360

# Ruta exacta de la ISO según la página 5 del PDF de la clase
$ISO_PATH = "H:\ISO\LINUX\zentyal-7.0-development-amd64.iso"

Write-Host "[1/5] Creando la máquina virtual en VirtualBox..."
& $vbox createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register
& $vbox modifyvm "$VM_NAME" --memory "$RAM_MB" --cpus "$CPU_COUNT"

Write-Host "[2/5] Creando el disco duro virtual..."
$vdiPath = "$HOME\VirtualBox VMs\$VM_NAME\$VM_NAME.vdi"
& $vbox createmedium disk --filename "$vdiPath" --size "$DISK_SIZE_MB" --format VDI
& $vbox storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
& $vbox storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vdiPath"

Write-Host "[3/5] Adjuntando la ISO de Zentyal..."
& $vbox storagectl "$VM_NAME" --name "IDE Controller" --add ide
& $vbox storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH"

Write-Host "[4/5] Configurando adaptadores de red..."
& $vbox modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM
& $vbox modifyvm "$VM_NAME" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM

Write-Host "[5/5] Iniciando la máquina virtual..."
& $vbox startvm "$VM_NAME"

Write-Host "¡Proceso finalizado con éxito! La máquina ya debería aparecer y arrancar en VirtualBox."
