#!/bin/sh
xrandr \
  --output DVI-D-0 --mode 1920x1080 --pos 0x1376 --rotate normal \
  --output HDMI-0 --mode 1920x1080 --pos 2680x0 --rotate normal \
  --output DVI-I-1 --off \
  --output DVI-I-0 --mode 1920x1080 --pos 5360x1376 --rotate normal \
  --output DP-1 --primary --mode 3440x1440 --pos 1920x1080 --rotate normal \
  --output DP-0 --off

# Hotplug USB devices to Windows
sudo virsh detach-device win10 usb-xmls/mouse-razer.xml
sudo virsh detach-device win10 usb-xmls/keyboard-k70.xml

# stop synergyc
sudo systemctl stop synergyc@alex.service
