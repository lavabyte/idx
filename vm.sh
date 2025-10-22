#!/bin/bash
if ! dpkg -l wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>&1; then
    apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>/dev/null
fi
if [[ ! -f "disk.qcow2" ]]; then
    wget -O "disk.qcow2" "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    qemu-img resize "disk.qcow2" 20G
fi
cat > user-data <<EOF
#cloud-config
hostname: lavabyte-vm
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
cat > "meta-data" <<EOF
instance-id: lavabyte-vm
local-hostname: lavabyte
EOF
genisoimage -output "conf.img" -volid cidata -joliet -rock "user-data" "meta-data"
rm -f meta-data user-data
qemu-system-x86_64 \
    -enable-kvm \
    -m 2048 \
    -cpu host \
    -smp 2 \
    -drive file="disk.qcow2",format=qcow2,if=virtio \
    -drive file="conf.img",format=raw,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::2224-:22 \
    -device virtio-net-pci,netdev=net0 \
    -nographic \
    -name "lavabyte-vm"
