#!/bin/sh
xrandr \
  --output DVI-D-0 --mode 1920x1080 --pos 0x1080 --rotate normal \
  --output HDMI-0 --mode 1920x1080 --pos 1528x0 --rotate normal \
  --output DVI-I-1 --off \
  --output DVI-I-0 --mode 1920x1080 --pos 3008x1080 --rotate normal \
  --output DP-1 --off \
  --output DP-0 --off
