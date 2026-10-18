$VMName     = "Windows Server 19"
$VBoxPath   = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$IsoOrigen  = "C:\Users\nitot\Downloads\Windows_Server_2019_x64FRE_es-es.iso"

# Obtener automáticamente la ruta real del Escritorio sin importar el idioma de Windows
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$IsoDestino  = Join-Path $DesktopPath "Windows_Server_2019_x64FRE_es-es.iso"

Write-Host "1. Copiando la ISO al Escritorio de forma automática y segura..." -ForegroundColor Cyan
if (Test-Path $IsoOrigen) {
    Copy-Item -Path $IsoOrigen -Destination $IsoDestino -Force
    Write-Host "¡Copia al Escritorio completada con éxito en: $IsoDestino!" -ForegroundColor Green
} else {
    Write-Error "No se encontró la ISO en Descargas: $IsoOrigen"
    exit
}

Write-Host "2. Apagando la máquina virtual para aplicar configuración..." -ForegroundColor Cyan
& $VBoxPath controlvm "$VMName" poweroff 2>$null
Start-Sleep -Seconds 2

Write-Host "3. Configurando almacenamiento SATA y montando la ISO desde el Escritorio..." -ForegroundColor Yellow
& $VBoxPath storagectl "$VMName" --name "SATA" --add sata --controller IntelAhci --portcount 2 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "$VMName" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$HOME\VirtualBox VMs\$VMName\$VMName.vdi" 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null

Write-Host "4. Configurando red (2 adaptadores) y gráficos según la guía de la materia..." -ForegroundColor Yellow
& $VBoxPath modifyvm "$VMName" --nic1 bridged --bridge-adapter1 "Default"
& $VBoxPath modifyvm "$VMName" --nic2 nat
& $VBoxPath modifyvm "$VMName" --graphicscontroller vboxsvga
& $VBoxPath modifyvm "$VMName" --vram 128
& $VBoxPath modifyvm "$VMName" --accelerate3d off

Write-Host "5. Sincronizando repositorio con Git..." -ForegroundColor Cyan
git add .
git commit -m "Instalacion desde el Escritorio con ruta dinamica sin errores" 2>$null
git push

Write-Host "6. Iniciando la máquina virtual..." -ForegroundColor Green
& $VBoxPath startvm "$VMName"
