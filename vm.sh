#!/bin/bash
if ! dpkg -l wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>&1; then
    apt update && DEBIAN_FRONTEND=noninteractive apt install -y wget qemu-system-x86 qemu-utils cloud-image-utils genisoimage >/dev/null 2>/dev/null
fi
wget -O "disk.qcow2" "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
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
    user:123
  expire: false
write_files:
  - path: /etc/ssh/ssh_config.d/serveo.conf
    content: |
      Host serveo.net
        StrictHostKeyChecking no
        UserKnownHostsFile /dev/null
        ServerAliveInterval 60
        ServerAliveCountMax 3
    permissions: '0644'
runcmd:
  - systemctl enable ssh
  - systemctl start ssh
  - sudo -u user nohup ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -R 22:localhost:22 serveo.net >/root/.ssh-server 2>&1 &
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
