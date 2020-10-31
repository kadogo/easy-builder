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
cat << EOF > ./AppDir/AppRun
#!/bin/bash

if [ "\$#" -eq 0 ]; then
	programname=`basename "$0"`
	echo "ERROR: No program supplied (in full path)"
	echo
	echo "Usage: $programname <program>"
	exit 1
fi

HERE="\$(dirname "\$(readlink -f "\${0}")")"

if [ "\$@" = "--dlsym" ]; then
        MANGOHUD_DLSYM=1
        shift
fi

MANGOHUD_LIB_NAME="libMangoHud.so"

if [ "\$MANGOHUD_DLSYM" = "1" ]; then
        MANGOHUD_LIB_NAME="libMangoHud_dlsym.so:\${MANGOHUD_LIB_NAME}"
fi

LD_PRELOAD="\${LD_PRELOAD}:\${MANGOHUD_LIB_NAME}"

# Define which lib to load with MANGOHUDARCH
if [[ "\$MANGOHUDARCH" =  'x86-64' ]] ; then
  LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${HERE}/usr/lib/mangohud/lib/" 
else
  LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}:\${HERE}/usr/lib/mangohud/lib32/"
fi

cd "${HERE}/usr"

# DEBUG
echo "HERE: \$HERE"
echo "MANGOHUDARCH: \$MANGOHUDARCH"
echo "LD_PRELOAD: \$LD_PRELOAD"
echo "LD_LIBRARY_PATH: \$LD_LIBRARY_PATH"
echo "\\\$@: \$@"

exec env MANGOHUD=1 LD_LIBRARY_PATH="\${LD_LIBRARY_PATH}" LD_PRELOAD="\${LD_PRELOAD}" "\$@"
EOF

# Set execute bit
chmod +x ./AppDir/AppRun

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
