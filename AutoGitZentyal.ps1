$VMName     = "Zentyal_7-001"
$VBoxPath   = "C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"

# Obtener automáticamente la ruta real del Escritorio sin importar el idioma de Windows
$DesktopPath = [Environment]::GetFolderPath('Desktop')

# Buscar automáticamente la ISO de Zentyal en la carpeta Descargas
$UserDownloads = [Environment]::GetFolderPath('UserProfile') + "\Downloads"
$IsoFile       = Get-ChildItem -Path $UserDownloads -Filter "*zentyal*.iso" | Select-Object -First 1

if ($IsoFile) {
    $IsoOrigen = $IsoFile.FullName
} else {
    $IsoOrigen = "$UserDownloads\zentyal-7.0-development-amd64.iso"
}

$IsoDestino = Join-Path $DesktopPath "zentyal-7.0-development-amd64.iso"

Write-Host "1. Copiando la ISO de Zentyal al Escritorio de forma automática y segura..." -ForegroundColor Cyan
if (Test-Path $IsoOrigen) {
    Copy-Item -Path $IsoOrigen -Destination $IsoDestino -Force
    Write-Host "¡Copia al Escritorio completada con éxito en: $IsoDestino!" -ForegroundColor Green
} else {
    Write-Error "No se encontró la ISO de Zentyal en Descargas: $IsoOrigen"
    exit
}

Write-Host "2. Creando y configurando la máquina virtual en VirtualBox..." -ForegroundColor Cyan
& $VBoxPath createvm --name "$VMName" --ostype "Ubuntu_64" --register 2>$null
& $VBoxPath modifyvm "$VMName" --memory 2048 --cpus 2 --boot1 optic --boot2 disk --boot3 none --boot4 none

Write-Host "3. Creando disco virtual de 15 GB y configurando controladores..." -ForegroundColor Yellow
$VdiPath = "$HOME\VirtualBox VMs\$VMName\$VMName.vdi"
& $VBoxPath createmedium disk --filename "$VdiPath" --size 15360 --format VDI 2>$null
& $VBoxPath storagectl "$VMName" --name "SATA Controller" --add sata --controller IntelAhci 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VdiPath" 2>$null

Write-Host "4. Adjuntando la ISO de Zentyal desde el Escritorio..." -ForegroundColor Yellow
& $VBoxPath storagectl "$VMName" --name "IDE Controller" --add ide 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null

Write-Host "5. Configurando redes (Adaptador Puente y Red NAT 'RNatSoII')..." -ForegroundColor Yellow
& $VBoxPath modifyvm "$VMName" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM
& $VBoxPath modifyvm "$VMName" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM

Write-Host "6. Sincronizando repositorio con Git..." -ForegroundColor Cyan
git add .
git commit -m "Automatizacion de Zentyal desde el Escritorio con ruta dinamica" 2>$null
git push 2>$null

Write-Host "7. Iniciando la máquina virtual..." -ForegroundColor Green
& $VBoxPath startvm "$VMName"
