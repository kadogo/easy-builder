#!/usr/bin/env bash

# Define GIT repo
declare -r GIT='https://github.com/flightlessmango/MangoHud.git'

# Clone the GIT
git clone --recurse-submodules "$GIT" ./git
cd ./git

# Build the application
# We use yes to avoid user action
yes | ./build.sh build

# Rename release to AppDir
mv build/release/ ./AppDir/
