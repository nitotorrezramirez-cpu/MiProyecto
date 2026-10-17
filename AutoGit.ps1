# 1. Aplicar configuraciones de seguridad y permisos en la computadora
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
git config --global --add safe.directory C:/Users/nitot/MiProyecto
git config --global user.name "nicolas"
git config --global user.email "nitotorrezramirez@gmail.com"

# 2. Asegurar que estamos en la carpeta del proyecto
Set-Location -Path "C:\Users\nitot\MiProyecto"

# 3. Guardar y subir todos los cambios automáticamente a GitHub
git add .
git commit -m "Actualizacion automatica $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
git push origin main

Write-Host "`n¡Todo se ha guardado y subido a GitHub sin errores!" -ForegroundColor Green
