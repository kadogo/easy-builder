#!/usr/bin/env bash

# Define GIT repo
declare -r GIT='https://github.com/benjamimgois/goverlay.git'

# Clone the GIT
git clone "$GIT" ./git
cd ./git

# Build the application
lazbuild -B goverlay.lpi

# Change Makefile to prepare AppDir
sed -i -e "s|^prefix.*$|prefix = $(pwd)/AppDir/usr/|g" Makefile 
make install
