#!/usr/bin/env bash

# Install dependencies
# Lazarus
# librsvg2-2 (for appimage builder gtk helper script)7
# vulkan-tools (vkcube preview)
# mesa-utils (glxgears preview)
apt install --force-yes --yes \
  lazarus \
  librsvg2-dev \
  vulkan-tools \
  mesa-utils
