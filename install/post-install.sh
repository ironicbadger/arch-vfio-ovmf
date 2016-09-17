#!/bin/bash
# post installation stuff not suitable for chroot

yaourt -S --noconfirm \
  packer

echo "Time to install a lot of stuff..."

packer -S --noconfirm \
  atom-editor-bin \
  chromium-pepper-flash \
  corebird \
  gnome-shell-extension-battery-percentage-git \
  gnome-shell-extension-caffeine-git \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-freon-git \
  gnome-shell-extension-gravatar \
  gnome-shell-extension-installer \
  gnome-shell-extension-nohotcorner-git \
  gnome-shell-extension-services-systemd-git \
  gnome-shell-extension-sound-output-device-chooser-git \
  gnome-shell-extension-volume-mixer-git \
  gnome-shell-system-monitor-applet-git \
  haroopad \
  icaclient \
  messengerfordesktop \
  numix-circle-icon-theme-git \
  numix-icon-theme-git \
  packer-io \
  pulseaudio-dlna \
  spotify \
  teamviewer \
  ttf-roboto \
  ttf-roboto-mono

# icaclient ssl cert fix
sudo ln -sf /etc/ssl/certs/* /opt/Citrix/ICAClient/keystore/cacerts/
