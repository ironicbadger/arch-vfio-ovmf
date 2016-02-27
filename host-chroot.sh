#!/bin/bash
# run this once you're in the chroot

echo "Enter the target hostname..."
read HOSTNAME
echo "Enter the main user (usually kolbasz)..."
read USER
echo "Enter rootfs partition to install systemd-boot, usually sda2:"
read PARTITION

echo "Hostname:               '$HOSTNAME'"
echo "Username:               '$USER'"
echo "systemd-boot partition: '/dev/$PARTITION'"
echo ""
echo ""

### Doing actual stuff
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
ln -s /usr/share/zoneinfo/America/New York /etc/localtime
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

cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup \
sed '/^#S/ s|#||' -i /etc/pacman.d/mirrorlist.backup \
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

pacman -Syu \
#  ansible \
  audacity \
  bash-completion \
  bridge-utils \
  cinnamon \
#  chromium \
  curl \
  deja-dup \
  docker \
#  firefox \
  git \
  gnome \
  gnome-tweak-tool \
  grub \
  hddtemp \
  htop \
  iftop \
  iotop \
  lame \
#  lib32-nvidia-utils \
  lib32-nvidia-340xx-libgl \
#  libvirt \
  lightdm \
  lm_sensors \
  lsof \
  mc \
#  mesa \
  mumble \
  ncdu \
  networkmanager \
  nmap \
  ntp \
#  nvidia \
nvidia-304xx \
nvidia-304xx-libgl \
#  nvidia-settings \
  openssh \
#  openttd \
#  openttd-opengfx \
  os-prober \
  powertop \
#  qemu \
  quassel-client \
  reptyr \
  rsnapshot \
  samba \
  screen \
  skype-call-recorder \
  sl \
  smbclient \
#  steam \
  strace \
  sudo \
  synergy \
  terminator \
  teamspeak3 \
  tmux \
  tree \
#  vagrant \
  vim \
#  virt-manager \
#  virtualbox \
#  virtualbox-guest-iso \
#  virtualbox-host-modules \
  wget \
  which \
#  xorg-server \
#  xorg-server-devel
#  xorg-server-utils \
#  xorg-twm \
#  xorg-xclock \
#  xorg-xinit \
#  xterm \
  yaourt \
  youtube-dl
  
nvidia-xconfig
  
useradd -m -g users -s /bin/bash $USER
usermod -a -G wheel $USER

echo "root:password" | chpasswd
echo "$USER:password" | chpasswd

cat <<EOT >> /etc/bash.bashrc
export EDITOR=nano
EOT

systemctl enable sshd
#systemctl enable gdm
systemctl enable NetworkManager

grub-install /dev/sdagrub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

## systemd-boot
#bootctl --path=/boot/$esp install
#rm /boot/loader/loader.conf

#cat <<EOT >> /boot/loader/loader.conf
#default arch
#timeout 1
#editor 0
#EOT

#cat <<EOT >> /boot/loader/entries/arch.conf
#title   Arch Linux
#linux   /vmlinuz-linux
#initrd  /initramfs-linux.img
#options root=/dev/$PARTITION rw intel_iommu=on
#EOT

echo ""
echo "All done. Just add your modules to mkinitcpio.conf"
