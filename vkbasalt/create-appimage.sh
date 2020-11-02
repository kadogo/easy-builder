#!/usr/bin/env bash

# Extract linuxdeploy se we not use fuse for building
/linuxdeploy.AppImage --appimage-extract

# Go to git
cd ./git

# Prepare files if needed (desktop, icon...)
cat << EOF > ./vkbasalt.desktop 
[Desktop Entry]
Encoding=UTF-8
Name=vkBasalt
Categories=Development;
Exec=vkbasalt
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

# Preload using the plain filesnames of the libs, the dynamic linker will
# figure out whether the 32 or 64 bit version should be used, and will search
# for it in the correct directory
LD_PRELOAD="${LD_PRELOAD}:libvkbasalt.so"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$HERE/usr/lib/:$HERE/usr/lib32/"

# Add vkBasalt implicit layer to VK_LAYER_PATH and make a version where $HERE is in library_path and that we want activate the vkBasalt layer
VK_LAYER_PATH="${VK_LAYER_PATH}:$HERE/usr/share/vulkan/implicit_layer.d/"
VK_INSTANCE_LAYERS=${VK_INSTANCE_LAYERS}:VK_LAYER_VKBASALT_post_processing

# DEBUG
echo "HERE: $HERE"
echo "LD_PRELOAD: $LD_PRELOAD"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"
echo "VK_LAYER_PATH: $VK_LAYER_PATH"
echo "VK_INSTANCE_LAYERS: $VK_INSTANCE_LAYERS"
echo "\$@: $@"

exec env \
  ENABLE_VKBASALT=1 \
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH}" \
  LD_PRELOAD="${LD_PRELOAD}" \
  VK_LAYER_PATH="${VK_LAYER_PATH}" \
  VK_INSTANCE_LAYERS=${VK_INSTANCE_LAYERS} \
  "$@"
EOF

# Set execute bit
chmod +x ./AppDir/AppRun

# Move lib and share to ./AppDir/usr/
mkdir ./AppDir/usr/
mv ./AppDir/lib/ ./AppDir/share/ ./AppDir/usr/

# Build appimage with linuxdeploy
# Need to define ARCH for no reason
ARCH=x86_64 /squashfs-root/AppRun \
  --appdir ./AppDir \
  -d ./vkbasalt.desktop \
  -i /usr/share/pixmaps/debian-logo.png \
  --output appimage

# Move AppImage to /target
mv ./*.AppImage /target/

# Move also the lib for people that not want the vkBasalt wrapper
mkdir /target/vkBasalt/
mv ./AppDir/usr/lib/* /target/vkBasalt/

# Copy also the vulkan implicit layer
cp -a ./AppDir/usr/share/vulkan/ /target/vkBasalt/

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
