Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Instalador Zentyal - Universidad Nur"
$form.Size = New-Object System.Drawing.Size(600, 480)$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox =$false

$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "Ensamblaje y Arranque Automático (ISO en Descargas)"
$labelTitle.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$labelTitle.Location = New-Object System.Drawing.Point(20, 20)
$labelTitle.AutoSize =$true
$form.Controls.Add($labelTitle)

$textBoxLog = New-Object System.Windows.Forms.TextBox
$textBoxLog.Location = New-Object System.Drawing.Point(20, 60)
$textBoxLog.Size = New-Object System.Drawing.Size(540, 260)$textBoxLog.Multiline = $true$textBoxLog.ScrollBars = "Vertical"
$textBoxLog.ReadOnly =$true
$textBoxLog.BackColor = [System.Drawing.Color]::Black$textBoxLog.ForeColor = [System.Drawing.Color]::Lime
$form.Controls.Add($textBoxLog)

$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Crear MV e Iniciar en VirtualBox"
$buttonStart.Location = New-Object System.Drawing.Point(20, 340)
$buttonStart.Size = New-Object System.Drawing.Size(540, 50)$buttonStart.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$buttonStart.ForeColor = [System.Drawing.Color]::White$buttonStart.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($buttonStart)

function Log($message) {
    $textBoxLog.AppendText("$message`r`n")
    $form.Refresh()
}

$buttonStart.Add_Click({
    $buttonStart.Enabled =$false
    
    # Ruta de VirtualBox en Windows
    $vbox = "C:\Program Files\Oracle\VirtualBox\vboxmanage.exe"
    
    $VM_NAME = "Zentyal_7-001"
    $OS_TYPE = "Ubuntu_64"
    $RAM_MB = 2048
    $CPU_COUNT = 2$DISK_SIZE_MB = 15360
    
    # Ruta automática al archivo ISO dentro de la carpeta Descargas de Windows
    $userDownloads = [Environment]::GetFolderPath('UserProfile') + "\Downloads"
    
    # Busca automáticamente cualquier archivo ISO de Zentyal en Descargas, o usa el nombre estándar
    $isoFile = Get-ChildItem -Path$userDownloads -Filter "*zentyal*.iso" | Select-Object -First 1
    if ($isoFile) {
        $ISO_PATH =$isoFile.FullName
    } else {
        $ISO_PATH = "$userDownloads\zentyal-7.0-development-amd64.iso"
    }

    Log "ISO detectada en: $ISO_PATH"

    Log "[1/5] Creando la máquina virtual '$VM_NAME'..."
    & $vbox createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[2/5] Configurando RAM ($RAM_MB MB) y Procesadores ($CPU_COUNT)..."
    & $vbox modifyvm "$VM_NAME" --memory "$RAM_MB" --cpus "$CPU_COUNT" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[3/5] Creando disco duro virtual de 15 GB..."
    $vdiPath = "$HOME\VirtualBox VMs\$VM_NAME\$VM_NAME.vdi"
    & $vbox createmedium disk --filename "$vdiPath" --size "$DISK_SIZE_MB" --format VDI 2>&1 | Out-String | ForEach-Object { Log $_ }
    & $vbox storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci 2>&1 | Out-String | ForEach-Object { Log $_ }
    & $vbox storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vdiPath" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[4/5] Conectando la ISO y adaptadores de red..."
    & $vbox storagectl "$VM_NAME" --name "IDE Controller" --add ide 2>&1 | Out-String | ForEach-Object { Log $_ }
    & $vbox storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }
    & $vbox modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM 2>&1 | Out-String | ForEach-Object { Log $_ }
    & $vbox modifyvm "$VM_NAME" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM 2>&1 | Out-String | ForEach-Object { Log $_ }

    Log "[5/5] Iniciando la máquina virtual..."
    & $vbox startvm "$VM_NAME" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "¡Listo! Abre VirtualBox para ver la máquina en ejecución y seguir el PDF."
    [System.Windows.Forms.MessageBox]::Show("La máquina virtual se ha creado e iniciado correctamente.", "Éxito", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $buttonStart.Enabled =$true
})

[void]$form.ShowDialog()
