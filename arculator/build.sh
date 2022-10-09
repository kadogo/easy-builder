#!/usr/bin/env bash

# Define URL
declare -r URL='http://b-em.bbcmicro.com/arculator/Arculator_V2.1_Linux.tar.gz'

# Go to another folder because the archive doesn't have one
mkdir arculator && cd arculator

# Download URL
wget "$URL"

# Extract
tar xfv ./*.tar.gz

# Create AppDir
mkdir ./AppDir

# Build
./configure --disable-dependency-tracking --prefix=$(pwd)/AppDir

# Make
make

# Make install
make install
