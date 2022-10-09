#!/usr/bin/env bash

# Extract linuxdeploy se we not use fuse for building
./linuxdeploy.AppImage --appimage-extract

# Go to arculator
cd ./arculator

# Prepare files if needed (desktop, icon...)
cat << EOF > ./arculator.desktop
[Desktop Entry]
Encoding=UTF-8
Name=Arculator
Categories=GTK;Development;
Exec=arculator
Terminal=true
Type=Application
StartupNotify=true
Icon=arculator
EOF

# Build appimage with linuxdeploy
../squashfs-root/AppRun \
  --appdir ./AppDir \
  --executable ./AppDir/bin/arculator \
  -i ./icon/arculator.png \
  -d ./arculator.desktop \
  --output appimage

# Move AppImage to /target
mv ./*.AppImage /target/

# Copy other dirs needed to target
mv ./podules/ ./roms/ ./configs/ ./ddnoise/ ./cmos/ ./hostfs/ /target/

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
