#!/usr/bin/env bash

# Extract linuxdeploy se we not use fuse for building
/linuxdeploy.AppImage --appimage-extract

# Go to git
cd ./git

# Prepare files if needed (desktop, icon...)
cat << EOF > ./mangohud.desktop 
[Desktop Entry]
Encoding=UTF-8
Name=MangoHud
Categories=Development;
Exec=mangohud
Icon=debian-logo
Terminal=true
Type=Application
StartupNotify=true
EOF

# Create wrapper
# Carefull to escape $ and backslash properly
# https://github.com/probonopd/linuxdeployqt/wiki/Custom-wrapper-script-instead-of-AppRun
cat <<'EOF' > ./AppDir/AppRun
#!/bin/bash

HERE="$(dirname "$(readlink -f "${0}")")"

if [ "$#" -eq 0 ]; then
        programname=`basename "$0"`
        echo "ERROR: No program supplied"
        echo
        echo "Usage: $programname <program>"
        exit 1
fi

if [ "$1" = "--dlsym" ]; then
        MANGOHUD_DLSYM=1
        shift
fi

MANGOHUD_LIB_NAME="libMangoHud.so"

if [ "$MANGOHUD_DLSYM" = "1" ]; then
        MANGOHUD_LIB_NAME="libMangoHud_dlsym.so:${MANGOHUD_LIB_NAME}"
fi

# Preload using the plain filesnames of the libs, the dynamic linker will
# figure out whether the 32 or 64 bit version should be used, and will search
# for it in the correct directory
LD_PRELOAD="${LD_PRELOAD}:${MANGOHUD_LIB_NAME}"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$HERE/usr/lib/mangohud/\$LIB/"

# Add MangoHud implicit layer to VK_LAYER_PATH and make a version where $HERE is in library_path and that we want activate the MangoHud layer
VK_LAYER_PATH="${VK_LAYER_PATH}:$HERE/usr/share/vulkan/implicit_layer.d/"
VK_INSTANCE_LAYERS=${VK_INSTANCE_LAYERS}:VK_LAYER_MANGOHUD_overlay 

# DEBUG
echo "HERE: $HERE"
echo "LD_PRELOAD: $LD_PRELOAD"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "VK_LAYER_PATH: $VK_LAYER_PATH"
echo "VK_INSTANCE_LAYERS: $VK_INSTANCE_LAYERS"
echo "\$@: $@"

exec env \
  MANGOHUD=1 \
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" \
  LD_PRELOAD="${LD_PRELOAD}" \
  VK_LAYER_PATH="${VK_LAYER_PATH}" \
  VK_INSTANCE_LAYERS=${VK_INSTANCE_LAYERS} \
  "$@"
EOF

# Set execute bit
chmod +x ./AppDir/AppRun

# Create symlink in AppDir like the mangohud-setup script
cd ./AppDir/usr/
# FIXME get the triplet somehow
ln -sv lib ././lib/mangohud/lib64
ln -sv lib ././lib/mangohud/x86_64
ln -sv lib ././lib/mangohud/x86_64-linux-gnu
ln -sv . ././lib/mangohud/lib/x86_64
ln -sv . ././lib/mangohud/lib/x86_64-linux-gnu
ln -sv lib32 ././lib/mangohud/i686
ln -sv lib32 ././lib/mangohud/i386-linux-gnu
ln -sv ../lib32 ././lib/mangohud/lib/i386-linux-gnu
ln -sv lib32 ././lib/mangohud/i686-linux-gnu
ln -sv ../lib32 ././lib/mangohud/lib/i686-linux-gnu
#ln -sv lib /usr/lib/mangohud/aarch64-linux-gnu
#ln -sv lib /usr/lib/mangohud/arm-linux-gnueabihf
cd ../../

# Make the implicit vulkan layer with a relative library_path
sed -i 's#/usr/#../../../#g' ./AppDir/usr/share/vulkan/implicit_layer.d/MangoHud.json

# Build appimage with linuxdeploy
# Need to define ARCH for no reason
ARCH=x86_64 /squashfs-root/AppRun \
  --appdir ./AppDir \
  -d ./mangohud.desktop \
  -i /usr/share/pixmaps/debian-logo.png \
  --output appimage

# Move AppImage to /target
mv ./*.AppImage /target/

# Move also the lib for people that not want the MangoHud wrapper
mv ./AppDir/usr/lib/mangohud/ /target/

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
