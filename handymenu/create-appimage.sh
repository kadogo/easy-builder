#!/usr/bin/env bash

# Extract linuxdeploy because fuse is not available in Docker
./linuxdeploy.AppImage --appimage-extract

# Go to git
cd ./git

# Copy files in AppDir
for i in $(dpkg -L handymenu); do
  if ! test -d "$i" ; then
    mkdir -p ./AppDir/$(dirname "$i") && cp -a "$i" ./AppDir/"$i"
  fi
done
for i in $(dpkg -L python3-gi); do
  if ! test -d "$i" ; then
    mkdir -p ./AppDir/$(dirname "$i") && cp -a "$i" ./AppDir/"$i"
  fi
done
for i in $(dpkg -L python3-xdg); do
  if ! test -d "$i" ; then
    mkdir -p ./AppDir/$(dirname "$i") && cp -a "$i" ./AppDir/"$i"
  fi
done
for i in $(dpkg -L python3-minimal); do
  if ! test -d "$i" ; then
    mkdir -p ./AppDir/$(dirname "$i") && cp -a "$i" ./AppDir/"$i"
  fi
done

# Patch files that have /usr/ hardcoded and bypass shebang for hm-start.py
sed -i \
  -e 's|/usr/share/|$HERE/usr/share/|g' \
  -e 's|./hm-start.py|python3 ./hm-start.py|g' ./AppDir/usr/bin/handymenu
sed -i 's|"/usr/share/|os.getenv("HERE") + "/usr/share/|g' ./AppDir/usr/share/handymenu/hm_utils.py

# Create wrapper
# Careful to escape $ and backslash properly
# https://github.com/probonopd/linuxdeployqt/wiki/Custom-wrapper-script-instead-of-AppRun
cat <<'EOF' > ./AppDir/AppRun
#!/bin/bash

# Keep fullpath in HERE
export HERE="$(dirname "$(readlink -f "${0}")")"

# Update PATH
export PATH="$HERE/usr/bin/:$PATH"

if [ -z "$(ps aux | grep 'hm-start.py' | grep -v 'grep')" ]; then
    cd "$HERE/usr/share/handymenu"
    python3 ./hm-start.py \$@
else
    echo "Handy-menu est d  j   lanc  "
    killall hm-start.py
    cd "$HERE/usr/share/handymenu"
    python3 ./hm-start.py \$@
fi

# Workaround to keep appimage alive if we have one or other script running because each script close the window
while true ; do
  # wait 2s to let it run the script
  sleep 2
  # grep -v if needed without it will grep itself
  if [[ -z "$(ps aux | grep 'hm-start.py' | grep -v 'grep')" ]] && [[ -z "$(ps aux | grep 'handymenu-configuration.py' | grep -v 'grep')" ]] ; then
    # If hm-start.py doesn't run and handymenu-configuration.py too it means we closed everything
    exit 0
  fi
done
EOF

# Set wrapper executable
chmod +x ./AppDir/AppRun

# Build appimage with linuxdeploy
ARCH=x86_64 ../squashfs-root/AppRun \
  --appdir ./AppDir/ \
  -d ./AppDir/usr/share/applications/handymenu.desktop \
  --output appimage

# Move AppImage to /target
mv ./*.AppImage /target/

# Execute the CMD command by default in Dockerfile or what we pass as argument
exec "$@"
