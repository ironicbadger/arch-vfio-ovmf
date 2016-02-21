#!/bin/bash
# run this once you're in the chroot

echo "Enter the target hostname..."
read HOSTNAME
echo "Enter the main user (usually alex)..."
read USER
echo "Enter rootfs partition to install systemd-boot, usually sda2:"
read PARTITION

echo "Hostname:               '$HOSTNAME'"
echo "Username:               '$USER'"
echo "systemd-boot partition: '/dev/$PARTITION'"
echo ""
echo ""

### Doing actual stuff
echo en_GB.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
echo LANG=en_GB.UTF-8 > /etc/locale.conf
export LANG=en_GB.UTF-8
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc
mkinitcpio -p linux
echo $HOSTNAME > /etc/hostname

# packages
cat <<EOT >> /etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist

[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/\$arch
EOT

pacman -Syu \
  bridge-utils \
  chromium \
  curl \
  docker \
  firefox \
  git \
  gnome \
  gnome-tweak-tool \
  hddtemp \
  htop \
  iftop \
  iotop \
  libvirt \
  lm_sensors \
  lsof \
  mc \
  ncdu \
  networkmanager \
  nmap \
  ntp \
  openssh \
  qemu \
  quassel-client \
  screen \
  samba \
  smbclient \
  sudo \
  synergy \
  tmux \
  tree \
  vim \
  virt-manager \
  wget \
  which \
  xf86-video-intel \
  yaourt \
  youtube-dl

useradd -m -g users -s /bin/bash $USER
usermod -a -G wheel $USER

echo "root:password" | chpasswd
echo "$USER:password" | chpasswd

systemctl enable sshd
systemctl enable gdm
systemctl enable NetworkManager

# systemd-boot
bootctl --path=/boot/$esp install
rm /boot/loader/loader.conf

cat <<EOT >> /boot/loader/loader.conf
default arch
timeout 1
editor 0
EOT

cat <<EOT >> /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=/dev/$PARTITION rw intel_iommu=on
EOT

echo ""
echo "All done. Just add your modules to mkinitcpio.conf"
