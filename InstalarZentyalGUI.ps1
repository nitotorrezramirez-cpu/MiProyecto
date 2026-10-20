Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Crear la ventana principal de la interfaz gráfica
$form = New-Object System.Windows.Forms.Form
$form.Text = "Instalador Automático - Zentyal 7 (Universidad Nur)"
$form.Size = New-Object System.Drawing.Size(550, 450)$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox =$false

# Etiqueta de título
$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "Automatización de Servidor Zentyal"
$labelTitle.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$labelTitle.Location = New-Object System.Drawing.Point(20, 20)
$labelTitle.AutoSize =$true
$form.Controls.Add($labelTitle)

# Cuadro de texto para mostrar el progreso en tiempo real
$textBoxLog = New-Object System.Windows.Forms.TextBox
$textBoxLog.Location = New-Object System.Drawing.Point(20, 60)
$textBoxLog.Size = New-Object System.Drawing.Size(490, 260)$textBoxLog.Multiline = $true$textBoxLog.ScrollBars = "Vertical"
$textBoxLog.ReadOnly =$true
$textBoxLog.BackColor = [System.Drawing.Color]::Black$textBoxLog.ForeColor = [System.Drawing.Color]::Lime
$form.Controls.Add($textBoxLog)

# Botón para iniciar el proceso automatizado
$buttonStart = New-Object System.Windows.Forms.Button
$buttonStart.Text = "Iniciar Instalación y Configuración"
$buttonStart.Location = New-Object System.Drawing.Point(20, 340)
$buttonStart.Size = New-Object System.Drawing.Size(490, 40)$buttonStart.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$buttonStart.ForeColor = [System.Drawing.Color]::White$buttonStart.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($buttonStart)

# Función para añadir texto al log de la interfaz
function Log($message) {
    $textBoxLog.AppendText("$message`r`n")
    $form.Refresh()
}

# Acción del botón
$buttonStart.Add_Click({
    $buttonStart.Enabled =$false
    Log "Iniciando proceso según parámetros del documento..."

    $VM_NAME = "Zentyal_7-001"
    $OS_TYPE = "Ubuntu_64"
    $RAM_MB = 2048
    $CPU_COUNT = 2$DISK_SIZE_MB = 15360
    $ISO_PATH = "$HOME\ISO\LINUX\zentyal-7.0-development-amd64.iso"
    
    Log "[1/6] Creando máquina virtual: $VM_NAME..."
    & vboxmanage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[2/6] Configurando RAM ($RAM_MB MB) y CPUs ($CPU_COUNT)..."
    & vboxmanage modifyvm "$VM_NAME" --memory "$RAM_MB" --cpus "$CPU_COUNT" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[3/6] Creando disco duro virtual de 15 GB..."
    $vdiPath = "$HOME\VirtualBox VMs\$VM_NAME\$VM_NAME.vdi"
    & vboxmanage createmedium disk --filename "$vdiPath" --size "$DISK_SIZE_MB" --format VDI 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$vdiPath" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[4/6] Adjuntando ISO de Zentyal..."
    & vboxmanage storagectl "$VM_NAME" --name "IDE Controller" --add ide 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH" 2>&1 \vert{} Out-String \vert{} ForEach-Object { Log $_ }

    Log "[5/6] Configurando redes (Puente y Red NAT)..."
    & vboxmanage modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM 2>&1 | Out-String | ForEach-Object { Log $_ }
    & vboxmanage modifyvm "$VM_NAME" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM 2>&1 | Out-String | ForEach-Object { Log $_ }

    Log "¡Proceso de ensamblaje finalizado con éxito en la interfaz gráfica!"
    [System.Windows.Forms.MessageBox]::Show("La máquina virtual se ha configurado correctamente.", "Éxito", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    $buttonStart.Enabled =$true
})

# Mostrar ventana
[void]$form.ShowDialog()
