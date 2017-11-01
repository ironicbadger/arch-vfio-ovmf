#!/bin/bash
# run this once you're in the chroot

echo "Enter the target hostname..."
read HOSTNAME
echo "Enter the main user (usually alex)..."
read USER
echo "Enter rootfs partition to install systemd-boot, usually sda2 (no /dev/):"
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

pacman -Syu --needed \
  arandr \
  ansible \
  audacity \
  bash-completion \
  bridge-utils \
  btrfs-progs \
  ccache \
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
  intel-ucode \
  iotop \
  lame \
  libvirt \
  lm_sensors \
  lsof \
  mc \
  mesa \
  ncdu \
  nmap \
  ntp \
  openssh \
  openttd \
  openttd-opengfx \
  powertop \
  qemu \
  quassel-client \
  samba \
  screen \
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
  wget \
  which \
  xorg-server \
  xorg-server-devel \
  xorg-twm \
  xorg-xclock \
  xorg-xinit \
  xorg-xrandr \
  xterm \
  yaourt \
  youtube-dl
  #lib32-nvidia-utils \
  #nvidia \
  #nvidia-settings \

useradd -m -g users -s /bin/bash $USER
usermod -aG wheel $USER
usermod -aG docker $USER

echo "root:22" | chpasswd
echo "$USER:22" | chpasswd

systemctl enable sshd
systemctl enable gdm
systemctl enable NetworkManager
systemctl enable docker
systemctl enable ntpd

# ccache
SEARCH=" \!ccache "
REPLACE=" ccache "
perl -i -pe "s/$SEARCH/$REPLACE/g" /etc/makepkg.conf
# Uses more threads for compilation
SEARCH="#MAKEFLAGS=\"-j.\""
REPLACE="MAKEFLAGS=\"-j$(nproc)\""
perl -i -pe "s/$SEARCH/$REPLACE/g" /etc/makepkg.conf
# Disables compression of packages
SEARCH="PKGEXT=\'.pkg.tar.xz\'"
REPLACE="PKGEXT=\'.pkg.tar\'"
perl -i -pe "s/$SEARCH/$REPLACE/g" /etc/makepkg.conf
# Uses more threads for compression
SEARCH="COMPRESSXZ=\(xz -c -z -\)"
REPLACE="COMPRESSXZ=(xz -c -z --threads=$(nproc))"
perl -i -pe "s/$SEARCH/$REPLACE/g" /etc/makepkg.conf

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

# git setup
echo "Configuring git..."
git config --global user.email "alexktz@gmail.com"
git config --global user.name "IronicBadger"
git config --global push.default simple

# configure X for nvidia
#echo "Configuring X..."
#nvidia-xconfig
#cp /etc/X11/xorg.conf /etc/X11/xorg.conf.d/20-nvidia.conf

# initramfs
mkinitcpio -p linux

# rank pacman mirrors
# echo "Ranking mirrors... Takes 5-10 minutes."
# cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
# sed '/^#S/ s|#||' -i /etc/pacman.d/mirrorlist.backup
# rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

cd /opt
curl -LO https://raw.githubusercontent.com/IronicBadger/arch/master/install/post-install.sh
curl -LO https://raw.githubusercontent.com/IronicBadger/arch/master/vfio/vfio.sh

echo ""
echo "All done. Just add your modules to mkinitcpio.conf"
