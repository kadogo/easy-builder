#!/usr/bin/env bash

# Define architecture
declare -r ARCH=$(uname -m)

# Download linuxdeploy appimage based on architecture and set executable bit
if [[ "$ARCH" = "i386" ]] ; then
  wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-i386.AppImage
  chmod +x ./linuxdeploy-i386.AppImage
  mv ./linuxdeploy-i386.AppImage ./linuxdeploy.AppImage
elif [[ "$ARCH" = "x86_64" ]] ; then
  wget https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
  chmod +x ./linuxdeploy-x86_64.AppImage
  mv ./linuxdeploy-x86_64.AppImage ./linuxdeploy.AppImage
else
  printf "Your architecture %s doesn't exist for linuxdeploy." "$ARCH"
  exit 1
fi
