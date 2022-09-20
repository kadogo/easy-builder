#!/usr/bin/env bash

# Define GIT repo
declare -r GIT='https://debian-facile.org/git/ProjetsDF/handymenu.git'

# Clone the GIT
git clone "$GIT" ./git
cd ./git

# Build the application and install
equivs-build handymenu.equivs
dpkg -i handymenu_*.deb
