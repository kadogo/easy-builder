#!/usr/bin/env bash

# Define GIT repo
declare -r GIT='https://github.com/DadSchoorse/vkBasalt.git'

# Remove old /git because we use gcc9 docker image
if [[ -d ./git ]] ; then
  rm -Rf ./git
fi

# Clone the GIT
git clone "$GIT" ./git
cd ./git

# Build the application
LDFLAGS=-static-libstdc++ meson --buildtype=release --prefix=$(pwd)/AppDir builddir
ninja -C builddir install

# Build the application (32bit)
LDFLAGS=-static-libstdc++ ASFLAGS=--32 CFLAGS=-m32 CXXFLAGS=-m32 PKG_CONFIG_PATH=/usr/lib/i386-linux-gnu/pkgconfig meson --prefix=$(pwd)/AppDir --buildtype=release --libdir=lib/i386-linux-gnu -Dwith_json=false builddir.32
ninja -C builddir.32 install
