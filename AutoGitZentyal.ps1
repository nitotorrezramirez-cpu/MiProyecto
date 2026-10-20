$VMName     = "Zentyal_7-001"
$VBoxPath   = "C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"

# Obtener la ruta real del Escritorio
$DesktopPath = [Environment]::GetFolderPath('Desktop')

# Buscar la ISO en Descargas
$UserDownloads = [Environment]::GetFolderPath('UserProfile') + "\Downloads"
$IsoFile       = Get-ChildItem -Path $UserDownloads -Filter "*zentyal*.iso" | Select-Object -First 1

if ($IsoFile) {
    $IsoOrigen = $IsoFile.FullName
} else {
    $IsoOrigen = "$UserDownloads\zentyal-7.0-development-amd64.iso"
}

$IsoDestino = Join-Path $DesktopPath "zentyal-7.0-development-amd64.iso"

Write-Host "1. Copiando la ISO al Escritorio..." -ForegroundColor Cyan
if (Test-Path $IsoOrigen) {
    Copy-Item -Path $IsoOrigen -Destination $IsoDestino -Force
    Write-Host "¡Copia completada con éxito en: $IsoDestino!" -ForegroundColor Green
} else {
    Write-Error "No se encontró la ISO en Descargas: $IsoOrigen"
    exit
}

Write-Host "2. Creando y configurando Sistema (2048 MB RAM, 2 CPUs, Orden de arranque Optica/Disco)..." -ForegroundColor Cyan
& $VBoxPath createvm --name "$VMName" --ostype "Ubuntu_64" --register 2>$null
& $VBoxPath modifyvm "$VMName" --memory 2048 --cpus 2 --boot1 optic --boot2 disk --boot3 none --boot4 none

Write-Host "3. Configurando Pantalla (VMSVGA, 16 MB de vídeo)..." -ForegroundColor Yellow
& $VBoxPath modifyvm "$VMName" --graphicscontroller vmsvga
& $VBoxPath modifyvm "$VMName" --vram 16

Write-Host "4. Configurando Almacenamiento (Disco VDI de 15 GB e ISO en IDE/SATA)..." -ForegroundColor Yellow
$VdiPath = "$HOME\VirtualBox VMs\$VMName\$VMName.vdi"
& $VBoxPath createmedium disk --filename "$VdiPath" --size 15360 --format VDI 2>$null
& $VBoxPath storagectl "$VMName" --name "SATA Controller" --add sata --controller IntelAhci 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VdiPath" 2>$null

& $VBoxPath storagectl "$VMName" --name "IDE Controller" --add ide 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null

Write-Host "5. Configurando Audio (ICH AC97)..." -ForegroundColor Yellow
& $VBoxPath modifyvm "$VMName" --audio-controller ac97

Write-Host "6. Configurando Red (3 adaptadores exactos de la imagen)..." -ForegroundColor Yellow
& $VBoxPath modifyvm "$VMName" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM
& $VBoxPath modifyvm "$VMName" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM
& $VBoxPath modifyvm "$VMName" --nic3 nat --nictype3 82540EM

Write-Host "7. Sincronizando repositorio con Git..." -ForegroundColor Cyan
git add .
git commit -m "Configuracion exacta de Zentyal segun imagen de VirtualBox" 2>$null
git push 2>$null

Write-Host "8. Iniciando la máquina virtual..." -ForegroundColor Green
& $VBoxPath startvm "$VMName"
