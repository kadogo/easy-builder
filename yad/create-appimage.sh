#!/usr/bin/env bash

# Extract linuxdeploy se we not use fuse for building
./linuxdeploy.AppImage --appimage-extract

# Go to git
cd ./git

# Prepare files if needed (desktop, icon...)
cat << EOF > ./yad.desktop 
[Desktop Entry]
Encoding=UTF-8
Name=Yad
Categories=GTK;Development;
Exec=yad
Icon=yad
Terminal=true
Type=Application
StartupNotify=true
EOF

# Build appimage with linuxdeploy
../squashfs-root/AppRun \
  --appdir ./AppDir \
  -i ./data/icons/128x128/yad.png \
  --executable ./AppDir/bin/yad \
  -d ./yad.desktop \
  --output appimage

# Move AppImage to /target
mv ./*.AppImage /target/

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
