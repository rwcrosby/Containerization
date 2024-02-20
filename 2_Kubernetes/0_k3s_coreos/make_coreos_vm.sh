#!/bin/bash

# Default VM name if not entered on the command line
VM_NAME=${1-"k3s"}

BASE=$(pwd)

IMAGE=$BASE/fedora-coreos-39.20240128.3.0-qemu.x86_64.qcow2
BUTANE_CONFIG="coreos-base.bu"
IGNITION_INP="/tmp/coreos-base.ign"
IGNITION_CONFIG="/var/lib/libvirt/images/coreos-base.ign"
VCPUS="2"
RAM_MB="4096"
STREAM="stable"
DISK_GB="20"
IGNITION_DEVICE_ARG=(--qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGNITION_CONFIG}")

# Generate ignition file from butane input
podman run -i --rm quay.io/coreos/butane:release --pretty --strict < ${BUTANE_CONFIG} > ${IGNITION_INP}

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