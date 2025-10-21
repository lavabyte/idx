#!/bin/bash
set -e

if ! dpkg -l wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>&1; then
    apt update && DEBIAN_FRONTEND=noninteractive apt install -y qemu-system-x86 qemu-utils cloud-image-utils genisoimage
fi

if [[ -f "./vm.sh" ]]; then
    mkdir -p ./root/
    mv ./vm.sh ./root/
fi

IMG_FILE="./ubuntu-vm.img"
SEED_FILE="./ubuntu-seed.iso"
IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

if [[ ! -f "$IMG_FILE" ]]; then
    wget -q "$IMG_URL" -O "$IMG_FILE"
    qemu-img resize "$IMG_FILE" 20G >/dev/null 2>&1
fi

if [[ ! -f "$SEED_FILE" ]]; then
    cat > user-data <<EOF
#cloud-config
hostname: ubuntu-vm
ssh_pwauth: true
users:
  - name: user
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "123")
chpasswd:
  list: |
    user:123
  expire: false
EOF
    cat > meta-data <<EOF
instance-id: iid-ubuntu-vm
local-hostname: ubuntu-vm
EOF
    cloud-localds "$SEED_FILE" user-data meta-data >/dev/null 2>&1
    rm -f user-data meta-data
fi

qemu-system-x86_64 \
    -enable-kvm \
    -m 16384 \
    -smp 4 \
    -drive "file=$IMG_FILE,format=qcow2,if=virtio" \
    -drive "file=$SEED_FILE,format=raw,if=virtio" \
    -nographic
