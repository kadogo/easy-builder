#!/usr/bin/env bash

# Disable stripping the appimage
# 0 enable stripping
# 1 disable strpping
export NO_STRIP=1

# TARGET path
declare -r TARGET="/target/"

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

# Move AppImage to $TARGET
printf 'Appimage is moved to directory: "%s"\n' "$TARGET"
mv ./*.AppImage "$TARGET"

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
