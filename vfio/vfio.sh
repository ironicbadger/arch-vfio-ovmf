#!/bin/bash

echo "Please paste the URL from https://www.kraxel.org/repos/jenkins/edk2/ for edk2:"
read URL
echo "Please enter main user for this system (alex):"
read USER

# setup arch for PCI passthrough
pacman -Sy --noconfirm \
  qemu \
  rpmextract \
  synergy

usermod -aG libvirt $USER
cd /tmp
wget $URL
rpmextract.sh edk2.*.rpm
cp -R ./usr/share/* /usr/share

# get vfio-pci ids
lspci -nn|grep -iP "NVIDIA|Radeon"
echo ""
echo ""
echo "Please enter your vfio-pci ids, no quotes (e.g. '10de:1234,10de:4321')"
read VFIOID
echo options vfio-pci ids=$VFIOID > /etc/modprobe.d/vfio.conf
echo ""
echo "Your new /etc/modprobe.d/vfio.conf looks like this..."
echo "-----------"
cat /etc/modprobe.d/vfio.conf
echo ""

read -p "Please press [Enter] to continue if this looks correct..."

# backing up qemu.conf
mv /etc/libvirt/qemu.conf /etc/libvirt/qemu.conf.orig

# configuring qemu.conf
cat <<EOT >> /etc/libvirt/qemu.conf
user = "root"
group = "root"
clear_emulator_capabilities = 0
cgroup_device_acl = [
    "/dev/null", "/dev/full", "/dev/zero",
    "/dev/random", "/dev/urandom",
    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
    "/dev/rtc","/dev/hpet", "/dev/vfio/vfio",
    "/dev/vfio/1"
]
nvram = [
  "/usr/share/edk2.git/ovmf-x64/OVMF_CODE-pure-efi.fd:/usr/share/edk2.git/ovmf-x64/OVMF_VARS-pure-efi.fd",
]
EOT

# to fix geforce experience
echo options kvm ignore_msrs=1 > /etc/modprobe.d/kvm.conf

# networking
cat <<EOT>> /etc/netctl/bridge
Interface=br0
Connection=bridge
BindsToInterfaces=(enp3s0)
IP=dhcp
EOT

cat <<EOT>> /etc/netctl/ethernet
Description='enp0s31f6 ethernet connection'
Interface=enp0s31f6
Connection=ethernet
IP=no
EOT

netctl enable ethernet
netctl enable bridge

echo ""
echo "Enabling libvirtd service..."
systemctl enable libvirtd
systemctl start libvirtd

# virtio modules to initramfs
sed -i 's/\(MODULES="\)/\1vfio vfio_iommu_type1 vfio_pci vfio_virqfd /' /etc/mkinitcpio.conf
mkinitcpio -p linux

echo "All setup for VFIO, time to reboot!"
