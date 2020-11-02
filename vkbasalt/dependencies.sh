#!/usr/bin/env bash

# Install dependencies
apt install --force-yes --yes \
  libx11-dev \
  glslang-dev \
  meson \
  glslang-tools \
  cmake \
  pkg-config \
  gcc \
  g++ \
  gcc-multilib \
  g++-multilib

# We need i386 dependences for the 32 bit version
dpkg --add-architecture i386
apt update
apt install --force-yes --yes libx11-dev:i386
