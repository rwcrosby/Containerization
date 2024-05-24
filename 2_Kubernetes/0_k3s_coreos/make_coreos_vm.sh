#!/bin/bash

# Default VM name if not entered on the command line
VM_NAME=${1-"k3s"}

BASE=$(pwd)
IMAGE_BASE=$HOME/.local/share/libvirt/images

IMAGE=$IMAGE_BASE/fedora-coreos-40.20240504.3.0-qemu.x86_64.qcow2

BUTANE_CONFIG=${2-"coreos-base.bu"}
BUTANE_CONFIG_TAILORED="/tmp/tailored-${BUTANE_CONFIG}"

IGNITION_INP="/tmp/coreos-base.ign"
IGNITION_CONFIG="/var/lib/libvirt/images/coreos-base.ign"
IGNITION_DEVICE_ARG=(--qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}")

VCPUS="2"
RAM_MB="4096"
STREAM="stable"
DISK_GB="20"

# Update the hostname in thne butane file
sed "s/vmname/${VM_NAME}/" < ${BUTANE_CONFIG} > ${BUTANE_CONFIG_TAILORED}

# Generate ignition file from butane input
podman run \
    -i \
    --rm \
    quay.io/coreos/butane:release \
    --pretty \
    --strict \
    < ${BUTANE_CONFIG_TAILORED} > ${IGNITION_INP}

# Copy to libvirt so apparmor is happy
sudo cp ${IGNITION_INP} /var/lib/libvirt/images/

# Create the VM
virt-install \
    --connect="qemu:///system" \
    --name="${VM_NAME}" \
    --vcpus="${VCPUS}" \
    --memory="${RAM_MB}" \
    --os-variant="fedora-coreos-$STREAM" \
    --import \
    --graphics=none \
    --disk="size=${DISK_GB},backing_store=${IMAGE}" \
    --network bridge=virbr0 \
    "${IGNITION_DEVICE_ARG[@]}"