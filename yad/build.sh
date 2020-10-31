#!/usr/bin/env bash

# Define GIT repo
declare -r GIT='https://github.com/v1cont/yad'

# Clone the GIT
git clone "$GIT" ./git
cd ./git

# Build the application
autoreconf -ivf
intltoolize
./configure prefix=$(pwd)/AppDir --enable-standalone
make
make install
