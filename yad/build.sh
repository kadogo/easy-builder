#!/usr/bin/env bash

# Define GIT repo
declare -r GIT='https://github.com/v1cont/yad'
declare -r COMMIT="fbfb0fafb06fad14b5ddc2d7a9a3064022ee41b4"

# Clone the GIT
git clone "$GIT" ./git
cd ./git

# Checkout COMMIT
if [[ -n "$COMMIT" ]] ; then
  git checkout "$COMMIT"
fi

# Build the application
autoreconf -ivf
intltoolize
./configure prefix=$(pwd)/AppDir --enable-standalone
make
make install
