#!/bin/bash

# Default VM name if not entered on the command line
VM_NAME=${1-"k3s"}

BASE=$(pwd)

BUTANE_CONFIG="coreos-base.bu"
BUTANE_CONFIG_TAILORED="tailored-${BUTANE_CONFIG}"

IGNITION_INP="coreos-base.ign"

ISO_NAME="fedora-coreos-39.20240128.3.0-live.x86_64.iso"
ISO_NAME_TAILORED="tailored-${ISO_NAME}"

VCPUS="2"
RAM_MB="4096"
STREAM="stable"
DISK_GB="20"

# Download the CoreOS image
if [[ ! -f $ISO_NAME ]]; then
    podman run \
        --pull=always \
        --rm \
        -v /dev:/dev \
        -v /run/udev:/run/udev \
        -v .:/data \
        -w /data \
        quay.io/coreos/coreos-installer:release \
        download \
        -s stable \
        -p metal \
        -f iso
fi

# Update the hostname in thne butane file

sed "s/vmname/${VM_NAME}/" < ${BUTANE_CONFIG} > ${BUTANE_CONFIG_TAILORED}

# Create the ignition file
podman run \
    -i \
    --rm \
    quay.io/coreos/butane:release \
    --pretty \
    --strict < ${BUTANE_CONFIG_TAILORED} > ${IGNITION_INP}

# Delete any existing tailored iso file

if [[ -f $ISO_NAME_TAILORED ]]; then
    rm $ISO_NAME_TAILORED
fi

# Apply the ignition file to the iso
podman run \
    -i \
    --rm \
    -v /dev:/dev \
    -v /run/udev:/run/udev \
    -v .:/data \
    -w /data \
    quay.io/coreos/coreos-installer:release \
    iso customize \
    --dest-ignition ${IGNITION_INP} \
    --dest-device /dev/sda \
    -o ${ISO_NAME_TAILORED} \
    ${ISO_NAME}

# Delete any existing vm
VBoxManage unregistervm \
    $VM_NAME \
    --delete

# Create the VM
VBoxManage createvm \
    --name $VM_NAME \
    --register \
    --ostype "Fedora_64"

# Create the storage controller
VBoxManage storagectl $VM_NAME \
    --name "ide01" \
    --add ide

# Adjust memory, etc/
VBoxManage modifyvm $VM_NAME \
    --memory=4096 \
    --cpus=2 \
    --vram=64
