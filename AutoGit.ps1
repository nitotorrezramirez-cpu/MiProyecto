Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
git config --global --add safe.directory C:/Users/nitot/MiProyecto
Set-Location -Path "C:\Users\nitot\MiProyecto"

# 1. Subir cambios a GitHub
git add .
git commit -m "Actualizacion automatica $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main

Write-Host "`nSubido a GitHub. Aplicando cambios en la Maquina Virtual..." -ForegroundColor Yellow

# 2. Ejecutar automaticamente en la VM
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" guestcontrol "Windows Server 19" run --username "Administrador" --password "123.abc!" --exe "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -- powershell.exe -ExecutionPolicy Bypass -Command "Invoke-RestMethod https://raw.githubusercontent.com/nitotorrezramirez-cpu/MiProyecto/main/ConfigurarServidor.ps1 | Invoke-Expression"

Write-Host "`n¡Todo se guardo, subio y ejecuto en el servidor con exito!" -ForegroundColor Green
