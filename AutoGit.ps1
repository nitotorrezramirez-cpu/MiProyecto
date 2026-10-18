$VMName     = "Windows Server 19"
$VBoxPath   = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$IsoOrigen  = "C:\Users\nitot\Downloads\Windows_Server_2019_x64FRE_es-es.iso"
$IsoDestino = "$HOME\Escritorio\Windows_Server_2019_x64FRE_es-es.iso"

Write-Host "1. Copiando la ISO directamente al Escritorio..." -ForegroundColor Cyan
if (Test-Path $IsoOrigen) {
    Copy-Item -Path $IsoOrigen -Destination $IsoDestino -Force
    Write-Host "¡Copia al Escritorio completada con éxito!" -ForegroundColor Green
} else {
    Write-Error "No se encontró la ISO en Descargas."
    exit
}

Write-Host "2. Apagando la máquina virtual para actualizar la fuente..." -ForegroundColor Cyan
& $VBoxPath controlvm "$VMName" poweroff 2>$null
Start-Sleep -Seconds 2

Write-Host "3. Configurando controladora IDE universal y montando desde el Escritorio..." -ForegroundColor Yellow
& $VBoxPath storagectl "$VMName" --name "SATA" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --remove 2>$null
& $VBoxPath storagectl "$VMName" --name "IDE" --add ide --controller PIIX4 2>$null

& $VBoxPath storageattach "$VMName" --storagectl "IDE" --port 0 --device 0 --type hdd --medium "$HOME\VirtualBox VMs\$VMName\$VMName.vdi" 2>$null
& $VBoxPath storageattach "$VMName" --storagectl "IDE" --port 1 --device 0 --type dvddrive --medium "$IsoDestino" 2>$null

Write-Host "4. Sincronizando con Git..." -ForegroundColor Cyan
git add .
git commit -m "Instalacion desde el Escritorio segun indicacion del profesor" 2>$null
git push

Write-Host "5. Iniciando la máquina virtual..." -ForegroundColor Green
& $VBoxPath startvm "$VMName"
