#!/usr/bin/env bash

# Install dependencies
# autoconf
# automake
# intltool
# gtk3
# Need libglib2.0-dev for an issue during autoreconf -ivf (build.sh)
apt install --force-yes --yes \
  autoconf \
  automake \
  intltool \
  libgtk-3-dev \
  libglib2.0-dev
