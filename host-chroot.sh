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
  ansible \
  audacity \
  bash-completion \
  bridge-utils \
  btrfs-progs \
  chromium \
  curl \
  deja-dup \
  docker \
  firefox \
  git \
  gnome \
  gnome-tweak-tool \
  hddtemp \
  htop \
  iftop \
  intel-ucode \
  iotop \
  lame \
  lib32-nvidia-utils \
  libvirt \
  lm_sensors \
  lsof \
  mc \
  mesa \
  mumble \
  ncdu \
  networkmanager \
  nmap \
  ntp \
  nvidia \
  nvidia-settings \
  openssh \
  openttd \
  openttd-opengfx \
  powertop \
  qemu \
  quassel-client \
  reptyr \
  rsnapshot \
  samba \
  screen \
  skype-call-recorder \
  sl \
  smbclient \
  steam \
  strace \
  sudo \
  synergy \
  teamspeak3 \
  tmux \
  tree \
  vagrant \
  vim \
  virt-manager \
  virtualbox \
  virtualbox-guest-iso \
  virtualbox-host-modules \
  wget \
  which \
  xorg-server \
  xorg-server-devel
  xorg-server-utils \
  xorg-twm \
  xorg-xclock \
  xorg-xinit \
  xterm \
  yaourt \
  youtube-dl

useradd -m -g users -s /bin/bash $USER
usermod -aG wheel docker $USER

echo "root:22" | chpasswd
echo "$USER:22" | chpasswd

systemctl enable sshd
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable docker
systemctl enable ntpd

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
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options root=/dev/$PARTITION rw intel_iommu=on
EOT

nvidia-xconfig
cp /etc/X11/xorg.conf /etc/X11/xorg.conf.d/20-nvidia.conf

mkinitcpio -p linux

echo "Ranking mirrors..."

# rank pacman mirrors
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed '/^#S/ s|#||' -i /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

echo ""
echo "All done. Just add your modules to mkinitcpio.conf"
