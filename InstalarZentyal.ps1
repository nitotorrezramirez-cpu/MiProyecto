#!/bin/bash

# --- CONFIGURACIÓN DE PARÁMETROS SEGÚN EL PDF ---
VM_NAME="Zentyal_7-001"
OS_TYPE="Ubuntu_64"
RAM_MB=2048
CPU_COUNT=2
DISK_SIZE_MB=15360 # 15 GB
ISO_PATH="$HOME/ISO/LINUX/zentyal-7.0-development-amd64.iso"
SHARED_FOLDER_PATH="$HOME/MV/Area_Compartida"

echo "[1/6] Creando la máquina virtual: $VM_NAME..."
vboxmanage createvm --name "$VM_NAME" --ostype "$OS_TYPE" --register

echo "[2/6] Configurando memoria RAM ($RAM_MB MB) y CPUs ($CPU_COUNT)..."
vboxmanage modifyvm "$VM_NAME" --memory "$RAM_MB" --cpus "$CPU_COUNT" --boot1 optic --boot2 disk --boot3 none --boot4 none

echo "[3/6] Creando y conectando el disco duro virtual de 15 GB..."
vboxmanage createmedium disk --filename "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi" --size "$DISK_SIZE_MB" --format VDI
vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci --portcount 1
vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

echo "[4/6] Adjuntando la imagen ISO de Zentyal en el controlador IDE..."
vboxmanage storagectl "$VM_NAME" --name "IDE Controller" --add ide
vboxmanage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH"

echo "[5/6] Configurando las interfaces de red..."
vboxmanage modifyvm "$VM_NAME" --nic1 bridged --bridgeadapter1 "Intel(R) Dual Band Wireless-AC 7265" --nictype1 82540EM --cableconnected1 on
vboxmanage modifyvm "$VM_NAME" --nic2 natnetwork --nat-network2 "RNatSoII" --nictype2 82540EM --cableconnected2 on

echo "[6/6] Añadiendo la carpeta compartida..."
mkdir -p "$SHARED_FOLDER_PATH"
vboxmanage sharedfolder add "$VM_NAME" --name "Area_Compartida" --hostpath "$SHARED_FOLDER_PATH" --automount --auto-mount-point "/media/sf_Area_Compartida"

echo "¡Ensamblaje completado con éxito!"
