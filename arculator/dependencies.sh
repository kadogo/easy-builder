#!/usr/bin/env bash

# Install dependencies
# gcc
# g++
# wget
# make
# libz-dev (zlib)
# libwxgtk3.0-dev (wxWidgets)
# libopenal-dev (OpenAL)
# libasound2-dev (ALSA)
# libsdl2-dev (SDL2)
apt-get install --force-yes --yes \
  gcc \
  g++ \
  wget \
  make \
  libz-dev \
  libwxgtk3.0-dev \
  libopenal-dev \
  libasound2-dev \
  libsdl2-dev
