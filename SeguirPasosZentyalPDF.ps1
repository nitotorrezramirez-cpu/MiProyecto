Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Automatización Zentyal (Págs. 22-42) - Universidad Nur"
$form.Size = New-Object System.Drawing.Size(620, 500)$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox =$false

$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "Generador y Lanzador de Zentyal (Pasos del PDF)"
$labelTitle.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
$labelTitle.Location = New-Object System.Drawing.Point(20, 20)
$labelTitle.AutoSize =$true
$form.Controls.Add($labelTitle)

$textBoxLog = New-Object System.Windows.Forms.TextBox
$textBoxLog.Location = New-Object System.Drawing.Point(20, 60)
$textBoxLog.Size = New-Object System.Drawing.Size(560, 280)$textBoxLog.Multiline = $true$textBoxLog.ScrollBars = "Vertical"
$textBoxLog.ReadOnly =$true
$textBoxLog.BackColor = [System.Drawing.Color]::Black$textBoxLog.ForeColor = [System.Drawing.Color]::Lime
$form.Controls.Add($textBoxLog)

$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Ejecutar Ensamblaje y Preparar Instalación"
$buttonStart.Location = New-Object System.Drawing.Point(20, 360)
$buttonStart.Size = New-Object System.Drawing.Size(560, 50)$buttonStart.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$buttonStart.ForeColor = [System.Drawing.Color]::White$buttonStart.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($buttonStart)

function Log($message) {
    $textBoxLog.AppendText("$message`r`n")
    $form.Refresh()
}

$buttonStart.Add_Click({$buttonStart.Enabled = $false$VM_NAME = "Zentyal_7-001"
    $OS_TYPE = "Ubuntu_64"
    $RAM_MB = 2048
    $CPU_COUNT = 2$DISK_SIZE_MB = 15360
    $ISO_PATH = "$HOME\ISO\LINUX\zentyal-7.0-development-amd64.iso"

    Log "[Paso 5-10] Verificando y creando la máquina virtual..."
    & vboxmanage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[Paso 11-12] Configurando hardware (RAM: 2GB, CPUs: 2)..."
    & vboxmanage modifyvm "$VM_NAME" --memory "$RAM_MB" --cpus "$CPU_COUNT" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[Paso 7] Creando disco duro virtual de 15 GB..."
    $vdiPath = "$HOME\VirtualBox VMs\$VM_NAME\$VM_NAME.vdi"
    & vboxmanage createmedium disk --filename "$vdiPath" --size "$DISK_SIZE_MB" --format VDI 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vdiPath" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[Paso 10-20] Conectando la ISO de Zentyal y redes..."
    & vboxmanage storagectl "$VM_NAME" --name "IDE Controller" --add ide 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }
    & vboxmanage modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage modifyvm "$VM_NAME" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM 2>&1 | Out-String | ForEach-Object { Log $_ }

    Log "[Paso 22] Iniciando la MV para seguir el asistente del PDF..."
    & vboxmanage startvm "$VM_NAME" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "¡Listo! Máquina iniciada. Sigue los pasos visuales del PDF (Págs 22 a 42):"
    Log "-> Pág 22: Selecciona 'Install Zentyal (delete all disk)'[cite: 62]."
    Log "-> Pág 26: Crea el usuario 'master' con su contraseña[cite: 66]."
    Log "-> Pág 31-42: Entra al navegador web de la MV (https://localhost:8443) con el usuario 'master' y completa el Wizard de red y roles[cite: 71, 73, 77, 78, 83]."

    [System.Windows.Forms.MessageBox]::Show("Entorno preparado con éxito. Sigue las páginas 22 a 42 en la ventana de VirtualBox.", "Guía Zentyal Nur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $buttonStart.Enabled =$true
})

[void]$form.ShowDialog()
