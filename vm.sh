#!/bin/bash
set -euo pipefail

if ! dpkg -l wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>&1; then
    apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>/dev/null
fi

IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"

IMG_FILE="ubuntu.img"
SEED_FILE="ubuntu-seed.iso"

if [[ ! -f "$IMG_FILE" ]]; then
    wget --progress=bar:force -O "$IMG_FILE" "$IMG_URL"
fi

qemu-img resize "$IMG_FILE" "20G"

cat > user-data <<EOF
#cloud-config
hostname: lavabyte
ssh_pwauth: true
disable_root: false
users:
  - name: user
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "123" | tr -d '\n')
chpasswd:
  list: |
    root:123
    user:123
  expire: false
EOF

cat > meta-data <<EOF
instance-id: iid-ubuntu
local-hostname: lavabyte
EOF

cloud-localds "$SEED_FILE" user-data meta-data

rm -f user-data meta-data

qemu-system-x86_64 \
    -enable-kvm \
    -m "16384" \
    -smp "2" \
    -cpu host \
    -drive "file=$IMG_FILE,format=qcow2,if=virtio" \
    -drive "file=$SEED_FILE,format=raw,if=virtio" \
    -boot order=c \
    -device virtio-net-pci,netdev=n0 \
    -netdev "user,id=n0,hostfwd=tcp::2222-:22" \
    -nographic \
    -serial mon:stdio \
    -device virtio-balloon-pci \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0
